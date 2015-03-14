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

library IEEE;
use			IEEE.NUMERIC_STD.all;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.STD_LOGIC_TEXTIO.all;

library	PoC;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.strings.all;


package pb is

	subtype T_PB_ADDRESS			is STD_LOGIC_VECTOR(11 downto 0);
	subtype T_PB_INSTRUCTION	is STD_LOGIC_VECTOR(17 downto 0);

	-- PicoBlaze I/O bus
	type T_PB_IOBUS_PB_DEV is record
		PortID					: T_SLV_8;
		Data						: T_SLV_8;
		WriteStrobe			: STD_LOGIC;
		WriteStrobe_K		: STD_LOGIC;
		ReadStrobe			: STD_LOGIC;
		Interrupt_Ack		: STD_LOGIC;
	end record;

	type T_PB_IOBUS_DEV_PB is record
		Data						: T_SLV_8;
		Interrupt				: STD_LOGIC;
		Message					: T_SLV_8;
	end record;

	type T_PB_IOBUS_PB_DEV_VECTOR	is array(NATURAL range <>) of T_PB_IOBUS_PB_DEV;
	type T_PB_IOBUS_DEV_PB_VECTOR	is array(NATURAL range <>) of T_PB_IOBUS_DEV_PB;
	
	constant T_PB_IOBUS_PB_DEV_Z : T_PB_IOBUS_PB_DEV := ((others => 'Z'), (others => 'Z'), 'Z', 'Z', 'Z', 'Z');
	constant T_PB_IOBUS_DEV_PB_Z : T_PB_IOBUS_DEV_PB := ((others => 'Z'), 'Z', (others => 'Z'));

	-- private functions (must be declared public to be useable in public constants)
	-- ===========================================================================
	constant C_PB_MAX_LONGNAME_LENGTH			: POSITIVE				:= 64;
	constant C_PB_MAX_SHORTNAME_LENGTH		: POSITIVE				:= 16;

	subtype T_PB_LONGNAME		is STRING(1 to C_PB_MAX_LONGNAME_LENGTH);
	subtype T_PB_SHORTNAME	is STRING(1 to C_PB_MAX_SHORTNAME_LENGTH);
	
	constant C_PB_LONGNAME_EMPTY	: T_PB_LONGNAME		:= (others => NUL);
	constant C_PB_SHORTNAME_EMPTY	: T_PB_SHORTNAME	:= (others => NUL);
	
	function pb_LongName(name : string)		return T_PB_LONGNAME ;
	function pb_ShortName(name : string)	return T_PB_SHORTNAME;
	
	-- PicoBlaze device description
	constant C_PB_MAX_REGISTER_FIELDS					: POSITIVE				:= 17;
	constant C_PB_MAX_REGISTERS								: POSITIVE				:= 18;
	constant C_PB_MAX_REGISTER_FIELD_MAPPINGS	: POSITIVE				:= 19;
	constant C_PB_MAX_MAPPINGS								: POSITIVE				:= 20;
	constant C_PB_MAX_DEVICES									: POSITIVE				:= 32;
	constant C_PB_MAX_BUSSES									: POSITIVE				:= 16;
	
	subtype T_PB_REGISTER_FIELD_INDEX					is NATURAL range 0 to (C_PB_MAX_REGISTER_FIELDS - 1);
	subtype T_PB_REGISTER_INDEX								is NATURAL range 0 to (C_PB_MAX_REGISTERS - 1);
	subtype T_PB_REGISTER_FIELD_MAPPING_INDEX	is NATURAL range 0 to (C_PB_MAX_REGISTER_FIELD_MAPPINGS - 1);
	subtype T_PB_PORTNUMBER_MAPPING_INDEX			is NATURAL range 0 to (C_PB_MAX_MAPPINGS - 1);
	subtype T_PB_DEVICE_INSTANCE_INDEX				is NATURAL range 0 to (C_PB_MAX_DEVICES - 1);
	subtype T_PB_BUS_INDEX										is NATURAL range 0 to (C_PB_MAX_BUSSES - 1);


	type T_PB_REGISTER_FIELD_KIND is (PB_REGISTER_FIELD_KIND_READ, PB_REGISTER_FIELD_KIND_WRITE, PB_REGISTER_FIELD_KIND_READWRITE);
	
	type T_PB_REGISTER_FIELD is record
		FieldName					: T_PB_LONGNAME;
		FieldShort				: T_PB_SHORTNAME;
		Length						: T_UINT_8;
		AutoClear					: BOOLEAN;
		FieldKind					: T_PB_REGISTER_FIELD_KIND;
	end record;
	
	constant C_PB_REGISTER_FIELD_EMPTY : T_PB_REGISTER_FIELD := (
		FieldName =>	C_PB_LONGNAME_EMPTY,
		FieldShort =>	C_PB_SHORTNAME_EMPTY,
		Length =>			0,
		AutoClear =>	FALSE,
		FieldKind =>	PB_REGISTER_FIELD_KIND_READ
	);
	
	type T_PB_REGISTER_FIELD_VECTOR is array(NATURAL range <>) of T_PB_REGISTER_FIELD;
	type T_PB_REGISTER_FIELD_MAPPING_KIND		is (PB_REGISTER_FIELD_MAPPING_KIND_READ, PB_REGISTER_FIELD_MAPPING_KIND_WRITE, PB_REGISTER_FIELD_MAPPING_KIND_WRITEK);
	
	type T_PB_REGISTER_FIELD_MAPPING is record
		FieldID			: T_UINT_8;
		Start				: T_UINT_8;
		Length			: T_UINT_8;
		MappingKind	: T_PB_REGISTER_FIELD_MAPPING_KIND;
	end record;
	
	type T_PB_REGISTER_FIELD_MAPPING_VECTOR is array(NATURAL range <>) of T_PB_REGISTER_FIELD_MAPPING;
	
	constant C_PB_REGISTER_FIELD_MAPPING_EMPTY : T_PB_REGISTER_FIELD_MAPPING := (
		FieldID =>			255,
		Start =>				0,
		Length =>				0,
		MappingKind =>	PB_REGISTER_FIELD_MAPPING_KIND_READ
	);
	
	type T_PB_REGISTER_KIND is (PB_REGISTER_KIND_READ, PB_REGISTER_KIND_WRITE, PB_REGISTER_KIND_READWRITE, PB_REGISTER_KIND_WRITEK);
	
	type T_PB_REGISTER is record
		RegisterName			: T_PB_LONGNAME;
		RegisterShort			: T_PB_SHORTNAME;
		RegisterNumber		: T_UINT_8;
		RegisterKind			: T_PB_REGISTER_KIND;
		FieldMappings			: T_PB_REGISTER_FIELD_MAPPING_VECTOR(T_PB_REGISTER_FIELD_MAPPING_INDEX);
	end record;
	
	constant C_PB_REGISTER_EMPTY : T_PB_REGISTER := (
		RegisterName =>		C_PB_LONGNAME_EMPTY,
		RegisterShort =>	C_PB_SHORTNAME_EMPTY,
		RegisterNumber => 255,
		RegisterKind =>		PB_REGISTER_KIND_READ,
		FieldMappings =>	(others => C_PB_REGISTER_FIELD_MAPPING_EMPTY)
	);
	
	type T_PB_REGISTER_VECTOR is array(NATURAL range <>) of T_PB_REGISTER;
	
	type T_PB_DEVICE is record
		DeviceName				: T_PB_LONGNAME;
		DeviceShort				: T_PB_SHORTNAME;
		Registers					: T_PB_REGISTER_VECTOR(T_PB_REGISTER_INDEX);
		RegisterFields		: T_PB_REGISTER_FIELD_VECTOR(T_PB_REGISTER_FIELD_INDEX);
		CreatesInterrupt	: BOOLEAN;
	end record;
	
	type T_PB_DEVICE_VECTOR is array (NATURAL range <>) of T_PB_DEVICE;
	
	constant C_PB_DEVICE_EMPTY : T_PB_DEVICE := (
		DeviceName =>					C_PB_LONGNAME_EMPTY,
		DeviceShort =>				C_PB_SHORTNAME_EMPTY,
		Registers =>					(others => C_PB_REGISTER_EMPTY),
		RegisterFields =>			(others => C_PB_REGISTER_FIELD_EMPTY),
		CreatesInterrupt =>		FALSE
	);
	
	subtype T_PB_BUSAFFILATION						is BIT_VECTOR(15 downto 0);
	
	constant C_PB_BUSAFFILATION_NONE			: T_PB_BUSAFFILATION		:= x"0001";
	constant C_PB_BUSAFFILATION_ANY				: T_PB_BUSAFFILATION		:= x"0002";
	constant C_PB_BUSAFFILATION_INTERN		: T_PB_BUSAFFILATION		:= x"0004";
	constant C_PB_BUSAFFILATION_EXTERN		: T_PB_BUSAFFILATION		:= x"0008";
	constant C_PB_BUS_INTERN							: T_PB_BUSAFFILATION		:= C_PB_BUSAFFILATION_INTERN or C_PB_BUSAFFILATION_ANY;
	constant C_PB_BUS_EXTERN							: T_PB_BUSAFFILATION		:= C_PB_BUSAFFILATION_EXTERN or C_PB_BUSAFFILATION_ANY;

	type T_PB_MAPPING_KIND is (PB_MAPPING_KIND_EMPTY, PB_MAPPING_KIND_WRITE, PB_MAPPING_KIND_WRITEK, PB_MAPPING_KIND_READ);

	type T_PB_PORTNUMBER_MAPPING is record
		PortNumber	: T_UINT_8;
		RegID				: T_UINT_8;
		MappingKind	: T_PB_MAPPING_KIND;
	end record;
	
	type T_PB_PORTNUMBER_MAPPING_VECTOR		is array(NATURAL range <>) of T_PB_PORTNUMBER_MAPPING;

	constant C_PB_PORTNUMBER_MAPPING_EMPTY : T_PB_PORTNUMBER_MAPPING := (
		PortNumber =>		0,
		RegID =>				0,
		MappingKind =>	PB_MAPPING_KIND_EMPTY
	);

	type T_PB_DEVICE_INSTANCE is record
		DeviceName				: T_PB_LONGNAME;
		DeviceShort				: T_PB_SHORTNAME;
		Device						: T_PB_DEVICE;
		BusShort					: T_PB_SHORTNAME;
		Mappings					: T_PB_PORTNUMBER_MAPPING_VECTOR(T_PB_PORTNUMBER_MAPPING_INDEX);
	end record;

	type T_PB_DEVICE_INSTANCE_VECTOR	is array (NATURAL range <>) of T_PB_DEVICE_INSTANCE;

	constant C_PB_DEVICE_INSTANCE_EMPTY : T_PB_DEVICE_INSTANCE := (
		DeviceName =>		C_PB_LONGNAME_EMPTY,
		DeviceShort =>	C_PB_SHORTNAME_EMPTY,
		Device =>				C_PB_DEVICE_EMPTY,
		BusShort =>			C_PB_SHORTNAME_EMPTY,
		Mappings =>			(others => C_PB_PORTNUMBER_MAPPING_EMPTY)
	);

	function pb_CreateReadonlyField(NameLong : STRING; NameShort : STRING; Length : T_UINT_8; AutoClear : BOOLEAN := FALSE) return T_PB_REGISTER_FIELD;
	function pb_CreateWriteonlyField(NameLong : STRING; NameShort : STRING; Length : T_UINT_8; AutoClear : BOOLEAN := FALSE) return T_PB_REGISTER_FIELD;
	function pb_CreateRegisterField(NameLong : STRING; NameShort : STRING; Length : T_UINT_8; AutoClear : BOOLEAN := FALSE) return T_PB_REGISTER_FIELD;
	function pb_GetRegisterFieldID(RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; NameShort : STRING) return T_UINT_8;
	function pb_GetRegisterField(RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; NameShort : STRING) return T_PB_REGISTER_FIELD;
	
	function pb_CreateRegisterRO(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER;
	function pb_CreateRegisterRW(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER_VECTOR;
	function pb_CreateRegisterWO(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER;
	function pb_CreateRegisterK(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER;
	function pb_CreateRegisterWK(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER_VECTOR;
	function pb_CreateDeviceInstance(Device : T_PB_DEVICE;																				BusShort : STRING; Start : T_UINT_8) return T_PB_DEVICE_INSTANCE;
	function pb_CreateDeviceInstance(Device : T_PB_DEVICE; InstanceNumber : T_UINT_8;							BusShort : STRING; Start : T_UINT_8) return T_PB_DEVICE_INSTANCE;
	function pb_CreateDeviceInstance(Device : T_PB_DEVICE; NameLong : STRING; NameShort : STRING;	BusShort : STRING; Start : T_UINT_8) return T_PB_DEVICE_INSTANCE;
	function pb_GetDeviceInstance(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR; NameShort : STRING) return T_PB_DEVICE_INSTANCE;

	subtype T_PB_BUSID				is NATURAL range 0 to 31;
	subtype T_PB_DEVICEID			is NATURAL range 0 to 127;
	type T_PB_BUSID_VECTOR		is array (NATURAL range <>) of T_PB_BUSID;
	type T_PB_DEVICEID_VECTOR	is array (NATURAL range <>) of T_PB_DEVICEID;

	type T_PB_BUS is record
		BusName						: T_PB_LONGNAME;
		BusShort					: T_PB_SHORTNAME;
		SuperBusShort			: T_PB_SHORTNAME;
		SuperBusID				: T_PB_BUSID;
		SubBusses					:	T_PB_BUSID_VECTOR(0 to 7);
		SubBusCount				: NATURAL range 0 to 8;
		Devices						: T_PB_DEVICEID_VECTOR(0 to 31);
		DeviceCount				: NATURAL range 0 to 32;
		TotalDeviceCount	: T_UINT_8;
	end record;
	
	type T_PB_BUS_VECTOR is array (NATURAL range <>) of T_PB_BUS;

	constant C_PB_BUS_EMPTY : T_PB_BUS := (
		BusName =>					C_PB_LONGNAME_EMPTY,
		BusShort =>					C_PB_SHORTNAME_EMPTY,
		SuperBusShort =>		C_PB_SHORTNAME_EMPTY,
		SuperBusID =>				0,
		SubBusses =>				(others => 0),
		SubBusCount =>			0,
		Devices =>					(others => 0),
		DeviceCount =>			0,
		TotalDeviceCount =>	0
	);

	function pb_CreateBus(BusName : STRING; BusShort : STRING; SuperBusShort : STRING) return T_PB_BUS;
	function pb_ConnectBusses(Busses : T_PB_BUS_VECTOR) return T_PB_BUS_VECTOR;

	constant C_PB_BUSSES : T_PB_BUS_VECTOR := (
		0 => pb_CreateBus("Any",		"Any",		""),
		1 => pb_CreateBus("Intern",	"Intern",	"Any"),
		2 => pb_CreateBus("Extern",	"Extern",	"Any")
	);

	type T_PB_SYSTEM is record
		DeviceInstances			: T_PB_DEVICE_INSTANCE_VECTOR(T_PB_DEVICE_INSTANCE_INDEX);
		DeviceInstanceCount	: T_UINT_8;
		Busses							: T_PB_BUS_VECTOR(T_PB_BUS_INDEX);
		BusCount						: T_UINT_8;
	end record;

	function pb_CreateSystem(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR; Busses : T_PB_BUS_VECTOR) return T_PB_SYSTEM;
	function pb_GetDeviceInstance(System : T_PB_SYSTEM; NameShort : STRING) return T_PB_DEVICE_INSTANCE;


	function pb_Resize(RegisterMapping : T_PB_REGISTER_FIELD_MAPPING; Size : NATURAL := 0) return T_PB_REGISTER_FIELD_MAPPING_VECTOR;
	function pb_Resize(RegisterField : T_PB_REGISTER_FIELD; Size : NATURAL := 0) return T_PB_REGISTER_FIELD_VECTOR;
	function pb_Resize(Reg : T_PB_REGISTER; Size : NATURAL := 0) return T_PB_REGISTER_VECTOR;
	
	function pb_ResizeVec(RegisterMappings : T_PB_REGISTER_FIELD_MAPPING_VECTOR; Size : NATURAL := 0) return T_PB_REGISTER_FIELD_MAPPING_VECTOR;
	function pb_ResizeVec(RegisterFields : T_PB_REGISTER_FIELD_VECTOR; Size : NATURAL := 0) return T_PB_REGISTER_FIELD_VECTOR;
	function pb_ResizeVec(Registers : T_PB_REGISTER_VECTOR; Size : NATURAL := 0) return T_PB_REGISTER_VECTOR;
	function pb_ResizeVec(Busses : T_PB_BUS_VECTOR; Size : NATURAL := 0) return T_PB_BUS_VECTOR;
	function pb_ResizeVec(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR; Size : NATURAL := 0) return T_PB_DEVICE_INSTANCE_VECTOR;
	
	-- PicoBlaze interrupt functions
	function pb_GetInterruptCount(System : T_PB_SYSTEM) return NATURAL;
	function pb_GetInterruptPortIndex(System : T_PB_SYSTEM; DeviceShort : STRING) return NATURAL;
	function pb_GetInterruptVector(PicoBlazeBus : T_PB_IOBUS_DEV_PB_VECTOR; System : T_PB_SYSTEM) return STD_LOGIC_VECTOR;
	function pb_GetInterruptMessages(PicoBlazeBus : T_PB_IOBUS_DEV_PB_VECTOR; System : T_PB_SYSTEM) return T_SLVV_8;
	procedure pb_AssignInterruptAck(signal Output : inout T_PB_IOBUS_PB_DEV_VECTOR; Input : STD_LOGIC_VECTOR; System : T_PB_SYSTEM);
	
	-- PicoBlaze bus functions
	function pb_GetBusIndex(System : T_PB_SYSTEM; DeviceShort : STRING) return NATURAL;
	function pb_GetBusWidth(System : T_PB_SYSTEM; BusShort : STRING) return NATURAL;
	function pb_GetSubOrdinateBus(Input : T_PB_IOBUS_PB_DEV_VECTOR; System : T_PB_SYSTEM; BusShort : STRING) return T_PB_IOBUS_PB_DEV_VECTOR;
	procedure pb_AssignSubOrdinateBus(signal Output : inout T_PB_IOBUS_DEV_PB_VECTOR; Input : T_PB_IOBUS_DEV_PB_VECTOR; System : T_PB_SYSTEM; BusShort : STRING);
	
	impure function pb_ExportAddressMapping(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR; Name : STRING; psmFileName : STRING; tokenFileName : STRING) return BOOLEAN;
end pb;


package body pb is
	-- private functions (must be declared before public functions)
	-- ===========================================================================
	function pb_LongName(name : STRING) return T_PB_LONGNAME is
	begin
		return resize(name, T_PB_LONGNAME'length);
	end function;
	
	function pb_ShortName(name : STRING) return T_PB_SHORTNAME is
	begin
		return resize(name, T_PB_SHORTNAME'length);
	end function;

	-- public functions
	-- ===========================================================================
	function pb_CreateReadonlyField(NameLong : STRING; NameShort : STRING; Length : T_UINT_8; AutoClear : BOOLEAN := FALSE) return T_PB_REGISTER_FIELD is
		variable Result : T_PB_REGISTER_FIELD;
	begin
		Result.FieldName	:= pb_LongName(NameLong);
		Result.FieldShort	:= pb_ShortName(NameShort);
		Result.Length			:= Length;
		Result.FieldKind	:= PB_REGISTER_FIELD_KIND_READ;
		Result.AutoClear	:= AutoClear;
		return Result;
	end function;
	
	function pb_CreateWriteonlyField(NameLong : STRING; NameShort : STRING; Length : T_UINT_8; AutoClear : BOOLEAN := FALSE) return T_PB_REGISTER_FIELD is
		variable Result : T_PB_REGISTER_FIELD;
	begin
		Result.FieldName	:= pb_LongName(NameLong);
		Result.FieldShort	:= pb_ShortName(NameShort);
		Result.Length			:= Length;
		Result.FieldKind	:= PB_REGISTER_FIELD_KIND_WRITE;
		Result.AutoClear	:= AutoClear;
		return Result;
	end function;
	
	function pb_CreateRegisterField(NameLong : STRING; NameShort : STRING; Length : T_UINT_8; AutoClear : BOOLEAN := FALSE) return T_PB_REGISTER_FIELD is
		variable Result : T_PB_REGISTER_FIELD;
	begin
		Result.FieldName	:= pb_LongName(NameLong);
		Result.FieldShort	:= pb_ShortName(NameShort);
		Result.Length			:= Length;
		Result.FieldKind	:= PB_REGISTER_FIELD_KIND_READWRITE;
		Result.AutoClear	:= AutoClear;
		return Result;
	end function;
	
	function pb_GetRegisterFieldID(RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; NameShort : STRING) return T_UINT_8 is
	begin
		for i in RegisterFieldList'range loop
			next when (not str_match(RegisterFieldList(i).FieldShort, NameShort));
			return i;
		end loop;
		report "RegisterField '" & NameShort & "' does not exist!" severity FAILURE;
	end function;

	function pb_GetRegisterField(RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; NameShort : STRING) return T_PB_REGISTER_FIELD is
	begin
		return RegisterFieldList(pb_GetRegisterFieldID(RegisterFieldList, NameShort));
	end function;
	
	function pb_CreateRegisterRO(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER is
		variable Result : T_PB_REGISTER;
		constant RegisterFieldID	: T_UINT_8						:= pb_GetRegisterFieldID(RegisterFieldList, RegisterNameShort);
		constant RegisterField 		: T_PB_REGISTER_FIELD := pb_GetRegisterField(RegisterFieldList, RegisterNameShort);
	begin
		assert (RegisterField.FieldKind = PB_REGISTER_FIELD_KIND_READ)
			report "pb_CreateRegisterRO: Given RegisterField is not RO, but should be translated into a READ register."
			severity FAILURE;
	
		Result.RegisterName			:= pb_LongName(NameShort);
		Result.RegisterShort		:= pb_ShortName(NameShort);
		Result.RegisterNumber		:= RegisterNumber;
		Result.RegisterKind			:= PB_REGISTER_KIND_READ;
		Result.FieldMappings		:= pb_Resize((
			FieldID =>			RegisterFieldID,
			Start =>				Offset,
			Length =>				RegisterField.Length,
			MappingKind =>	PB_REGISTER_FIELD_MAPPING_KIND_READ));
	
		return Result;
	end function;
	
	function pb_CreateRegisterRW(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER_VECTOR is
		variable Result 					: T_PB_REGISTER_VECTOR(0 to 1);
		constant RegisterFieldID	: T_UINT_8						:= pb_GetRegisterFieldID(RegisterFieldList, RegisterNameShort);
		constant RegisterField 		: T_PB_REGISTER_FIELD := pb_GetRegisterField(RegisterFieldList, RegisterNameShort);
	begin
		assert (RegisterField.FieldKind = PB_REGISTER_FIELD_KIND_READWRITE)
			report "pb_CreateRegisterRW: Given RegisterField is not RW, but should be translated into a READ and a WRITE register."
			severity FAILURE;
	
		Result(0).RegisterName		:= pb_LongName(NameShort);
		Result(0).RegisterShort		:= pb_ShortName(NameShort);
		Result(0).RegisterNumber	:= RegisterNumber;
		Result(0).RegisterKind		:= PB_REGISTER_KIND_READ;
		Result(0).FieldMappings		:= pb_Resize((
			FieldID =>			RegisterFieldID,
			Start =>				Offset,
			Length =>				RegisterField.Length,
			MappingKind =>	PB_REGISTER_FIELD_MAPPING_KIND_READ));
				
		Result(1).RegisterName		:= pb_LongName(NameShort);
		Result(1).RegisterShort		:= pb_ShortName(NameShort);
		Result(1).RegisterNumber	:= RegisterNumber;
		Result(1).RegisterKind		:= PB_REGISTER_KIND_WRITE;
		Result(1).FieldMappings		:= pb_Resize((
			FieldID =>			RegisterFieldID,
			Start =>				Offset,
			Length =>				RegisterField.Length,
			MappingKind =>	PB_REGISTER_FIELD_MAPPING_KIND_WRITE));
		
		return Result;
	end function;
	
	function pb_CreateRegisterWO(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER is
		variable Result : T_PB_REGISTER;
		constant RegisterFieldID	: T_UINT_8						:= pb_GetRegisterFieldID(RegisterFieldList, RegisterNameShort);
		constant RegisterField 		: T_PB_REGISTER_FIELD := pb_GetRegisterField(RegisterFieldList, RegisterNameShort);
	begin
		assert (RegisterField.FieldKind = PB_REGISTER_FIELD_KIND_WRITE)
			report "pb_CreateRegisterRO: Given RegisterField is not WO, but should be translated into a WRITE register."
			severity FAILURE;
	
		Result.RegisterName			:= pb_LongName(NameShort);
		Result.RegisterShort		:= pb_ShortName(NameShort);
		Result.RegisterNumber		:= RegisterNumber;
		Result.RegisterKind			:= PB_REGISTER_KIND_WRITE;
		Result.FieldMappings		:= pb_Resize((
			FieldID =>			RegisterFieldID,
			Start =>				Offset,
			Length =>				RegisterField.Length,
			MappingKind =>	PB_REGISTER_FIELD_MAPPING_KIND_READ));
		
		return Result;
	end function;
	
	function pb_CreateRegisterK(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER is
		variable Result : T_PB_REGISTER;
		constant RegisterFieldID	: T_UINT_8						:= pb_GetRegisterFieldID(RegisterFieldList, RegisterNameShort);
		constant RegisterField 		: T_PB_REGISTER_FIELD := pb_GetRegisterField(RegisterFieldList, RegisterNameShort);
	begin
		assert (RegisterField.FieldKind /= PB_REGISTER_FIELD_KIND_READ)
			report "pb_CreateRegisterK: Given RegisterField is not WO or RW, but should be translated into a WRITE register."
			severity FAILURE;
	
		Result.RegisterName			:= pb_LongName(NameShort);
		Result.RegisterShort		:= pb_ShortName(NameShort);
		Result.RegisterNumber		:= RegisterNumber;
		Result.RegisterKind			:= PB_REGISTER_KIND_WRITEK;
		Result.FieldMappings		:= pb_Resize((
			FieldID =>			RegisterFieldID,
			Start =>				Offset,
			Length =>				RegisterField.Length,
			MappingKind =>	PB_REGISTER_FIELD_MAPPING_KIND_WRITEK));

		return Result;
	end function;

	function pb_CreateRegisterWK(NameShort : STRING; RegisterNumber : T_UINT_8; RegisterFieldList : T_PB_REGISTER_FIELD_VECTOR; RegisterNameShort : STRING; Offset : T_UINT_8 := 0) return T_PB_REGISTER_VECTOR is
		variable Result 					: T_PB_REGISTER_VECTOR(0 to 1);
		constant RegisterFieldID	: T_UINT_8						:= pb_GetRegisterFieldID(RegisterFieldList, RegisterNameShort);
		constant RegisterField 		: T_PB_REGISTER_FIELD := pb_GetRegisterField(RegisterFieldList, RegisterNameShort);
	begin
		assert (RegisterField.FieldKind /= PB_REGISTER_FIELD_KIND_READ)
			report "pb_CreateRegisterRW: Given RegisterField is not WO, but should be translated into a WRITE register."
			severity FAILURE;
	
		Result(0).RegisterName		:= pb_LongName(NameShort);
		Result(0).RegisterShort		:= pb_ShortName(NameShort);
		Result(0).RegisterNumber	:= RegisterNumber;
		Result(0).RegisterKind		:= PB_REGISTER_KIND_WRITE;
		Result(0).FieldMappings		:= pb_Resize((
			FieldID =>			RegisterFieldID,
			Start =>				Offset,
			Length =>				RegisterField.Length,
			MappingKind =>	PB_REGISTER_FIELD_MAPPING_KIND_WRITE));
				
		Result(1).RegisterName		:= pb_LongName(NameShort);
		Result(1).RegisterShort		:= pb_ShortName(NameShort);
		Result(1).RegisterNumber	:= RegisterNumber;
		Result(1).RegisterKind		:= PB_REGISTER_KIND_WRITEK;
		Result(1).FieldMappings		:= pb_Resize((
			FieldID =>			RegisterFieldID,
			Start =>				Offset,
			Length =>				RegisterField.Length,
			MappingKind =>	PB_REGISTER_FIELD_MAPPING_KIND_WRITEK));
		
		return Result;
	end function;

	function pb_GetRegisterCount(Device : T_PB_DEVICE) return T_UINT_8 is
		variable Count : T_UINT_8 := 0;
	begin
		for i in Device.Registers'range loop
			if (Device.Registers(i).RegisterNumber /= 255) then
				Count := Count + 1;
			end if;
		end loop;
		return Count;
	end function;

	function pb_GetRegisterCount(DeviceInstance : T_PB_DEVICE_INSTANCE) return T_UINT_8 is
		variable Count : T_UINT_8 := 0;
	begin
		for i in DeviceInstance.Device.Registers'range loop
			if (DeviceInstance.Device.Registers(i).RegisterNumber /= 255) then
				Count := Count + 1;
			end if;
		end loop;
		return Count;
	end function;
	
	function pb_CreateMapping(Device : T_PB_DEVICE; Start : T_UINT_8) return T_PB_PORTNUMBER_MAPPING_VECTOR is
		variable Result					: T_PB_PORTNUMBER_MAPPING_VECTOR(T_PB_PORTNUMBER_MAPPING_INDEX);
		variable RegisterCount	: T_UINT_8						:= pb_GetRegisterCount(Device);
		variable Reg						: T_PB_REGISTER;
		variable j							: T_UINT_8;
	begin
		report "pb_CreateMapping: for device " & str_trim(Device.DeviceShort) & " with " & INTEGER'image(RegisterCount) & " registers." severity NOTE;
	
		j := 0;
		for i in 0 to RegisterCount - 1 loop
			Reg := Device.Registers(i);
			
			report "  Mapping PortNumber " & INTEGER'image(Start + Reg.RegisterNumber) & " to register " & INTEGER'image(Reg.RegisterNumber) & " (" & str_trim(Reg.RegisterShort) & ")" severity NOTE;
			case Reg.RegisterKind is
				when PB_REGISTER_KIND_READ =>
					Result(j)			:= (
						PortNumber =>		Start + Reg.RegisterNumber,
						RegID =>				i,
						MappingKind =>	PB_MAPPING_KIND_READ
					);
					j := j + 1;
					
				when PB_REGISTER_KIND_READWRITE =>
					Result(j)			:= (
						PortNumber =>		Start + Reg.RegisterNumber,
						RegID =>				i,
						MappingKind =>	PB_MAPPING_KIND_READ
					);
					Result(j + 1)	:= (
						PortNumber =>		Start + Reg.RegisterNumber,
						RegID =>				i,
						MappingKind =>	PB_MAPPING_KIND_WRITE
					);
					j := j + 2;
					
				when PB_REGISTER_KIND_WRITE =>
					Result(j)			:= (
						PortNumber =>		Start + Reg.RegisterNumber,
						RegID =>				i,
						MappingKind =>	PB_MAPPING_KIND_WRITE
					);
					j := j + 1;
				
				when PB_REGISTER_KIND_WRITEK =>
					Result(j)			:= (
						PortNumber =>		Start + Reg.RegisterNumber,
						RegID =>				i,
						MappingKind =>	PB_MAPPING_KIND_WRITEK
					);
					j := j + 1;
				
				assert (j <= C_PB_MAX_MAPPINGS) report "pb_CreateMapping: Too many mappings created." severity FAILURE;
			end case;
		end loop;

		return Result;
	end function;
	
	function pb_CreateDeviceInstance(Device : T_PB_DEVICE; BusShort : STRING; Start : T_UINT_8) return T_PB_DEVICE_INSTANCE is
		variable Result : T_PB_DEVICE_INSTANCE;
	begin
		Result.DeviceName			:= Device.DeviceName;
		Result.DeviceShort		:= Device.DeviceShort;
		Result.Device					:= Device;
		Result.BusShort				:= pb_ShortName(BusShort);
		Result.Mappings				:= pb_CreateMapping(Device, Start);
		return Result;
	end function;
	
	function pb_CreateDeviceInstance(Device : T_PB_DEVICE; InstanceNumber : T_UINT_8; BusShort : STRING; Start : T_UINT_8) return T_PB_DEVICE_INSTANCE is
		variable Result : T_PB_DEVICE_INSTANCE;
	begin
		Result.DeviceName			:= pb_LongName(str_trim(Device.DeviceName) & INTEGER'image(InstanceNumber));
		Result.DeviceShort		:= pb_ShortName(str_trim(Device.DeviceShort) & INTEGER'image(InstanceNumber));
		Result.Device					:= Device;
		Result.BusShort				:= pb_ShortName(BusShort);
		Result.Mappings				:= pb_CreateMapping(Device, Start);
		return Result;
	end function;
	
	function pb_CreateDeviceInstance(Device : T_PB_DEVICE; NameLong : STRING; NameShort : STRING; BusShort : STRING; Start : T_UINT_8) return T_PB_DEVICE_INSTANCE is
		variable Result : T_PB_DEVICE_INSTANCE;
	begin
		Result.DeviceName			:= pb_LongName(NameLong);
		Result.DeviceShort		:= pb_ShortName(NameShort);
		Result.Device					:= Device;
		Result.BusShort				:= pb_ShortName(BusShort);
		Result.Mappings				:= pb_CreateMapping(Device, Start);
		return Result;
	end function;

	function pb_GetDeviceInstanceID(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR; NameShort : STRING) return T_PB_DEVICE_INSTANCE_INDEX is
	begin
		for i in DeviceInstances'range loop
			next when (not str_match(DeviceInstances(i).DeviceShort, NameShort));
			return i;
		end loop;
		report "Device '" & NameShort & "' does not exist!" severity FAILURE;
	end function;
	
	function pb_GetDeviceInstanceID(System : T_PB_SYSTEM; NameShort : STRING) return T_PB_DEVICE_INSTANCE_INDEX is
	begin
		for i in 0 to System.DeviceInstanceCount loop
			next when (not str_match(System.DeviceInstances(i).DeviceShort, NameShort));
			return i;
		end loop;
		report "Device '" & NameShort & "' does not exist!" severity FAILURE;
	end function;

	function pb_GetDeviceInstance(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR; NameShort : STRING) return T_PB_DEVICE_INSTANCE is
	begin
		return DeviceInstances(pb_GetDeviceInstanceID(DeviceInstances, NameShort));
	end function;
	
	function pb_GetDeviceInstance(System : T_PB_SYSTEM; NameShort : STRING) return T_PB_DEVICE_INSTANCE is
	begin
		return System.DeviceInstances(pb_GetDeviceInstanceID(System, NameShort));
	end function;
	
	function pb_CreateBus(BusName : STRING; BusShort : STRING; SuperBusShort : STRING) return T_PB_BUS is
		variable Result : T_PB_BUS;
	begin
		Result.BusName					:= pb_LongName(BusName);
		Result.BusShort					:= pb_ShortName(BusShort);
		Result.SuperBusShort		:= pb_ShortName(SuperBusShort);
		Result.SuperBusID				:= 0;
		Result.SubBusses				:= (others => 0);
		Result.SubBusCount			:= 0;
		Result.Devices					:= (others => 0);
		Result.DeviceCount			:= 0;
		Result.TotalDeviceCount	:= 0;
		return Result;
	end function;
	
	function pb_GetBusID(Busses : T_PB_BUS_VECTOR; BusShort : T_PB_SHORTNAME) return NATURAL is
	begin
		for i in Busses'range loop
			next when (Busses(i).BusShort /= BusShort);
			return i;
		end loop;
		report "Unknown bus name '" & str_trim(BusShort) & "'" severity failure;
	end function;

	function pb_GetBusID(System : T_PB_SYSTEM; BusShort : T_PB_SHORTNAME) return NATURAL is
	begin
		return pb_GetBusID(System.Busses(0 to System.BusCount - 1), BusShort);
	end function;
	
	function pb_ConnectBusses(Busses : T_PB_BUS_VECTOR) return T_PB_BUS_VECTOR is
		variable Result			: T_PB_BUS_VECTOR(Busses'range);
		variable SuperBusID	: T_PB_BUSID;
		variable j					: T_UINT_8;
	begin
		for i in Busses'range loop
			report "pb_ConnectBusses: Connecting bus '" & str_trim(Busses(i).BusShort) & "' to '" & str_trim(Busses(i).SuperBusShort) & "'" severity note;
			if (str_length(Busses(i).SuperBusShort) /= 0) then
				SuperBusID	:= pb_GetBusID(Busses, Busses(i).SuperBusShort);
			else
				SuperBusID	:= T_PB_BUSID'high;
			end if;
		
			Result(i).BusName				:= Busses(i).BusName;
			Result(i).BusShort			:= Busses(i).BusShort;
			Result(i).SuperBusShort	:= Busses(i).SuperBusShort;
			Result(i).SuperBusID		:= SuperBusID;
			
			if (SuperBusID /= T_PB_BUSID'high) then
				j																:= Result(SuperBusID).SubBusCount;
				Result(SuperBusID).SubBusses(j)	:= i;
				Result(SuperBusID).SubBusCount	:= j + 1;
			end if;
		end loop;
		return Result;
	end function;

	function pb_GetTotalDeviceCount(Busses : T_PB_BUS_VECTOR; BusID : T_PB_BUSID) return T_UINT_8 is
		variable Result : T_UINT_8	:= 0;
	begin
		report "pb_GetTotalDeviceCount: BusID=" & INTEGER'image(BusID) severity NOTE;
		for i in 0 to Busses(BusID).SubBusCount - 1 loop
			Result := Result + pb_GetTotalDeviceCount(Busses, Busses(BusID).SubBusses(i));
		end loop;
		return Result + Busses(BusID).DeviceCount;
	end function;
	
	procedure pb_PrintBusses(Busses : T_PB_BUS_VECTOR) is
	
	begin
		report "pb_PrintBusses: Count=" & INTEGER'image(Busses'length) severity NOTE;
		for i in Busses'range loop
			report "BusID " & INTEGER'image(i) severity NOTE;
			report "  SuperBusID " & INTEGER'image(Busses(i).SuperBusID) severity NOTE;
			report "  SubBusCount " & INTEGER'image(Busses(i).SubBusCount) severity NOTE;
			for j in 0 to Busses(i).SubBusCount - 1 loop
				report "    SubBusID " & INTEGER'image(Busses(i).SubBusses(j)) severity NOTE;
			end loop;
			report "  DeviceCount " & INTEGER'image(Busses(i).DeviceCount) severity NOTE;
			for j in 0 to Busses(i).DeviceCount - 1 loop
				report "    DeviceID " & INTEGER'image(Busses(i).Devices(j)) severity NOTE;
			end loop;
		end loop;
	end procedure;
	
	function pb_CreateSystem(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR; Busses : T_PB_BUS_VECTOR) return T_PB_SYSTEM is
		variable Result : T_PB_SYSTEM;
		variable BusID	: T_PB_BUSID;
		variable j			: T_UINT_8;
	begin
		Result.DeviceInstances			:= pb_ResizeVec(DeviceInstances);
		Result.DeviceInstanceCount	:= DeviceInstances'length;
		Result.Busses								:= pb_ResizeVec(Busses);
		Result.BusCount							:= Busses'length;
	
		-- connect devices to busses
		for i in DeviceInstances'range loop
			BusID															:= pb_GetBusID(Busses, DeviceInstances(i).BusShort);
			j																	:= Result.Busses(BusID).DeviceCount;
			Result.Busses(BusID).Devices(j)		:= i;
			Result.Busses(BusID).DeviceCount	:= j + 1;
		end loop;
		-- count devices on a bus
		-- TODO: rewrite recursion to local loops
		for i in 0 to Result.BusCount - 1 loop
			Result.Busses(i).TotalDeviceCount := pb_GetTotalDeviceCount(Result.Busses(0 to Result.BusCount - 1), i);
		end loop;

		pb_PrintBusses(Result.Busses(0 to Result.BusCount - 1));	
		return Result;
	end function;
	
	function pb_Resize(RegisterMapping : T_PB_REGISTER_FIELD_MAPPING; Size : NATURAL := 0) return T_PB_REGISTER_FIELD_MAPPING_VECTOR is
		constant high : T_UINT_8 := ite(Size /= 0, (Size - 1), T_PB_REGISTER_FIELD_MAPPING_INDEX'high);
	begin
		return RegisterMapping & T_PB_REGISTER_FIELD_MAPPING_VECTOR'(1 to high => C_PB_REGISTER_FIELD_MAPPING_EMPTY);
	end function;
	
	function pb_Resize(RegisterField : T_PB_REGISTER_FIELD; Size : NATURAL := 0) return T_PB_REGISTER_FIELD_VECTOR is
		constant high : T_UINT_8 := ite(Size /= 0, (Size - 1), T_PB_REGISTER_FIELD_INDEX'high);
	begin
		return RegisterField & T_PB_REGISTER_FIELD_VECTOR'(1 to high => C_PB_REGISTER_FIELD_EMPTY);
	end function;
	
	function pb_Resize(Reg : T_PB_REGISTER; Size : NATURAL := 0) return T_PB_REGISTER_VECTOR is
		constant high : T_UINT_8 := ite(Size /= 0, (Size - 1), T_PB_REGISTER_INDEX'high);
	begin
		return Reg & T_PB_REGISTER_VECTOR'(1 to high => C_PB_REGISTER_EMPTY);
	end function;
	
	function pb_ResizeVec(RegisterMappings : T_PB_REGISTER_FIELD_MAPPING_VECTOR; Size : NATURAL := 0) return T_PB_REGISTER_FIELD_MAPPING_VECTOR is
		constant high : T_UINT_8 := ite(Size /= 0, (Size - 1), T_PB_REGISTER_FIELD_MAPPING_INDEX'high);
	begin
		return RegisterMappings & T_PB_REGISTER_FIELD_MAPPING_VECTOR'(RegisterMappings'length to high => C_PB_REGISTER_FIELD_MAPPING_EMPTY);
	end function;
	
	function pb_ResizeVec(RegisterFields : T_PB_REGISTER_FIELD_VECTOR; Size : NATURAL := 0) return T_PB_REGISTER_FIELD_VECTOR is
		constant high : T_UINT_8 := ite(Size /= 0, (Size - 1), T_PB_REGISTER_FIELD_INDEX'high);
	begin
		return RegisterFields & T_PB_REGISTER_FIELD_VECTOR'(RegisterFields'length to high => C_PB_REGISTER_FIELD_EMPTY);
	end function;
	
	function pb_ResizeVec(Registers : T_PB_REGISTER_VECTOR; Size : NATURAL := 0) return T_PB_REGISTER_VECTOR is
		constant high : T_UINT_8 := ite(Size /= 0, (Size - 1), T_PB_REGISTER_INDEX'high);
	begin
		return Registers & T_PB_REGISTER_VECTOR'(Registers'length to high => C_PB_REGISTER_EMPTY);
	end function;

	function pb_ResizeVec(Busses : T_PB_BUS_VECTOR; Size : NATURAL := 0) return T_PB_BUS_VECTOR is
		constant high : T_UINT_8 := ite(Size /= 0, (Size - 1), T_PB_BUS_INDEX'high);
	begin
		return Busses & T_PB_BUS_VECTOR'(Busses'length to high => C_PB_BUS_EMPTY);
	end function;
	
	function pb_ResizeVec(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR; Size : NATURAL := 0) return T_PB_DEVICE_INSTANCE_VECTOR is
		constant high : T_UINT_8 := ite(Size /= 0, (Size - 1), T_PB_DEVICE_INSTANCE_INDEX'high);
	begin
		return DeviceInstances & T_PB_DEVICE_INSTANCE_VECTOR'(DeviceInstances'length to high => C_PB_DEVICE_INSTANCE_EMPTY);
	end function;
	
	-- PicoBlaze interrupt functions
	function pb_GetInterruptCount(System : T_PB_SYSTEM) return NATURAL is
		variable Result : NATURAL := 0;
	begin
		for i in 0 to System.DeviceInstanceCount - 1 loop
			if (System.DeviceInstances(i).Device.CreatesInterrupt = TRUE) then
				Result := Result + 1;
			end if;
		end loop;
		return Result;
	end function;
	
	function pb_GetInterruptPortIndex(System : T_PB_SYSTEM; DeviceShort : STRING) return NATURAL is
		variable Result : NATURAL		:= 0;
	begin
		for i in 0 to System.DeviceInstanceCount - 1 loop
			exit when str_match(System.DeviceInstances(i).DeviceShort, DeviceShort);
			Result := Result + 1;
		end loop;
		return Result;
	end function;
	
	function pb_GetInterruptVector(PicoBlazeBus : T_PB_IOBUS_DEV_PB_VECTOR; System : T_PB_SYSTEM) return STD_LOGIC_VECTOR is
		variable Result						: STD_LOGIC_VECTOR(System.DeviceInstanceCount - 1 downto 0);
		variable DeviceInstance		: T_PB_DEVICE_INSTANCE;
		variable BusIndex					: T_PB_BUSID;
		variable InterruptPortID	: T_UINT_8							:= 0;
	begin
		for i in 0 to System.DeviceInstanceCount - 1 loop
			DeviceInstance	:= System.DeviceInstances(i);
			BusIndex				:= pb_GetBusIndex(System, DeviceInstance.DeviceShort);
			
			if (DeviceInstance.Device.CreatesInterrupt = TRUE) then
				Result(InterruptPortID)	:= PicoBlazeBus(BusIndex).Interrupt;
				InterruptPortID					:= InterruptPortID + 1;
			end if;
		end loop;
		return Result(InterruptPortID - 1 downto 0);
	end function;

	function pb_GetInterruptMessages(PicoBlazeBus : T_PB_IOBUS_DEV_PB_VECTOR; System : T_PB_SYSTEM) return T_SLVV_8 is
		variable Result						: T_SLVV_8(System.DeviceInstanceCount - 1 downto 0);
		variable DeviceInstance		: T_PB_DEVICE_INSTANCE;
		variable BusIndex					: T_PB_BUSID;
		variable InterruptPortID	: T_UINT_8							:= 0;
	begin
		for i in 0 to System.DeviceInstanceCount - 1 loop
			DeviceInstance	:= System.DeviceInstances(i);
			BusIndex				:= pb_GetBusIndex(System, DeviceInstance.DeviceShort);
			
			if (DeviceInstance.Device.CreatesInterrupt = TRUE) then
				Result(InterruptPortID)	:= PicoBlazeBus(BusIndex).Message;
				InterruptPortID					:= InterruptPortID + 1;
			end if;
		end loop;
		return Result(InterruptPortID - 1 downto 0);
	end function;

	procedure pb_AssignInterruptAck(signal Output : inout T_PB_IOBUS_PB_DEV_VECTOR; Input : STD_LOGIC_VECTOR; System : T_PB_SYSTEM) is
		variable DeviceInstance		: T_PB_DEVICE_INSTANCE;
		variable BusIndex					: T_PB_BUSID;
		variable InterruptPortID	: NATURAL								:= 0;
	begin
		for i in 0 to System.DeviceInstanceCount - 1 loop
			DeviceInstance	:= System.DeviceInstances(i);
			BusIndex				:= pb_GetBusIndex(System, DeviceInstance.DeviceShort);

			if (DeviceInstance.Device.CreatesInterrupt = TRUE) then
				Output(i).Interrupt_Ack	<= Input(InterruptPortID);
				InterruptPortID					:= InterruptPortID + 1;
			else
				Output(i).Interrupt_Ack	<= '0';
			end if;
		end loop;
	end procedure;
	
	-- PicoBlaze bus functions
	function pb_GetBusWidth(System : T_PB_SYSTEM; BusShort : STRING) return NATURAL is
		constant BUSID			: T_PB_BUSID	:= pb_GetBusID(System, pb_ShortName(BusShort));
	begin
		return System.Busses(BUSID).TotalDeviceCount;
	end function;
	
	function pb_GetBusIndex(System : T_PB_SYSTEM; DeviceShort : STRING) return NATURAL is
		constant DeviceInstance		: T_PB_DEVICE_INSTANCE				:= pb_GetDeviceInstance(System, DeviceShort);
		constant DeviceInstanceID : T_PB_DEVICE_INSTANCE_INDEX	:= pb_GetDeviceInstanceID(System, DeviceShort);
		constant BusID						: T_PB_BUSID									:= pb_GetBusID(System, DeviceInstance.BusShort);
		constant MyBus						: T_PB_BUS										:= System.Busses(BusID);
		variable Result						: NATURAL											:= 0;
	begin
--		report "pb_GetBusIndex: DevInstID=" & INTEGER'image(DeviceInstanceID) severity NOTE;
	
		Result :=  MyBus.TotalDeviceCount -  MyBus.DeviceCount;
		for i in 0 to  MyBus.DeviceCount - 1 loop
--			report "pb_GetBusIndex: Devices(i)=" & INTEGER'image(MyBus.Devices(i)) severity NOTE;
			exit when (MyBus.Devices(i) = DeviceInstanceID);
			Result := Result + 1;
		end loop;
		return Result;
	end function;
	
	function pb_GetSubBusOffset(System : T_PB_SYSTEM; BusShort : T_PB_SHORTNAME) return NATURAL is
		constant BusID			: T_PB_BUSID	:= pb_GetBusID(System, BusShort);
		constant SuperBusID	: T_PB_BUSID	:= System.Busses(BusID).SuperBusID;
		variable Result			: NATURAL			:= 0;
	begin
		for i in 0 to System.Busses(SuperBusID).SubBusCount - 1 loop
			if (System.Busses(SuperBusID).SubBusses(i) = BusID) then
				return Result;
			else
				Result := Result + System.Busses(System.Busses(SuperBusID).SubBusses(i)).TotalDeviceCount;
			end if;
		end loop;
		-- report error
	end function;
	
	function pb_GetSubOrdinateBus(Input : T_PB_IOBUS_PB_DEV_VECTOR; System : T_PB_SYSTEM; BusShort : STRING) return T_PB_IOBUS_PB_DEV_VECTOR is
		constant BusWidth	: NATURAL																					:= pb_GetBusWidth(System, BusShort);
		constant Offset		: NATURAL																					:= pb_GetSubBusOffset(System, pb_ShortName(BusShort));
		variable Result		: T_PB_IOBUS_PB_DEV_VECTOR(BusWidth - 1 downto 0);
	begin
		for i in Result'range loop
			Result(i)	:= Input(Offset + i);
		end loop;
		return Result;
	end function;
	
	procedure pb_AssignSubOrdinateBus(signal Output : inout T_PB_IOBUS_DEV_PB_VECTOR; Input : T_PB_IOBUS_DEV_PB_VECTOR; System : T_PB_SYSTEM; BusShort : STRING) is
		constant Offset		: NATURAL		:= pb_GetSubBusOffset(System, pb_ShortName(BusShort));
	begin
		for i in Input'range loop
			Output(Offset + i)	<= Input(i);
		end loop;
	end procedure;

	function pb_PrintAddressMapping(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR) return BOOLEAN is
		variable DeviceInstance	: T_PB_DEVICE_INSTANCE;
		variable Device					: T_PB_DEVICE;
		variable Reg						: T_PB_REGISTER;
		variable Field					: T_PB_REGISTER_FIELD_MAPPING;
	begin
		for i in DeviceInstances'range loop
			DeviceInstance	:= DeviceInstances(i);
			Device					:= DeviceInstance.Device;
			
			report "DeviceInstance " & INTEGER'image(i) & ":" severity NOTE;
			report "  DeviceInstance: " & str_trim(DeviceInstance.DeviceShort) severity NOTE;
			report "    Device: " & str_trim(Device.DeviceShort) severity NOTE;
			report "      Registers: " severity NOTE;
			for j in Device.Registers'range loop
				Reg := Device.Registers(j);
				if (Reg.RegisterNumber /= 255) then
					report "        " & INTEGER'image(j) & ": " & str_trim(Reg.RegisterShort) & " Reg#=" & INTEGER'image(Reg.RegisterNumber) & " " &
							ite((Reg.RegisterKind = PB_REGISTER_KIND_READ),				"RD",
							ite((Reg.RegisterKind = PB_REGISTER_KIND_READWRITE),	"RW",
							ite((Reg.RegisterKind = PB_REGISTER_KIND_WRITE),			"WR", "K ")))
						severity NOTE;
					for k in Reg.FieldMappings'range loop
						Field	:= Reg.FieldMappings(k);
						if (Field.FieldID /= 255) then
							report "          " & INTEGER'image(k) & ": FieldID=" & INTEGER'image(Field.FieldID) & " (" & str_trim(Device.RegisterFields(Field.FieldID).FieldShort) & ")"
								severity NOTE;
						end if;
					end loop;
				end if;
			end loop;
		end loop;
		
		return TRUE;
	end function;

	impure function pb_ExportAddressMapping(DeviceInstances : T_PB_DEVICE_INSTANCE_VECTOR; Name : STRING; psmFileName : STRING; tokenFileName : STRING) return BOOLEAN is
		file psmFile		: TEXT open WRITE_MODE is psmFileName;
		file tokenFile	: TEXT open WRITE_MODE is tokenFileName;

		variable psmLine				: LINE;
		variable tokenLine			: LINE;

		variable DeviceInstance	: T_PB_DEVICE_INSTANCE;
		variable Device					: T_PB_DEVICE;
		variable Mapping				: T_PB_PORTNUMBER_MAPPING;
		
		variable PortNumber_slv	: T_SLV_8;

		type T_USAGE_TRACKING is record
			DeviceInstanceID	: T_UINT_8;
			MappingID					: T_UINT_8;
		end record;
		
		type T_ERROR_DETECT is array (NATURAL range <>) of T_USAGE_TRACKING;
		variable AddressMapRead		: T_ERROR_DETECT(0 to 255)	:= (others => (0, 255));
		variable AddressMapWrite	: T_ERROR_DETECT(0 to 255)	:= (others => (0, 255));
		variable AddressMapWriteK	: T_ERROR_DETECT(0 to 15)		:= (others => (0, 255));

		variable MappingID					: T_UINT_8;
		variable DeviceInstanceID		: T_UINT_8;
		variable RegID							: T_UINT_8;
		variable Reg								: T_PB_REGISTER;
		
		variable dummy							: BOOLEAN;
	begin
		dummy := pb_PrintAddressMapping(DeviceInstances);
	
		report "Exporting PicoBlaze address mappings as psm-file to '" & psmFileName & "' and as token-file to '" & tokenFileName & "'..." severity note;
		
		-- psm-file: write file header
		write(psmLine, STRING'("; Generate by synthesis for '" & Name & "'"));															writeline(psmFile, psmLine);
		write(psmLine, STRING'(";"));																																				writeline(psmFile, psmLine);
		write(psmLine, STRING'("; This file contains the PicoBlaze PortNumber to DeviceRegister mappings."));		writeline(psmFile, psmLine);
		write(psmLine, STRING'(";"));																																				writeline(psmFile, psmLine);
		write(psmLine, STRING'(";"));																																				writeline(psmFile, psmLine);

		-- token-file: write file header
		write(tokenLine, STRING'("# " & Name & " - PortNumbers"));				writeline(tokenFile, tokenLine);
		write(tokenLine, STRING'("#"));																writeline(tokenFile, tokenLine);
		write(tokenLine, STRING'("#"));																writeline(tokenFile, tokenLine);
		write(tokenLine, STRING'("# ChipScope Token File Version"));	writeline(tokenFile, tokenLine);
		write(tokenLine, STRING'("@FILE_VERSION=1.0.0"));							writeline(tokenFile, tokenLine);
		write(tokenLine, STRING'("#"));																writeline(tokenFile, tokenLine);
		write(tokenLine, STRING'("# Default token value"));						writeline(tokenFile, tokenLine);
		write(tokenLine, STRING'("@DEFAULT_TOKEN="));									writeline(tokenFile, tokenLine);
	
		-- write per device entires
		for i in DeviceInstances'range loop
			DeviceInstance	:= DeviceInstances(i);
			Device					:= DeviceInstance.Device;
		
			write(psmLine, STRING'(";"));																						writeline(psmFile, psmLine);
			write(psmLine, STRING'("; ") & str_trim(DeviceInstance.DeviceName));		writeline(psmFile, psmLine);

			write(tokenLine, STRING'("#"));																					writeline(tokenFile, tokenLine);
			write(tokenLine, STRING'("# ") & str_trim(DeviceInstance.DeviceName));	writeline(tokenFile, tokenLine);
		
			for j in DeviceInstance.Mappings'range loop
				Mapping	:= DeviceInstance.Mappings(j);

				report "pb_ExportAddressMapping: Map PortNumber " & INTEGER'image(Mapping.PortNumber) &
								 " to device " & INTEGER'image(-1) &
								 " (" & str_trim(DeviceInstance.DeviceShort) &
								 ") register " & INTEGER'image(DeviceInstance.Device.Registers(Mapping.RegID).RegisterNumber) &
								 " (" & str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterShort) & ")."
						severity NOTE;

				-- tokenFile content for INPUT address space
				if (Mapping.MappingKind = PB_MAPPING_KIND_READ) then
					if (AddressMapRead(Mapping.PortNumber).MappingID = 255) then
						PortNumber_slv	:= to_slv(Mapping.PortNumber, 8);
						AddressMapRead(Mapping.PortNumber)	:= (DeviceInstanceID => i, MappingID => j);					-- save used MappingID for a PortNumber
						
						write(tokenLine, "RD_" & str_trim(DeviceInstance.DeviceShort) & "=2" & to_string(PortNumber_slv, 'h', 2));
						writeline(tokenFile, tokenLine);
						
						write(psmLine, "CONSTANT IPORT_" & str_to_upper(str_trim(DeviceInstance.DeviceShort)) &
													 "_" & str_to_upper(str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterShort)) &
													 ", " & INTEGER'image(Mapping.PortNumber) &
													 "'d    ; " & str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterName));
						writeline(psmFile, psmLine);
					else
						DeviceInstanceID	:= AddressMapRead(Mapping.PortNumber).DeviceInstanceID;
						MappingID					:= AddressMapRead(Mapping.PortNumber).MappingID;
						RegID							:= DeviceInstances(DeviceInstanceID).Mappings(MappingID).RegID;
						Reg								:= DeviceInstances(DeviceInstanceID).Device.Registers(RegID);
						
						report "pb_ExportAddressMapping:" & LF & "PortNumber " & INTEGER'image(Mapping.PortNumber) &
									 " is already used by " & str_trim(DeviceInstances(DeviceInstanceID).DeviceShort) &
									 " register " & INTEGER'image(Reg.RegisterNumber) &
									 " (" & str_trim(Reg.RegisterShort) & ")." & LF &
									 "This overlaps with device " & str_trim(DeviceInstance.DeviceShort) &
									 " register " & INTEGER'image(DeviceInstance.Device.Registers(Mapping.RegID).RegisterNumber) &
									 " (" & str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterShort) & ")."
							severity FAILURE;
					end if;
				
				-- tokenFile content for OUTPUT address space
				elsif (Mapping.MappingKind = PB_MAPPING_KIND_WRITE) then
					PortNumber_slv	:= to_slv(Mapping.PortNumber, 8);
					if (AddressMapWrite(Mapping.PortNumber).MappingID = 255) then
						AddressMapWrite(Mapping.PortNumber)	:= (DeviceInstanceID => i, MappingID => j);
						
						write(tokenLine, "WR_" & str_trim(DeviceInstance.DeviceShort) & "=1" & to_string(PortNumber_slv, 'h', 2));
						writeline(tokenFile, tokenLine);
						
						write(psmLine, "CONSTANT OPORT_" & str_to_upper(str_trim(DeviceInstance.DeviceShort)) &
													 "_" & str_to_upper(str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterShort)) &
													 ", " & INTEGER'image(Mapping.PortNumber) &
													 "'d    ; " & str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterName));
						writeline(psmFile, psmLine);
					else
						DeviceInstanceID	:= AddressMapWrite(Mapping.PortNumber).DeviceInstanceID;
						MappingID					:= AddressMapWrite(Mapping.PortNumber).MappingID;
						RegID							:= DeviceInstances(DeviceInstanceID).Mappings(MappingID).RegID;
						Reg								:= DeviceInstances(DeviceInstanceID).Device.Registers(RegID);
						
						report "pb_ExportAddressMapping:" & LF & "PortNumber " & INTEGER'image(Mapping.PortNumber) &
									 " is already used by " & str_trim(DeviceInstances(DeviceInstanceID).DeviceShort) &
									 " register " & INTEGER'image(Reg.RegisterNumber) &
									 " (" & str_trim(Reg.RegisterShort) & ")." & LF &
									 "This overlaps with device " & str_trim(DeviceInstance.DeviceShort) &
									 " register " & INTEGER'image(DeviceInstance.Device.Registers(Mapping.RegID).RegisterNumber) &
									 " (" & str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterShort) & ")."
							severity FAILURE;
					end if;
				
				-- tokenFile content for OUTPUTK address space
				elsif (Mapping.MappingKind = PB_MAPPING_KIND_WRITEK) then
					if (AddressMapWriteK(Mapping.PortNumber).MappingID = 255) then
						AddressMapWriteK(Mapping.PortNumber)	:= (DeviceInstanceID => i, MappingID => j);
						
						for k in 0 to 15 loop
							PortNumber_slv	:= to_slv(k, 4) & to_slv(Mapping.PortNumber, 4);
							write(tokenLine, STRING'("WK_" & str_trim(DeviceInstance.DeviceShort) & "=4" & to_string(PortNumber_slv, 'h', 2)));
							writeline(tokenFile, tokenLine);
						end loop;
						
						write(psmLine, "CONSTANT KPORT_" & str_to_upper(str_trim(DeviceInstance.DeviceShort)) &
													 "_" & str_to_upper(str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterShort)) &
													 ", " & INTEGER'image(Mapping.PortNumber) &
													 "'d    ; " & str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterName));
						writeline(psmFile, psmLine);
					else
						DeviceInstanceID	:= AddressMapWriteK(Mapping.PortNumber).DeviceInstanceID;
						MappingID					:= AddressMapWriteK(Mapping.PortNumber).MappingID;
						RegID							:= DeviceInstances(DeviceInstanceID).Mappings(MappingID).RegID;
						Reg								:= DeviceInstances(DeviceInstanceID).Device.Registers(RegID);
						
						report "pb_ExportAddressMapping:" & LF & "PortNumber " & INTEGER'image(Mapping.PortNumber) &
									 " is already used by " & str_trim(DeviceInstances(DeviceInstanceID).DeviceShort) &
									 " register " & INTEGER'image(Reg.RegisterNumber) &
									 " (" & str_trim(Reg.RegisterShort) & ")." & LF &
									 "This overlaps with device " & str_trim(DeviceInstance.DeviceShort) &
									 " register " & INTEGER'image(DeviceInstance.Device.Registers(Mapping.RegID).RegisterNumber) &
									 " (" & str_trim(DeviceInstance.Device.Registers(Mapping.RegID).RegisterShort) & ")."
							severity FAILURE;
					end if;
				end if;
			end loop;
		end loop;

		-- write tokens for unused PortNumbers
		write(tokenLine, STRING'("#"));											writeline(tokenFile, tokenLine);
		write(tokenLine, STRING'("# unused PortNumbers"));	writeline(tokenFile, tokenLine);
		for i in AddressMapWrite'range loop
			PortNumber_slv	:= to_slv(i, 8);
			if (AddressMapWrite(i).MappingID = 255) then
				write(tokenLine, "WR_ERR" & "=1" & to_string(PortNumber_slv, 'h', 2));
				writeline(tokenFile, tokenLine);
			end if;
		end loop;
		for i in AddressMapRead'range loop
			PortNumber_slv	:= to_slv(i, 8);
			if (AddressMapRead(i).MappingID = 255) then
				write(tokenLine, "RD_ERR" & "=2" & to_string(PortNumber_slv, 'h', 2));
				writeline(tokenFile, tokenLine);
			end if;
		end loop;
		for i in AddressMapWriteK'range loop
			if (AddressMapWriteK(i).MappingID = 255) then
				for k in 0 to 15 loop
					PortNumber_slv	:= to_slv(k, 4) & to_slv(i, 4);
					write(tokenLine, "WK_ERR" & "=4" & to_string(PortNumber_slv, 'h', 2));
					writeline(tokenFile, tokenLine);
				end loop;
			end if;
		end loop;
		
		file_close(psmFile);
		file_close(tokenFile);
		
		return true;
	end function;	
end package body;
