-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Patrick Lehmann
--
-- Module:					PicoBlaze Interrupt Controller with up to 32 ports.
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
--use			PoC.config.all;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.components.all;

library L_PicoBlaze;
use			L_PicoBlaze.pb.all;


entity pb_InterruptController is
	generic (
		DEBUG													: BOOLEAN												:= FALSE;
		ADDRESS_MAPPING								: T_PB_ADDRESS_MAPPING;
		PORTS													: POSITIVE											:= 4
	);
	port (
		Clock													: in	STD_LOGIC;
		Reset													: in	STD_LOGIC;
		
		-- PicoBlaze interface
		PB_Address										: in	T_SLV_8;
		PB_WriteStrobe								: in	STD_LOGIC;
		PB_WriteStrobe_K							: in	STD_LOGIC;
		PB_ReadStrobe									: in	STD_LOGIC;
		PB_DataIn											: in	T_SLV_8;
		PB_DataOut										: out	T_SLV_8;
		PB_Interrupt									: out	STD_LOGIC;
		PB_Interrupt_Ack							: in	STD_LOGIC;
		
		-- Interrupt source interface
		Interrupt											: in	STD_LOGIC_VECTOR(PORTS - 1 downto 0);
		Interrupt_Ack									: out	STD_LOGIC_VECTOR(PORTS - 1 downto 0);
		Interrupt_Message							: in	T_SLVV_8(PORTS - 1 downto 0)
	);
end entity;


architecture rtl of pb_InterruptController is
	attribute KEEP											: BOOLEAN;
	
	constant REQUIRED_REGISTER_BYTES		: POSITIVE		:= div_ceil(PORTS, 8);
	constant ENABLE_DISABLE_POSITIONS		: T_NATVEC		:= (1 => 0, 2 => 1, 3 => 2, 4 => 2);
	constant ENABLE_DISABLE_BIT					: NATURAL			:= ENABLE_DISABLE_POSITIONS(REQUIRED_REGISTER_BYTES);
	constant VECTOR_MESSAGE_BIT					: NATURAL			:= ENABLE_DISABLE_POSITIONS(REQUIRED_REGISTER_BYTES);
	
	constant REG_WO_ENABLE_BIT_VALUE		: STD_LOGIC		:= '0';
	constant REG_WO_DISABLE_BIT_VALUE		: STD_LOGIC		:= '1';
	constant REG_RO_VECTOR_BIT_VALUE		: STD_LOGIC		:= '0';
	constant REG_RO_MESSAGE_BIT_VALUE		: STD_LOGIC		:= '1';
	
	signal AdrDec_we										: STD_LOGIC;
	signal AdrDec_re										: STD_LOGIC;
	signal AdrDec_WriteAddress					: T_SLV_8;
	signal AdrDec_ReadAddress						: T_SLV_8;
	signal AdrDec_Data									: T_SLV_8;
	
	signal Reg_InterruptEnable_slvv			: T_SLVV_8(REQUIRED_REGISTER_BYTES - 1 downto 0)								:= (others => (others => '0'));
	signal Reg_InterruptEnable					: STD_LOGIC_VECTOR((REQUIRED_REGISTER_BYTES * 8) - 1 downto 0);
	
	type T_STATE is (
		ST_IDLE,
		ST_INTERRUPT_PENDING,
		ST_INTERRUPT_MESSAGE
	);
	
	signal State												: T_STATE																			:= ST_IDLE;
	signal NextState										: T_STATE;

	signal Interrupt_re									: STD_LOGIC_VECTOR(PORTS - 1 downto 0);
	signal InterruptPending_r						: STD_LOGIC_VECTOR(PORTS - 1 downto 0)				:= (others => '0');
	signal InterruptMessages_d					: T_SLVV_8(PORTS - 1 downto 0)								:= (others => (others => '0'));
--	signal NewInterrupt									: STD_LOGIC;
	signal InterruptRequestsOpen				: STD_LOGIC;
	
	signal InterruptRequestVector				: STD_LOGIC_VECTOR(PORTS - 1 downto 0);

	signal InterruptSource_Read					: STD_LOGIC;
	signal FSM_DataOut									: T_SLV_8;
	signal FSM_Arbitrate								: STD_LOGIC;
	signal FSM_InterruptClearVector			: STD_LOGIC_VECTOR(PORTS - 1 downto 0);
	
	signal Arb_GrantVector							: STD_LOGIC_VECTOR(PORTS - 1 downto 0);
	signal Arb_GrantVector_bin					: STD_LOGIC_VECTOR(log2ceilnz(PORTS) - 1 downto 0);
	
	attribute KEEP of FSM_Arbitrate						: signal is DEBUG;
	attribute KEEP of Arb_GrantVector					: signal is DEBUG;
	attribute KEEP of InterruptRequestVector	: signal is DEBUG;
	
begin

	assert (PORTS <= 32) report "pb_InterruptController supports only up to 32 interrupt sources!" severity failure;

	AdrDec : entity L_PicoBlaze.PicoBlaze_AddressDecoder
		generic map (
			ADDRESS_MAPPING						=> ADDRESS_MAPPING
		)
		port map (
			Clock											=> Clock,
			Reset											=> Reset,

			-- PicoBlaze interface
			In_Address								=> PB_Address,
			In_WriteStrobe						=> PB_WriteStrobe,
			In_WriteStrobe_K					=> PB_WriteStrobe_K,
			In_ReadStrobe							=> PB_ReadStrobe,
			In_Data										=> PB_DataIn,
			Out_WriteAddress					=> AdrDec_WriteAddress,
			Out_ReadAddress						=> AdrDec_ReadAddress,
			Out_WriteStrobe						=> AdrDec_we,
			Out_ReadStrobe						=> AdrDec_re,
			Out_Data									=> AdrDec_Data
		);

	process(Clock)
		variable index	: NATURAL;
	begin
		index := to_index(AdrDec_WriteAddress(ENABLE_DISABLE_BIT - 1 downto 0));
	
		if rising_edge(Clock) then
			if (Reset = '1') then
				Reg_InterruptEnable_slvv			<= (others => (others => '0'));
			elsif (AdrDec_we = '1') then
				case AdrDec_WriteAddress(ENABLE_DISABLE_BIT) is
					when REG_WO_ENABLE_BIT_VALUE =>		Reg_InterruptEnable_slvv(index)	<= Reg_InterruptEnable_slvv(index) or AdrDec_Data;
					when REG_WO_DISABLE_BIT_VALUE =>	Reg_InterruptEnable_slvv(index)	<= Reg_InterruptEnable_slvv(index) and not AdrDec_Data;
					when others =>				null;
				end case;
			end if;
		end if;
	end process;

	process(AdrDec_re, AdrDec_ReadAddress, Reg_InterruptEnable_slvv, FSM_DataOut)
		variable index	: NATURAL;
	begin
		index := to_index(AdrDec_WriteAddress(VECTOR_MESSAGE_BIT - 1 downto 0));
		
		PB_DataOut				<= FSM_DataOut;
	
		case AdrDec_ReadAddress(VECTOR_MESSAGE_BIT) is
			when REG_RO_VECTOR_BIT_VALUE =>		PB_DataOut		<= Reg_InterruptEnable_slvv(index);
			when REG_RO_MESSAGE_BIT_VALUE =>	PB_DataOut		<= FSM_DataOut;
			when others =>										PB_DataOut		<= (others => 'X');
		end case;
		
		InterruptSource_Read	<= AdrDec_re and to_sl(AdrDec_ReadAddress(VECTOR_MESSAGE_BIT) = REG_RO_MESSAGE_BIT_VALUE);
	end process;

	genPort : for i in 0 to PORTS - 1 generate
		signal Interrupt_d			: STD_LOGIC				:= '0';
	begin
		Interrupt_d							<= Interrupt(i) when rising_edge(Clock);
		Interrupt_re(i)					<= not Interrupt_d and Interrupt(i);

		-- RS-FFs to latch the interrupt signal and the message
		InterruptPending_r(i)		<= ffrs(q => InterruptPending_r(i),															 rst => (Reset or FSM_InterruptClearVector(i)), set => Interrupt_re(i))	when rising_edge(Clock);
		InterruptMessages_d(i)	<= ffdre(q => InterruptMessages_d(i), d => Interrupt_Message(i), rst => (Reset or FSM_InterruptClearVector(i)), en => Interrupt_re(i))	when rising_edge(Clock);
	end generate;

	Reg_InterruptEnable			<= to_slv(Reg_InterruptEnable_slvv);
	InterruptRequestVector	<= InterruptPending_r and Reg_InterruptEnable(InterruptPending_r'range);
	InterruptRequestsOpen		<= slv_or(InterruptRequestVector and not FSM_InterruptClearVector);

	Arb : entity PoC.bus_Arbiter
		generic map (
			STRATEGY									=> "RR",			-- RR, LOT
			PORTS											=> PORTS,
			WEIGHTS										=> (0 to PORTS - 1 => 1),
			OUTPUT_REG								=> FALSE
		)
		port map (
			Clock											=> Clock,
			Reset											=> Reset,
			
			Arbitrate									=> FSM_Arbitrate,
			Request_Vector						=> InterruptRequestVector,
			
			Arbitrated								=> open,	--Arb_Arbitrated,
			Grant_Vector							=> Arb_GrantVector,
			Grant_Index								=> Arb_GrantVector_bin
		);

	process(Clock)
	begin
		if rising_edge(Clock) then
			if (Reset = '1') then
				State			<= ST_IDLE;
			else
				State			<= NextState;
			end if;
		end if;
	end process;

	process(State, InterruptRequestsOpen, Arb_GrantVector, Arb_GrantVector_bin, PB_Interrupt_Ack, InterruptSource_Read, InterruptMessages_d)
	begin
		NextState												<= State;
				
		PB_Interrupt										<= InterruptRequestsOpen;
		FSM_DataOut											<= resize(Arb_GrantVector_bin, PB_DataOut'length);
		
		Interrupt_Ack										<= (others => '0');
			
		FSM_Arbitrate										<= '0';
		FSM_InterruptClearVector				<= (others => '0');
	
		case State is
			when ST_IDLE =>
				if (InterruptRequestsOpen = '1') then
					FSM_Arbitrate							<= '1';
					NextState									<= ST_INTERRUPT_PENDING;				
				end if;
				
			when ST_INTERRUPT_PENDING =>
				FSM_DataOut									<= resize(Arb_GrantVector_bin, PB_DataOut'length);
		
				if (InterruptSource_Read = '1') then
					NextState									<= ST_INTERRUPT_MESSAGE;
				end if;
			
			when ST_INTERRUPT_MESSAGE =>
				FSM_DataOut									<= InterruptMessages_d(to_index(Arb_GrantVector_bin));
			
				if (PB_Interrupt_Ack = '1') then
					FSM_InterruptClearVector	<= Arb_GrantVector;
					Interrupt_Ack							<= Arb_GrantVector;
					
					if (InterruptRequestsOpen = '1') then
						FSM_Arbitrate						<= '1';
						NextState								<= ST_INTERRUPT_PENDING;
					else
						NextState								<= ST_IDLE;
					end if;
				end if;
			
		end case;
	end process;
end;
