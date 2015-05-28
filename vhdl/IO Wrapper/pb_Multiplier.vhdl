-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Patrick Lehmann
-- 
-- Module:					Multiplier Wrapper for PicoBlaze
--
-- Description:
-- ------------------------------------
--		TODO
--		
--
-- License:
-- ============================================================================
-- Copyright 2007-2015 Technische Universitaet Dresden - Germany,
--										 Chair for VLSI-Design, Diagnostics and Architecture
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
use			PoC.utils.all;
use			PoC.vectors.all;

library	L_PicoBlaze;
use			L_PicoBlaze.pb.all;


entity pb_Multiplier_Wrapper is
	generic (
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
		Message												: out T_SLV_8
	);
end entity;


architecture rtl of pb_Multiplier_Wrapper is
	constant REG_WO_A0					: STD_LOGIC_VECTOR(1 downto 0)			:= "00";
	constant REG_WO_A1					: STD_LOGIC_VECTOR(1 downto 0)			:= "01";
	constant REG_WO_B0					: STD_LOGIC_VECTOR(1 downto 0)			:= "10";
	constant REG_WO_B1					: STD_LOGIC_VECTOR(1 downto 0)			:= "11";
	constant REG_RO_R0					: STD_LOGIC_VECTOR(1 downto 0)			:= "00";
	constant REG_RO_R1					: STD_LOGIC_VECTOR(1 downto 0)			:= "01";
	constant REG_RO_R2					: STD_LOGIC_VECTOR(1 downto 0)			:= "10";
	constant REG_RO_R3					: STD_LOGIC_VECTOR(1 downto 0)			:= "11";
	
	signal AdrDec_we						: STD_LOGIC;
	signal AdrDec_re						: STD_LOGIC;
	signal AdrDec_WriteAddress	: T_SLV_8;
	signal AdrDec_ReadAddress		: T_SLV_8;
	signal AdrDec_Data					: T_SLV_8;
	
	signal Reg_Operand_a				: T_SLV_16							:= (others => '0');
	signal Reg_Operand_b				: T_SLV_16							:= (others => '0');
	signal Reg_Result						: T_SLV_32							:= (others => '0');
	
	signal Reg_Result_slvv			: T_SLVV_8(3 downto 0);
	
begin
	AdrDec : entity L_PicoBlaze.PicoBlaze_AddressDecoder
		generic map (
			DEVICE_INSTANCE						=> DEVICE_INSTANCE
		)
		port map (
			Clock											=> Clock,
			Reset											=> Reset,

			-- PicoBlaze interface
			In_WriteStrobe						=> WriteStrobe,
			In_WriteStrobe_K					=> WriteStrobe_K,
			In_ReadStrobe							=> ReadStrobe,
			In_Address								=> Address,
			In_Data										=> DataIn,
			Out_WriteStrobe						=> AdrDec_we,
			Out_ReadStrobe						=> AdrDec_re,
			Out_WriteAddress					=> AdrDec_WriteAddress,
			Out_ReadAddress						=> AdrDec_ReadAddress,
			Out_Data									=> AdrDec_Data
		);

	process(Clock)
	begin
		if rising_edge(Clock) then
			if (Reset = '1') then
				Reg_Operand_A						<= (others => '0');
				Reg_Operand_B						<= (others => '0');
				Reg_Result							<= (others => '0');
			else
				if (AdrDec_we = '1') then
					case AdrDec_WriteAddress(1 downto 0) is
						when REG_WO_A0 =>		Reg_Operand_A(7 downto 0)		<= AdrDec_Data;
						when REG_WO_A1 =>		Reg_Operand_A(15 downto 8)	<= AdrDec_Data;
						when REG_WO_B0 =>		Reg_Operand_B(7 downto 0)		<= AdrDec_Data;
						when reg_wo_b1 =>		reg_operand_b(15 downto 8)	<= adrdec_data;
						when others =>			null;
					end case;
				end if;
				
				Reg_Result	<= std_logic_vector(unsigned(Reg_Operand_A) * unsigned(Reg_Operand_B));
			end if;
		end if;
	end process;
	
	Reg_Result_slvv	<= to_slvv_8(Reg_Result);
	DataOut					<= Reg_Result_slvv(to_index(AdrDec_ReadAddress(1 downto 0)));
	
	Interrupt		<= '0';
	Message			<= x"00";
end;
