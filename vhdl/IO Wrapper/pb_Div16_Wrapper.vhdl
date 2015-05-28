-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Module:					Divider (32 bit) Wrapper for PicoBlaze
-- 
-- Authors:					Patrick Lehmann
--
-- Description:
-- ------------------------------------
--		TODO
--		
--
-- License:
-- ============================================================================
-- Copyright 2007-2014 Technische Universitaet Dresden - Germany,
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

LIBRARY IEEE;
USE			IEEE.STD_LOGIC_1164.ALL;
USE			IEEE.NUMERIC_STD.ALL;

LIBRARY PoC;
USE			PoC.utils.ALL;
USE			PoC.vectors.ALL;

LIBRARY	L_PicoBlaze;
USE			L_PicoBlaze.pb.ALL;


ENTITY pb_Div16_Wrapper IS
	GENERIC (
		ADDRESS_MAPPING								: T_PB_ADDRESS_MAPPING
	);
	PORT (
		Clock													: IN	STD_LOGIC;
		Reset													: IN	STD_LOGIC;

		-- PicoBlaze interface
		Address												: IN	T_SLV_8;
		WriteStrobe										: IN	STD_LOGIC;
		WriteStrobe_K									: IN	STD_LOGIC;
		ReadStrobe										: IN	STD_LOGIC;
		DataIn												: IN	T_SLV_8;
		DataOut												: OUT	T_SLV_8;
		
		Interrupt											: OUT	STD_LOGIC;
		Interrupt_Ack									: IN	STD_LOGIC;
		Message												: OUT T_SLV_8
	);
END ENTITY;


ARCHITECTURE rtl OF pb_Div16_Wrapper IS
	CONSTANT REG_WO_A0					: STD_LOGIC_VECTOR(1 DOWNTO 0)			:= "00";
	CONSTANT REG_WO_A1					: STD_LOGIC_VECTOR(1 DOWNTO 0)			:= "01";
	CONSTANT REG_WO_B0					: STD_LOGIC_VECTOR(1 DOWNTO 0)			:= "10";
	CONSTANT REG_WO_B1					: STD_LOGIC_VECTOR(1 DOWNTO 0)			:= "11";
	CONSTANT REG_RO_R0					: STD_LOGIC_VECTOR(1 DOWNTO 0)			:= "00";
	CONSTANT REG_RO_R1					: STD_LOGIC_VECTOR(1 DOWNTO 0)			:= "01";
	CONSTANT REG_RO_STATUS			: STD_LOGIC_VECTOR(1 DOWNTO 0)			:= "10";
	
	SIGNAL AdrDec_we						: STD_LOGIC;
	SIGNAL AdrDec_re						: STD_LOGIC;
	SIGNAL AdrDec_WriteAddress	: T_SLV_8;
	SIGNAL AdrDec_ReadAddress		: T_SLV_8;
	SIGNAL AdrDec_Data					: T_SLV_8;
	
	SIGNAL Reg_Operand_a				: T_SLV_16							:= (OTHERS => '0');
	SIGNAL Reg_Operand_b				: T_SLV_16							:= (OTHERS => '0');
	SIGNAL Reg_Result						: T_SLV_16							:= (OTHERS => '0');
	
	SIGNAL Div_Start		: STD_LOGIC;
	SIGNAL Div_Start_d	: STD_LOGIC															:= '0';
	SIGNAL Div_Done			: STD_LOGIC;
	SIGNAL Div_Done_d		: STD_LOGIC															:= '0';
	SIGNAL Div_Done_re	: STD_LOGIC;
	SIGNAL Div_Result		: T_SLV_16;
	
BEGIN
	AdrDec : ENTITY L_PicoBlaze.PicoBlaze_AddressDecoder
		GENERIC MAP (
			ADDRESS_MAPPING						=> ADDRESS_MAPPING
		)
		PORT MAP (
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

	PROCESS(Clock)
	BEGIN
		IF rising_edge(Clock) THEN
			IF (Reset = '1') THEN
				Reg_Operand_A						<= (OTHERS => '0');
				Reg_Operand_B						<= (OTHERS => '0');
				Reg_Result							<= (OTHERS => '0');
			ELSE
				IF (AdrDec_we = '1') THEN
					CASE AdrDec_WriteAddress(1 DOWNTO 0) IS
						WHEN REG_WO_A0 =>		Reg_Operand_A(7 DOWNTO 0)		<= AdrDec_Data;
						WHEN REG_WO_A1 =>		Reg_Operand_A(15 DOWNTO 8)	<= AdrDec_Data;
						WHEN REG_WO_B0 =>		Reg_Operand_B(7 DOWNTO 0)		<= AdrDec_Data;
						WHEN REG_WO_B1 =>		Reg_Operand_B(15 DOWNTO 8)	<= AdrDec_Data;
						WHEN OTHERS =>			NULL;
					END CASE;
				ELSIF (Div_Done_re = '1') THEN
					Reg_Result		<= Div_Result;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	Div_Start		<= AdrDec_we AND to_sl(AdrDec_WriteAddress(1 DOWNTO 0) = REG_WO_B1);
	Div_Start_d	<= Div_Start	WHEN rising_edge(Clock);
	Div_Done_d	<= Div_Done		WHEN rising_edge(Clock);
	Div_Done_re	<= NOT Div_Done_d AND Div_Done;
	
	Div : ENTITY PoC.arith_div
		GENERIC MAP (
			N							<= 16,				-- Operand /Result bit widths
			RAPOW					<= 1,					-- Power of Radix used (2**RAPOW)
			REGISTERED		<= FALSE
		)
		PORT MAP (
			clk				=> Clock,
			rst				=> Reset,

			start			=> Div_Start_d,
			arg1			=> Reg_Operand_A,
			arg2			=> Reg_Operand_B,

			rdy				=> Div_Done,
			res				=> Div_Result
  );
	
	PROCESS(AdrDec_re, AdrDec_ReadAddress, Reg_Result, Div_Done_d)
		VARIABLE Reg_Result_slvv	: T_SLVV_8(1 DOWNTO 0);
	BEGIN
		Reg_Result_slvv	:= to_slvv_8(Reg_Result);
		DataOut					<= Reg_Result_slvv(to_index(AdrDec_ReadAddress(0 DOWNTO 0), Reg_Result_slvv'length - 1));
		
		IF (AdrDec_ReadAddress(1 DOWNTO 0) = REG_RO_STATUS) THEN
			DataOut				<= "0000000" & Div_Done_d;
		END IF;
	END PROCESS;

	Interrupt		<= Div_Done_re;
	Message			<= to_slv(0, Message'length);

END;
