-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Patrick Lehmann
-- 
-- Package:					VHDL package for component declarations, types and
--									functions assoziated to the L_PicoBlaze namespace
--
-- Description:
-- ------------------------------------
--		For detailed documentation see below.
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


use			STD.TextIO.all;

library	IEEE;
use			IEEE.NUMERIC_STD.all;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.STD_LOGIC_TEXTIO.all;

library	PoC;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.strings.all;

library	L_PicoBlaze;
use			L_PicoBlaze.pb.all;


package pb_Devices is

	-- ===========================================================================
	-- PicoBlaze device descriptions
	-- ===========================================================================
	-- Instruction ROM
	-- ---------------------------------------------------------------------------
	constant PB_DEV_ROM_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 =>	pb_CreateRegisterField("PageNumber", "PageNumber", 3)
	);
	
	constant PB_DEV_ROM : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("Instruction ROM"),
		DeviceShort =>	pb_ShortName("InstROM"),
		Registers =>		pb_ResizeVec(
			pb_CreateRegisterRW("PageNumber", 0, PB_DEV_ROM_FIELDS, "PageNumber", 5) &
			pb_CreateRegisterK("PageNumber", 0, PB_DEV_ROM_FIELDS, "PageNumber", 5)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_ROM_FIELDS),
		CreatesInterrupt =>		FALSE
	);
	
	-- InterruptController
	-- ---------------------------------------------------------------------------
	constant PB_DEV_INTERRUPT_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Interrupt Enable",			"IntEnable",	16),
		1 => pb_CreateWriteOnlyField("Interrupt Disable",			"IntDisable", 16),
		2 => pb_CreateReadOnlyField("Interrupt Enable Mask",	"IntMask", 		16),
		3 => pb_CreateReadOnlyField("Interrupt Source",				"IntSource",	 8)
	);
	
	constant PB_DEV_INTERRUPT : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("Interrupt Controller"),
		DeviceShort =>	pb_ShortName("IntC"),
		Registers =>		pb_ResizeVec(
			pb_CreateRegisterWK("IntEnable0",		0, PB_DEV_INTERRUPT_FIELDS, "IntEnable",	0) &
			pb_CreateRegisterWK("IntEnable1",		1, PB_DEV_INTERRUPT_FIELDS, "IntEnable",	8) &
			pb_CreateRegisterWK("IntDisable0",	2, PB_DEV_INTERRUPT_FIELDS, "IntDisable",	0) &
			pb_CreateRegisterWK("IntDisable1",	3, PB_DEV_INTERRUPT_FIELDS, "IntDisable",	8) &
			pb_CreateRegisterRO("IntMask0",			0, PB_DEV_INTERRUPT_FIELDS, "IntMask",		0) &
			pb_CreateRegisterRO("IntMask1",			1, PB_DEV_INTERRUPT_FIELDS, "IntMask",		8) &
			pb_CreateRegisterRO("IntSource",		2, PB_DEV_INTERRUPT_FIELDS, "IntSource",	0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_INTERRUPT_FIELDS),
		CreatesInterrupt =>		FALSE				-- it doesn't create interrupts for itself
	);

	-- Timer
	-- ---------------------------------------------------------------------------
	constant PB_DEV_TIMER_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Control",				"Control",	 8),
		1 => pb_CreateWriteOnlyField("Max Value",			"MaxValue",	16),
		2 => pb_CreateReadOnlyField("Current Value",	"CurValue",	16)
	);

	constant PB_DEV_TIMER : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("Timer"),
		DeviceShort =>	pb_ShortName("Timer"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("Control",		0, PB_DEV_TIMER_FIELDS, "Control",	0) &
				pb_CreateRegisterWO("MaxValue0",	2, PB_DEV_TIMER_FIELDS, "MaxValue",	0) &
				pb_CreateRegisterWO("MaxValue1",	3, PB_DEV_TIMER_FIELDS, "MaxValue",	8) &
				pb_CreateRegisterRO("CurValue0",	2, PB_DEV_TIMER_FIELDS, "CurValue",	0) &
				pb_CreateRegisterRO("CurValue1",	3, PB_DEV_TIMER_FIELDS, "CurValue",	8)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_TIMER_FIELDS),
		CreatesInterrupt =>		TRUE
	);

	-- Multiplier (16 bit)
	-- ---------------------------------------------------------------------------
	constant PB_DEV_MULTIPLIER16_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Operand A",	"OperandA",	16),
		1 => pb_CreateWriteOnlyField("Operand B",	"OperandB",	16),
		2 => pb_CreateReadOnlyField("Result R",		"Result",		32)
	);
	
	constant PB_DEV_MULTIPLIER16 : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("Multiplier (16 bit)"),
		DeviceShort =>	pb_ShortName("Mult16"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("OperandA0",	0, PB_DEV_MULTIPLIER16_FIELDS, "OperandA",	 0) &
				pb_CreateRegisterWO("OperandA1",	1, PB_DEV_MULTIPLIER16_FIELDS, "OperandA",	 8) &
				pb_CreateRegisterWO("OperandB0",	2, PB_DEV_MULTIPLIER16_FIELDS, "OperandB",	 0) &
				pb_CreateRegisterWO("OperandB1",	3, PB_DEV_MULTIPLIER16_FIELDS, "OperandB",	 8) &
				pb_CreateRegisterRO("Result0",		0, PB_DEV_MULTIPLIER16_FIELDS, "Result",		 0) &
				pb_CreateRegisterRO("Result1",		1, PB_DEV_MULTIPLIER16_FIELDS, "Result",		 8) &
				pb_CreateRegisterRO("Result2",		2, PB_DEV_MULTIPLIER16_FIELDS, "Result",		16) &
				pb_CreateRegisterRO("Result3",		3, PB_DEV_MULTIPLIER16_FIELDS, "Result",		24)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_MULTIPLIER16_FIELDS),
		CreatesInterrupt =>		FALSE
	);

	-- Divider (32 bit)
	-- ---------------------------------------------------------------------------
	constant PB_DEV_DIVIDER32_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Operand A",	"OperandA",	32),
		1 => pb_CreateWriteOnlyField("Operand B",	"OperandB",	32),
		2 => pb_CreateReadOnlyField("Result R",		"Result",		32),
		3 => pb_CreateReadOnlyField("Status",			"Status",		 8)
	);

	constant PB_DEV_DIVIDER32 : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("Divider (32 bit)"),
		DeviceShort =>	pb_ShortName("Div32"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("OperandA0",	0, PB_DEV_DIVIDER32_FIELDS, "OperandA",	 0) &
				pb_CreateRegisterWO("OperandA1",	1, PB_DEV_DIVIDER32_FIELDS, "OperandA",  8) &
				pb_CreateRegisterWO("OperandA2",	2, PB_DEV_DIVIDER32_FIELDS, "OperandA",	16) &
				pb_CreateRegisterWO("OperandA3",	3, PB_DEV_DIVIDER32_FIELDS, "OperandA",	24) &
				pb_CreateRegisterWO("OperandB0",	4, PB_DEV_DIVIDER32_FIELDS, "OperandB",	 0) &
				pb_CreateRegisterWO("OperandB1",	5, PB_DEV_DIVIDER32_FIELDS, "OperandB",	 8) &
				pb_CreateRegisterWO("OperandB2",	6, PB_DEV_DIVIDER32_FIELDS, "OperandB",	16) &
				pb_CreateRegisterWO("OperandB3",	7, PB_DEV_DIVIDER32_FIELDS, "OperandB",	24) &
				pb_CreateRegisterRO("Result0",		0, PB_DEV_DIVIDER32_FIELDS, "Result",		 0) &
				pb_CreateRegisterRO("Result1",		1, PB_DEV_DIVIDER32_FIELDS, "Result",		 8) &
				pb_CreateRegisterRO("Result2",		2, PB_DEV_DIVIDER32_FIELDS, "Result",		16) &
				pb_CreateRegisterRO("Result3",		3, PB_DEV_DIVIDER32_FIELDS, "Result",		24) &
				pb_CreateRegisterRO("Status",			4, PB_DEV_DIVIDER32_FIELDS, "Result",		 0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_DIVIDER32_FIELDS),
		CreatesInterrupt =>		TRUE
	);

	-- Scaler (40 bit)
	-- ---------------------------------------------------------------------------
	constant PB_DEV_SCALER40_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Operand A",			"OperandA", 40),
		1 => pb_CreateWriteOnlyField("Multiplicator",	"Mult",			 8),
		2 => pb_CreateWriteOnlyField("Divisor",				"Div",			 8),
		3 => pb_CreateWriteOnlyField("Command",				"Command",	 8),
		4 => pb_CreateReadOnlyField("Result R",				"Result",		40),
		5 => pb_CreateReadOnlyField("Status",					"Status",		 8)
	);

	constant PB_DEV_SCALER40 : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("Scaler (40 bit)"),
		DeviceShort =>	pb_ShortName("Scaler40"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("OperandA0",	0, PB_DEV_SCALER40_FIELDS, "OperandA",	0) &
				pb_CreateRegisterWO("OperandA1",	1, PB_DEV_SCALER40_FIELDS, "OperandA",	8) &
				pb_CreateRegisterWO("OperandA2",	2, PB_DEV_SCALER40_FIELDS, "OperandA",	16) &
				pb_CreateRegisterWO("OperandA3",	3, PB_DEV_SCALER40_FIELDS, "OperandA",	24) &
				pb_CreateRegisterWO("OperandA4",	4, PB_DEV_SCALER40_FIELDS, "OperandA",	32) &
				pb_CreateRegisterWO("Mult",				5, PB_DEV_SCALER40_FIELDS, "Mult",			0) &
				pb_CreateRegisterWO("Div",				6, PB_DEV_SCALER40_FIELDS, "Div",				0) &
				pb_CreateRegisterWO("Command",		7, PB_DEV_SCALER40_FIELDS, "Command",		0) &
				pb_CreateRegisterRO("Result0",		0, PB_DEV_SCALER40_FIELDS, "Result",		0) &
				pb_CreateRegisterRO("Result1",		1, PB_DEV_SCALER40_FIELDS, "Result",		8) &
				pb_CreateRegisterRO("Result2",		2, PB_DEV_SCALER40_FIELDS, "Result",		16) &
				pb_CreateRegisterRO("Result3",		3, PB_DEV_SCALER40_FIELDS, "Result",		24) &
				pb_CreateRegisterRO("Result4",		4, PB_DEV_SCALER40_FIELDS, "Result",		32) &
				pb_CreateRegisterRO("Status",			5, PB_DEV_SCALER40_FIELDS, "Status",		0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_SCALER40_FIELDS),
		CreatesInterrupt =>		TRUE
	);

	-- General Purpose I/O
	-- ---------------------------------------------------------------------------
	constant PB_DEV_GPIO_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateRegisterField("GPIO DataOut",				"DataOut",		8),
		1 => pb_CreateReadOnlyField("GPIO DataIn",				"DataIn",			8),
		2 => pb_CreateWriteOnlyField("Interrupt Enable",	"IntEnable",	8)
	);

	constant PB_DEV_GPIO : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("General Purpose I/O"),
		DeviceShort =>	pb_ShortName("GPIO"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterRW("DataOut",		0, PB_DEV_GPIO_FIELDS, "DataOut",		0) &
				pb_CreateRegisterRO("DataIn",			1, PB_DEV_GPIO_FIELDS, "DataIn",		0) &
				pb_CreateRegisterWO("IntEnable",	1, PB_DEV_GPIO_FIELDS, "IntEnable",	0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_GPIO_FIELDS),
		CreatesInterrupt =>		TRUE
	);

	-- Bit Banging I/O
	-- ---------------------------------------------------------------------------
	constant PB_DEV_BITBANGING_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateRegisterField("BBIO DataOut",				"DataOut",		8),
		1 => pb_CreateReadOnlyField("BBIO DataIn",				"DataIn",			8),
		2 => pb_CreateWriteOnlyField("Interrupt Enable",	"IntEnable",	8)
	);

	constant PB_DEV_BITBANGING : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("Bit Banging I/O"),
		DeviceShort =>	pb_ShortName("BBIO"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterRW("DataOut",		0, PB_DEV_GPIO_FIELDS, "DataOut",		0) &
				pb_CreateRegisterRO("DataIn",			1, PB_DEV_GPIO_FIELDS, "DataIn",		0) &
				pb_CreateRegisterWO("IntEnable",	1, PB_DEV_GPIO_FIELDS, "IntEnable",	0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_BITBANGING_FIELDS),
		CreatesInterrupt =>		FALSE
	);

	-- LC-Display
	-- ---------------------------------------------------------------------------
	constant PB_DEV_LCDISPLAY_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Command",	"Command",	8),
		1 => pb_CreateWriteOnlyField("Data",		"Data",			8)
	);

	constant PB_DEV_LCDISPLAY : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("LC Display Controller"),
		DeviceShort =>	pb_ShortName("LCD"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("Command",	0, PB_DEV_LCDISPLAY_FIELDS, "Command",	0) &
				pb_CreateRegisterWO("DataOut",	1, PB_DEV_LCDISPLAY_FIELDS, "Data",			0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_LCDISPLAY_FIELDS),
		CreatesInterrupt =>		FALSE
	);

	-- UART
	-- ---------------------------------------------------------------------------
	constant PB_DEV_UART_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Command",				"Command",	8),
		1 => pb_CreateReadOnlyField("Status",					"Status",		8),
		2 => pb_CreateWriteOnlyField("FifO DataOut",	"DataOut",	8),
		3 => pb_CreateReadOnlyField("FifO DataIn",		"DataIn",		8)
	);

	constant PB_DEV_UART : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("UART"),
		DeviceShort =>	pb_ShortName("UART"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("Command",	0, PB_DEV_UART_FIELDS, "Command",	0) &
				pb_CreateRegisterRO("Status",		0, PB_DEV_UART_FIELDS, "Status",	0) &
				pb_CreateRegisterWO("DataOut",	1, PB_DEV_UART_FIELDS, "DataOut",	0) &
				pb_CreateRegisterRO("DataIn",		1, PB_DEV_UART_FIELDS, "DataIn",	0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_UART_FIELDS),
		CreatesInterrupt =>		TRUE
	);

	-- UARTStream
	-- ---------------------------------------------------------------------------
	constant PB_DEV_UARTSTREAM_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateRegisterField("Dummy",			"Dummy",	8)
	);

--	constant PB_DEV_UARTSTREAM : T_PB_DEVICE := (
--		DeviceName =>		pb_LongName("UARTStream"),
--		DeviceShort =>	pb_ShortName("UARTStream"),
--		Registers =>		pb_ResizeVec((
--				0 => pb_CreateRegister("Dummy",		0, PB_DEV_UARTSTREAM_FIELDS, "Dummy",	0))
--			),
--		RegisterFields =>			pb_ResizeVec(PB_DEV_UARTSTREAM_FIELDS),
--		CreatesInterrupt =>		TRUE
--	);

	-- I2C Controller
	-- ---------------------------------------------------------------------------
	constant PB_DEV_IICCONTROLLER_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Command",							"Command",				8),
		1 => pb_CreateReadOnlyField("Status",								"Status",					8),
		2 => pb_CreateRegisterField("Device Address [7:1]",	"DeviceAddress",	8),
		3 => pb_CreateRegisterField("RX Length [3:0]",			"RXLength",				8),
		4 => pb_CreateWriteOnlyField("TX_FifO",							"TX_FifO",				8),
		5 => pb_CreateReadOnlyField("RX_FifO",							"RX_FifO",				8)
	);

	constant PB_DEV_IICCONTROLLER : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("I2C Controller"),
		DeviceShort =>	pb_ShortName("IICCtrl"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("Command",				0, PB_DEV_IICCONTROLLER_FIELDS, "Command",				0) &
				pb_CreateRegisterRO("Status",					0, PB_DEV_IICCONTROLLER_FIELDS, "Status",					0) &
				pb_CreateRegisterRW("DeviceAddress",	1, PB_DEV_IICCONTROLLER_FIELDS, "DeviceAddress",	0) &
				pb_CreateRegisterRW("Length",					2, PB_DEV_IICCONTROLLER_FIELDS, "RXLength",				0) &
				pb_CreateRegisterWO("TX_FifO",				3, PB_DEV_IICCONTROLLER_FIELDS, "TX_FifO",				0) &
				pb_CreateRegisterRO("RX_FifO",				3, PB_DEV_IICCONTROLLER_FIELDS, "RX_FifO",				0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_IICCONTROLLER_FIELDS),
		CreatesInterrupt =>		TRUE
	);

	-- MDIO Controller
	-- ---------------------------------------------------------------------------
	constant PB_DEV_MDIOCONTROLLER_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateRegisterField("Dummy",			"Dummy",	8)
	);

--	constant PB_DEV_MDIOCONTROLLER : T_PB_DEVICE := (
--		DeviceName =>		pb_LongName("MDIO Controller"),
--		DeviceShort =>	pb_ShortName("MDIOCtrl"),
--		Registers =>		pb_ResizeVec((
--				0 => pb_CreateRegister("Dummy",		0, PB_DEV_MDIOCONTROLLER_FIELDS, "Dummy",	0))
--			),
--		RegisterFields =>			pb_ResizeVec(PB_DEV_MDIOCONTROLLER_FIELDS),
--		CreatesInterrupt =>		FALSE
--	);

	-- Dynamic Reconfiguration Port
	-- ---------------------------------------------------------------------------
	constant PB_DEV_DRP_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Command",							"Command",		 8),
		1 => pb_CreateReadOnlyField("Status",								"Status",			 8),
		2 => pb_CreateRegisterField("Address",							"Address",		 8),
		3 => pb_CreateRegisterField("Data",									"Data",				16),
		4 => pb_CreateWriteOnlyField("Mask Register Set",		"MaskRegSet",	16),
		5 => pb_CreateWriteOnlyField("Mask Register Clear",	"MaskRegClr",	16)
	);

	constant PB_DEV_DRP : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("PicoBlaze to DRP Adapter"),
		DeviceShort =>	pb_ShortName("DRP"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("Command",			0, PB_DEV_DRP_FIELDS, "Command",		0) &
				pb_CreateRegisterRO("Status",				0, PB_DEV_DRP_FIELDS, "Status",			0) &
				pb_CreateRegisterRW("Address",			1, PB_DEV_DRP_FIELDS, "Address",		0) &
				pb_CreateRegisterRW("Data0",				2, PB_DEV_DRP_FIELDS, "Data",				0) &
				pb_CreateRegisterRW("Data1",				3, PB_DEV_DRP_FIELDS, "Data",				0) &
				pb_CreateRegisterWO("MaskRegSet0",	4, PB_DEV_DRP_FIELDS, "MaskRegSet",	0) &
				pb_CreateRegisterWO("MaskRegSet1",	5, PB_DEV_DRP_FIELDS, "MaskRegSet",	0) &
				pb_CreateRegisterWO("MaskRegClr0",	6, PB_DEV_DRP_FIELDS, "MaskRegClr",	0) &
				pb_CreateRegisterWO("MaskRegClr1",	7, PB_DEV_DRP_FIELDS, "MaskRegClr",	0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_DRP_FIELDS),
		CreatesInterrupt =>		FALSE
	);

	-- Frequency Measurement
	-- ---------------------------------------------------------------------------
	constant PB_DEV_FREQM_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Command",						"Command",			 8),
		1 => pb_CreateReadOnlyField("Frequency Counter",	"FreqCntValue",	24),
		2 => pb_CreateReadOnlyField("Status",							"Status",				 8)
	);

	constant PB_DEV_FREQM : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("FrequencyMeasurement"),
		DeviceShort =>	pb_ShortName("FreqM"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("Command",				0, PB_DEV_FREQM_FIELDS, "Command",			0) &
				pb_CreateRegisterRO("FreqCntValue0",	0, PB_DEV_FREQM_FIELDS, "FreqCntValue",	0) &
				pb_CreateRegisterRO("FreqCntValue1",	1, PB_DEV_FREQM_FIELDS, "FreqCntValue",	0) &
				pb_CreateRegisterRO("FreqCntValue2",	2, PB_DEV_FREQM_FIELDS, "FreqCntValue",	0) &
				pb_CreateRegisterRO("Status",					3, PB_DEV_FREQM_FIELDS, "Status",				0)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_FREQM_FIELDS),
		CreatesInterrupt =>		FALSE
	);

	-- BCD Counter
	-- ---------------------------------------------------------------------------
	constant PB_DEV_BCDCOUNTER_FIELDS : T_PB_REGISTER_FIELD_VECTOR := (
		0 => pb_CreateWriteOnlyField("Command",	"Command",	 8),
		1 => pb_CreateReadOnlyField("Value",		"Value",		32)
	);

	constant PB_DEV_BCDCOUNTER : T_PB_DEVICE := (
		DeviceName =>		pb_LongName("BCD Counter"),
		DeviceShort =>	pb_ShortName("BCDCnt"),
		Registers =>		pb_ResizeVec(
				pb_CreateRegisterWO("Command",	0, PB_DEV_BCDCOUNTER_FIELDS, "Command",	0) &
				pb_CreateRegisterRO("Value0",		0, PB_DEV_BCDCOUNTER_FIELDS, "Value",	0) &
				pb_CreateRegisterRO("Value1",		1, PB_DEV_BCDCOUNTER_FIELDS, "Value",	8) &
				pb_CreateRegisterRO("Value2",		2, PB_DEV_BCDCOUNTER_FIELDS, "Value",	16) &
				pb_CreateRegisterRO("Value3",		3, PB_DEV_BCDCOUNTER_FIELDS, "Value",	24)),
		RegisterFields =>			pb_ResizeVec(PB_DEV_BCDCOUNTER_FIELDS),
		CreatesInterrupt =>		FALSE
	);

end package;


package body pb_Devices is

end package body;
