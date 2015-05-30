-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Patrick Lehmann
--
-- Module:					PicoBlaze UART Wrapper
-- 
-- Description:
-- ------------------------------------
--		TODO
--		
--
-- License:
-- ============================================================================
-- Copyright 2007-2015 Patrick Lehmann - Dresden, Germany
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--		http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ============================================================================

library IEEE;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.NUMERIC_STD.all;

library PoC;
use			PoC.config.all;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.physical.all;
use			PoC.io.all;
use			PoC.xil.all;

library	L_PicoBlaze;
use			L_PicoBlaze.pb.all;


entity pb_UART_Wrapper is
	generic (
		DEBUG													: BOOLEAN												:= TRUE;
		ENABLE_CHIPSCOPE							: BOOLEAN												:= TRUE;
		CLOCK_FREQ										: FREQ													:= 100.0 MHz;
		BAUDRATE											: BAUD													:= 115.200 kBd;
		DEVICE_INSTANCE								: T_PB_DEVICE_INSTANCE
	);
	port (
		Clock													: in	STD_LOGIC;
		Reset													: in	STD_LOGIC;

		-- PicoBlaze interface
		Address												: in	T_SLV_8;
		WriteStrobe										: in	STD_LOGIC;
		WriteStrobe_K									: in	STD_LOGIC;
		ReadStrobe										: in	STD_LOGIC;
		DataIn												: in	T_SLV_8;
		DataOut												: out	T_SLV_8;

		Interrupt											: out	STD_LOGIC;
		Interrupt_Ack									: in	STD_LOGIC;
		Message												: out	T_SLV_8;
		
		ICON_ControlBus								: inout	T_XIL_CHIPSCOPE_CONTROL;
		
		-- UART physical interface
		UART_TX												: out	STD_LOGIC;
		UART_RX												: in	STD_LOGIC
	);
end entity;


architecture rtl of pb_UART_Wrapper is
	attribute KEEP										: BOOLEAN;
	attribute FSM_ENCODING						: STRING;

	constant UART_OVERSAMPLING_RATE		: POSITIVE					:= 16;
	constant TIME_UNIT_INTERVAL				: TIME							:= 1.0 sec / (to_real(BAUDRATE, 1.0 Bd) * real(UART_OVERSAMPLING_RATE));
	constant BAUDRATE_COUNTER_MAX			: POSITIVE					:= TimingToCycles(TIME_UNIT_INTERVAL, CLOCK_FREQ);
	constant BAUDRATE_COUNTER_BITS		: POSITIVE					:= log2ceilnz(BAUDRATE_COUNTER_MAX + 1);
	
	signal BaudRate_Counter_rst				: STD_LOGIC;
	signal BaudRate_Counter_us				: UNSIGNED(BAUDRATE_COUNTER_BITS + 1 downto 0);
	signal BaudRate_Counter_eq				: STD_LOGIC;

	signal ClockEnable								: STD_LOGIC;

	signal Adapter_TX_put							: STD_LOGIC;
	signal Adapter_TX_Data						: T_SLV_8;
	signal TXUART_Empty_n							: STD_LOGIC;
	signal TXUART_HalfFull						: STD_LOGIC;
	signal TXUART_Full								: STD_LOGIC;
	
	signal RXUART_Data								: T_SLV_8;
	signal Adapter_RX_got							: STD_LOGIC;
	signal RXUART_Empty_n							: STD_LOGIC;
	signal RXUART_HalfFull						: STD_LOGIC;
	signal RXUART_Full								: STD_LOGIC;

	signal UART_TX_i									: STD_LOGIC;

BEGIN
	assert FALSE report "pb_UART_Wrapper: BAUDRATE=: " & to_string(BAUDRATE, 3)						severity NOTE;
	assert FALSE report "  TIME_UNIT_INTERVAL: " & to_string(TIME_UNIT_INTERVAL, 3)				severity NOTE;
	assert FALSE report "  BAUDRATE_COUNTER_MAX: " & INTEGER'image(BAUDRATE_COUNTER_MAX)	severity NOTE;
	assert uart_IsTypicalBaudRate(BAUDRATE) report "The given baudrate is not known to be a typical baudrate!" severity WARNING;

	Adapter : entity L_PicoBlaze.pb_UART_Adapter
		generic map (
			DEVICE_INSTANCE						=> DEVICE_INSTANCE
		)
		port map (
			Clock								=> Clock,
			Reset								=> Reset,
			
			-- PicoBlaze interface
			Address							=> Address,
			WriteStrobe					=> WriteStrobe,
			WriteStrobe_K				=> WriteStrobe_K,
			ReadStrobe					=> ReadStrobe,
			DataIn							=> DataIn,
			DataOut							=> DataOut,
			
			Interrupt						=> Interrupt,
			Interrupt_Ack				=> Interrupt_Ack,
			Message							=> Message,
			
			UART_TX_put					=> Adapter_TX_put,
			UART_TX_Data				=> Adapter_TX_Data,
			UART_TX_Empty_n			=> TXUART_Empty_n,
			UART_TX_HalfFull		=> TXUART_HalfFull,
			UART_TX_Full				=> TXUART_Full,
						
			UART_RX_got					=> Adapter_RX_got,
			UART_RX_Data				=> RXUART_Data,
			UART_RX_Empty_n			=> RXUART_Empty_n,
			UART_RX_HalfFull		=> RXUART_HalfFull,
			UART_RX_Full				=> RXUART_Full
		);
	
	process(Clock)
	begin
		if rising_edge(Clock) then
			if (BaudRate_Counter_rst = '1') then
				BaudRate_Counter_us		<= (others => '0');
			else
				BaudRate_Counter_us		<= BaudRate_Counter_us + 1;
			end if;
		end if;
	end process;
	
	BaudRate_Counter_eq					<= to_sl(BaudRate_Counter_us = BAUDRATE_COUNTER_MAX - 1);
	BaudRate_Counter_rst				<= BaudRate_Counter_eq;
	ClockEnable									<= BaudRate_Counter_eq;

	gen00 : if (DEVICE = DEVICE_VIRTEX5) generate
		TX : entity L_PicoBlaze.uart_tx6_unconstrained
			port map (
				clk										=> Clock,
				buffer_reset					=> Reset,
				en_16_x_baud					=> ClockEnable,
			
				data_in								=> Adapter_TX_Data,
				buffer_write					=> Adapter_TX_put,

				buffer_data_present		=> TXUART_Empty_n,
				buffer_half_full			=> TXUART_HalfFull,
				buffer_full						=> TXUART_Full,
							 
				serial_out						=> UART_TX_i
			);
	end generate;
	gen01 : if (DEVICE /= DEVICE_VIRTEX5) generate
		TX : entity L_PicoBlaze.uart_tx6
			port map (
				clk										=> Clock,
				buffer_reset					=> Reset,
				en_16_x_baud					=> ClockEnable,
			
				data_in								=> Adapter_TX_Data,
				buffer_write					=> Adapter_TX_put,

				buffer_data_present		=> TXUART_Empty_n,
				buffer_half_full			=> TXUART_HalfFull,
				buffer_full						=> TXUART_Full,
							 
				serial_out						=> UART_TX_i
			);
	end generate;
	
	gen10 : if (DEVICE = DEVICE_VIRTEX5) generate
		RX : entity L_PicoBlaze.uart_rx6_unconstrained
			port map (
				clk										=> Clock,
				buffer_reset					=> Reset,
				en_16_x_baud					=> ClockEnable,
				
				data_out							=> RXUART_Data,
				buffer_read						=> Adapter_RX_got,
				
				buffer_data_present		=> RXUART_Empty_n,
				buffer_half_full			=> RXUART_HalfFull,
				buffer_full						=> RXUART_Full,

				serial_in							=> UART_RX
			);
	end generate;
	gen11 : if (DEVICE /= DEVICE_VIRTEX5) generate
		RX : entity L_PicoBlaze.uart_rx6
			port map (
				clk										=> Clock,
				buffer_reset					=> Reset,
				en_16_x_baud					=> ClockEnable,
				
				data_out							=> RXUART_Data,
				buffer_read						=> Adapter_RX_got,
				
				buffer_data_present		=> RXUART_Empty_n,
				buffer_half_full			=> RXUART_HalfFull,
				buffer_full						=> RXUART_Full,

				serial_in							=> UART_RX
			);
	end generate;

	UART_TX	<= UART_TX_i;

	genDebug : if (ENABLE_CHIPSCOPE = TRUE) generate
	
	begin
		CSP_UART : entity L_PicoBlaze.CSP_UART_ILA
			port map (
				CONTROL							=> ICON_ControlBus,
				CLK									=> Clock,
				TRIG0(0)						=> Reset,
				TRIG0(1)						=> ClockEnable,
				TRIG0(2)						=> Adapter_RX_got,
				TRIG0(10 downto 3)	=> RXUART_Data,
				TRIG0(11)						=> RXUART_Empty_n,
				TRIG0(12)						=> RXUART_HalfFull,
				TRIG0(13)						=> RXUART_Full,
				TRIG0(14)						=> Adapter_TX_put,
				TRIG0(22 downto 15)	=> Adapter_TX_Data,
				TRIG0(23)						=> TXUART_Empty_n,
				TRIG0(24)						=> TXUART_HalfFull,
				TRIG0(25)						=> TXUART_Full,
				TRIG0(26)						=> UART_TX_i,
				TRIG0(27)						=> UART_RX,
				TRIG0(28)						=> Address(0),
				TRIG0(29)						=> ReadStrobe,
				TRIG_OUT						=> open
			);
	end generate;
end;
