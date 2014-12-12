-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Patrick Lehmann
-- 
-- Package:					VHDL package for component declarations, types and
--									functions assoziated to the PoC.io namespace
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
	
	constant C_PB_MAX_MAPPINGS						: POSITIVE				:= 16;
	constant C_PB_MAX_KMAPPINGS						: POSITIVE				:= 4;
	constant C_PB_MAX_DEVICENAME_LENGTH		: POSITIVE				:= 64;
	constant C_PB_MAX_SHORTNAME_LENGTH		: POSITIVE				:= 16;

	type T_PB_PORTID_MAPPING is record
		PortID			: T_UINT_8;
		RegID				: T_UINT_8;
	end record;
	
	type T_PB_PORTID_MAPPING_VECTOR		is array(NATURAL range <>) of T_PB_PORTID_MAPPING;
	
	subtype T_PB_PORTID_KMAPPING				is T_PB_PORTID_MAPPING;
	subtype T_PB_PORTID_KMAPPING_VECTOR	is T_PB_PORTID_MAPPING_VECTOR;
	
	subtype T_PB_BUSAFFILATION					is BIT_VECTOR(7 downto 0);
	
	type T_PB_ADDRESS_MAPPING is record
		DeviceName				: STRING(1 to C_PB_MAX_DEVICENAME_LENGTH);
		DeviceShort				: STRING(1 to C_PB_MAX_SHORTNAME_LENGTH);
		
		PortID_Mappings		: T_PB_PORTID_MAPPING_VECTOR(0 to C_PB_MAX_MAPPINGS - 1);
		MappingCount			: T_UINT_8;
		
		PortID_KMappings	: T_PB_PORTID_KMAPPING_VECTOR(0 to C_PB_MAX_KMAPPINGS - 1);
		KMappingCount			: T_UINT_8;
		
		InterruptID				: T_INT_8;
		
		BusAffiliation		: T_PB_BUSAFFILATION;
	end record;

	type T_PB_ADDRESS_MAPPING_VECTOR	is array(NATURAL range <>) of T_PB_ADDRESS_MAPPING;
	
	constant C_PB_PORTID_MAPPING_EMPTY		: T_PB_PORTID_MAPPING			:= (PortID => 0, RegID => 0);
	constant C_PB_PORTID_KMAPPING_EMPTY		: T_PB_PORTID_KMAPPING		:= (PortID => 0, RegID => 0);
	constant C_PB_INTERRUPT_NONE					: T_INT_8									:= -1;
	
	subtype T_PB_BUSAFFILATION						is bit_vector(7 downto 0);
	constant C_PB_BUSAFFILATION_NONE			: T_PB_BUSAFFILATION		:= x"01";
	constant C_PB_BUSAFFILATION_ANY				: T_PB_BUSAFFILATION		:= x"02";
	constant C_PB_BUSAFFILATION_INTERN		: T_PB_BUSAFFILATION		:= x"04";
	constant C_PB_BUSAFFILATION_EXTERN		: T_PB_BUSAFFILATION		:= x"08";
	constant C_PB_BUS_INTERN							: T_PB_BUSAFFILATION		:= C_PB_BUSAFFILATION_INTERN or C_PB_BUSAFFILATION_ANY;
	constant C_PB_BUS_EXTERN							: T_PB_BUSAFFILATION		:= C_PB_BUSAFFILATION_EXTERN or C_PB_BUSAFFILATION_ANY;

	
	function pb_NewMapping(
		devName					: STRING;
		devShort				: STRING;
		startAddress		: NATURAL;
		addressCount		: POSITIVE;
		BusAffiliation	: BIT_VECTOR										:= C_PB_BUSAFFILATION_NONE;
		InterruptID			: INTEGER												:= C_PB_INTERRUPT_NONE)
	return T_PB_ADDRESS_MAPPING;
		
	function pb_NewMapping(
		devName					: STRING;
		devShort				: STRING;
		startAddress		: NATURAL;
		addressCount		: POSITIVE;
		KMappings				: T_PB_PORTID_KMAPPING_VECTOR;
		BusAffiliation	: BIT_VECTOR										:= C_PB_BUSAFFILATION_NONE;
		InterruptID			: INTEGER												:= C_PB_INTERRUPT_NONE)
	return T_PB_ADDRESS_MAPPING;
	
--	function pb_DevName(name : string)	return string;
--	function pb_DevShort(name : string)	return string;
	function pb_GetAMIdx(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; DeviceShort : STRING)							return NATURAL;
	function pb_HasIntID(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; index : NATURAL)										return BOOLEAN;
	function pb_GetIntID(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; DeviceShort : STRING)							return NATURAL;
	function pb_GetIntCount(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR)																	return NATURAL;
	function pb_GetBusCount(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : BIT_VECTOR)		return NATURAL;
	function pb_GetBusIndizes(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : BIT_VECTOR)	return T_NATVEC;
	function pb_GetSubOrdinateBus(
		Input									: T_PB_IOBUS_PB_DEV_VECTOR;
		AddressMappingVector	: T_PB_ADDRESS_MAPPING_VECTOR;
		BusAffiliation				: bit_vector)
		return T_PB_IOBUS_PB_DEV_VECTOR;
	function pb_GetSubOrdinateBusIDs(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : BIT_VECTOR) return T_NATVEC;
	function pb_GetSuperOrdinateBusIDs(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; SuperOrdinateBus : BIT_VECTOR; SubOrdinateBus : bit_vector) return T_NATVEC;
	function pb_GetSubOrdinateBusID(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : BIT_VECTOR; DeviceShort : STRING) return NATURAL;
	function pb_GetSubOrdinateBusID(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : BIT_VECTOR; InterruptID : NATURAL) return NATURAL;
	procedure pb_AssignSubOrdinateBus(signal Output : inout T_PB_IOBUS_DEV_PB_VECTOR; Input : T_PB_IOBUS_DEV_PB_VECTOR; AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; SuperOrdinateBus : bit_vector; SubOrdinateBus : bit_vector);
	function pb_AssertAddressMapping(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR)													return BOOLEAN;
	function pb_ExportAddressMapping(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; tokenFileName : STRING)	return BOOLEAN;
end pb;


package body pb is
	-- private functions (must be declared before public functions)
	-- ===========================================================================
	function pb_DevName(name : string) return string is
	begin
		return resize(name, T_PB_ADDRESS_MAPPING.DeviceName'length);
	end function;
	
	function pb_DevShort(name : string) return string is
	begin
		return resize(name, T_PB_ADDRESS_MAPPING.DeviceShort'length);
	end function;

	-- public functions
	-- ===========================================================================
	function pb_NewMapping(
		devName					: STRING;
		devShort				: STRING;
		startAddress		: NATURAL;
		addressCount		: POSITIVE;
		BusAffiliation	: BIT_VECTOR										:= C_PB_BUSAFFILATION_NONE;
		InterruptID			: INTEGER												:= C_PB_INTERRUPT_NONE)
	return T_PB_ADDRESS_MAPPING is
		variable Result				: T_PB_ADDRESS_MAPPING;
	begin
		Result.PortID_Mappings			:= (OTHERS => C_PB_PORTID_MAPPING_EMPTY);
		
		for I in 0 to addressCount - 1 loop
			Result.PortID_Mappings(I)	:= (
				PortID	=> startAddress + I,
				RegID		=> I
			);
		end loop;

		Result.DeviceName				:= pb_DevName(devName);
		Result.DeviceShort			:= pb_DevShort(devShort);
		Result.MappingCount			:= addressCount;
		Result.PortID_KMappings	:= (others => C_PB_PORTID_KMAPPING_EMPTY);
		Result.KMappingCount		:= 0;
		Result.InterruptID			:= InterruptID;
		Result.BusAffiliation		:= C_PB_BUSAFFILATION_ANY OR BusAffiliation;
		
		return Result;
	end function;
	
	function pb_NewMapping(
		devName					: STRING;
		devShort				: STRING;
		startAddress		: NATURAL;
		addressCount		: POSITIVE;
		KMappings				: T_PB_PORTID_KMAPPING_VECTOR;
		BusAffiliation	: BIT_VECTOR										:= C_PB_BUSAFFILATION_NONE;
		InterruptID			: INTEGER												:= C_PB_INTERRUPT_NONE)
	return T_PB_ADDRESS_MAPPING is
		variable Result				: T_PB_ADDRESS_MAPPING;
	begin
		Result.PortID_Mappings			:= (OTHERS => C_PB_PORTID_MAPPING_EMPTY);
		
		for I in 0 to addressCount - 1 loop
			Result.PortID_Mappings(I)	:= (
				PortID	=> startAddress + I,
				RegID		=> I
			);
		end loop;
		
		if (KMappings'length > 0) then
			for i in KMappings'range loop
				Result.PortID_KMappings(i)	:= KMappings(i);
			end loop;
			Result.KMappingCount					:= KMappings'length;
		else
			Result.PortID_KMappings				:= (others => C_PB_PORTID_KMAPPING_EMPTY);
			Result.KMappingCount					:= 0;
		end if;
		
		Result.DeviceName				:= pb_DevName(devName);
		Result.DeviceShort			:= pb_DevShort(devShort);
		Result.MappingCount			:= addressCount;
		Result.InterruptID			:= InterruptID;
		Result.BusAffiliation		:= C_PB_BUSAFFILATION_ANY OR BusAffiliation;
		
		return Result;
	end function;
	
	function pb_DevName(name : string) return string is
	begin
		return resize(name, T_PB_ADDRESS_MAPPING.DeviceName'length);
	end function;
	
	function pb_DevShort(name : string) return string is
	begin
		return resize(name, T_PB_ADDRESS_MAPPING.DeviceShort'length);
	end function;
	
	function pb_GetAMIdx(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; DeviceShort : STRING) return NATURAL is
	begin
		for i in AddressMappingVector'range loop
			if str_match(AddressMappingVector(i).DeviceShort, DeviceShort) then
				return i;
			end if;
		end loop;
		report "Unknown device='" & DeviceShort & "'" severity failure;
	end function;
	
	function pb_HasIntID(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; index : NATURAL) return BOOLEAN is
	begin
		return (AddressMappingVector(index).InterruptID >= 0);
	end function;
	
	function pb_GetIntID(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; DeviceShort : STRING) return NATURAL is
	begin
		for i in AddressMappingVector'range loop
			if str_match(AddressMappingVector(i).DeviceShort, DeviceShort) then
				if (AddressMappingVector(i).InterruptID >= 0) then
					return AddressMappingVector(i).InterruptID;
				else
					report "No interrupt registered for device='" & DeviceShort & "'" severity failure;
				end if;
			end if;
		end loop;
		report "Unknown device='" & DeviceShort & "'" severity failure;
	end function;
	
	function pb_GetIntCount(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR) return NATURAL is
		variable Result		: NATURAL		:= 0;
	begin
		for i in AddressMappingVector'range loop
			if (AddressMappingVector(i).InterruptID >= 0) then
				Result	:= Result + 1;
			end if;
		end loop;
		return Result;
	end function;
	
	function pb_GetBusCount(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : bit_vector) return NATURAL is
		variable Result		: NATURAL		:= 0;
	begin
		for i in AddressMappingVector'range loop
			if ((AddressMappingVector(i).BusAffiliation AND BusAffiliation) = BusAffiliation) then
				Result	:= Result + 1;
			end if;
		end loop;
		return Result;
	end function;
	
	function pb_GetBusIndizes(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : bit_vector) return T_NATVEC is
		constant Count		: POSITIVE										:= pb_GetBusCount(AddressMappingVector, BusAffiliation);
		variable Result		: T_NATVEC(Count - 1 TO 0);
		variable Index		: NATURAL											:= 0;
	begin
		for i in AddressMappingVector'range loop
			if ((AddressMappingVector(i).BusAffiliation AND BusAffiliation) = BusAffiliation) then
				Result(Index)	:= i;
				Index					:= Index + 1;
			end if;
		end loop;
		return Result;
	end function;
	
	function pb_GetSubOrdinateBusIDs(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : bit_vector) return T_NATVEC is
		variable Result					: T_NATVEC(0 TO AddressMappingVector'length - 1);
		variable RunningIndex		: NATURAL																						:= 0;
		variable ResultCount		: NATURAL																						:= 0;
	begin
		for i in AddressMappingVector'range loop
			if ((AddressMappingVector(i).BusAffiliation AND BusAffiliation) = BusAffiliation) then
				Result(ResultCount)	:= RunningIndex;
				ResultCount					:= ResultCount + 1;
			end if;
			if (ResultCount > 0) then
				RunningIndex				:= RunningIndex + 1;
			end if;
		end loop;
		return Result(0 TO ResultCount - 1);
	end function;
	
	function pb_GetSuperOrdinateBusIDs(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; SuperOrdinateBus : bit_vector; SubOrdinateBus : bit_vector) return T_NATVEC is
		variable Result					: T_NATVEC(0 TO AddressMappingVector'length - 1);
		variable RunningIndex		: NATURAL																						:= 0;
		variable ResultCount		: NATURAL																						:= 0;
	begin
		for i in AddressMappingVector'range loop
			if ((AddressMappingVector(i).BusAffiliation AND SuperOrdinateBus) = SuperOrdinateBus) then
				if ((AddressMappingVector(i).BusAffiliation AND SubOrdinateBus) = SubOrdinateBus) then
					Result(ResultCount)	:= RunningIndex;
					ResultCount					:= ResultCount + 1;
				end if;
				RunningIndex				:= RunningIndex + 1;
			end if;
		end loop;
		return Result(0 TO ResultCount - 1);
	end function;
	
	function pb_GetSubOrdinateBusID(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : BIT_VECTOR; DeviceShort : STRING) return NATURAL is
		variable Result		: NATURAL		:= 0;
	begin
		for i in AddressMappingVector'range loop
			if ((AddressMappingVector(i).BusAffiliation AND BusAffiliation) = BusAffiliation) then
				if str_match(AddressMappingVector(i).DeviceShort, DeviceShort) then
					return Result;
				end if;
				Result	:= Result + 1;
			end if;
		end loop;
		report "Unknown device='" & DeviceShort & "'" severity failure;
	end function;
	
	function pb_GetSubOrdinateBusID(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : BIT_VECTOR; InterruptID : NATURAL) return NATURAL is
		variable Result		: NATURAL		:= 0;
	begin
		for i in AddressMappingVector'range loop
			if ((AddressMappingVector(i).BusAffiliation AND BusAffiliation) = BusAffiliation) then
				if (AddressMappingVector(i).InterruptID = InterruptID) then
					return Result;
				end if;
				Result	:= Result + 1;
			end if;
		end loop;
		report "Unknown InterruptID='" & INTEGER'image(InterruptID) & "'" severity failure;
	end function;
	
	function pb_GetSubOrdinateBus(Input : T_PB_IOBUS_PB_DEV_VECTOR; AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; BusAffiliation : bit_vector) return T_PB_IOBUS_PB_DEV_VECTOR is
		constant BusIndizes	: T_NATVEC	:= pb_GetSubOrdinateBusIDs(AddressMappingVector, BusAffiliation);
		variable Result			: T_PB_IOBUS_PB_DEV_VECTOR(BusIndizes'length - 1 DOWNTO 0);
	begin
		for i in BusIndizes'range loop
			Result(i)		:= Input(BusIndizes(i));
		end loop;
		return Result;
	end function;

	procedure pb_AssignSubOrdinateBus(signal Output : inout T_PB_IOBUS_DEV_PB_VECTOR; Input : T_PB_IOBUS_DEV_PB_VECTOR; AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; SuperOrdinateBus : bit_vector; SubOrdinateBus : bit_vector) is
		constant BusIndizes	: T_NATVEC	:= pb_GetSuperOrdinateBusIDs(AddressMappingVector, SuperOrdinateBus, SubOrdinateBus);
	begin
		for i in Input'range loop
			Output(BusIndizes(i))		<= Input(i);
		end loop;
		
	end procedure;
	
	function pb_AssertAddressMapping(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR) return BOOLEAN is
		variable AddressMap256	: T_BOOLVEC(0 to 255)		:= (others => FALSE);
		variable AddressMap16		: T_BOOLVEC(0 to 15)		:= (others => FALSE);
		variable MappingError		: BOOLEAN								:= FALSE;
	begin
		report "PicoBlaze address mapping check:" severity note;
		for i in AddressMappingVector'range loop
			for j in 0 to AddressMappingVector(i).MappingCount - 1 loop
				if (AddressMap256(AddressMappingVector(i).PortID_Mappings(j).PortID) = TRUE)	then		-- unused address
					report "  Error at: AMID=" & INTEGER'image(i) &
											 "    Device=" & str_trim(AddressMappingVector(i).DeviceName) &
											 "    PortID=" & INTEGER'image(AddressMappingVector(i).PortID_Mappings(j).PortID)
						severity error;
					MappingError	:= TRUE;
				else
					AddressMap256(AddressMappingVector(i).PortID_Mappings(j).PortID) := TRUE;
				end if;
			end loop;
			for j in 0 to AddressMappingVector(i).KMappingCount - 1 loop
				if (AddressMap16(AddressMappingVector(i).PortID_KMappings(j).PortID) = TRUE)	then		-- unused address
					report "  Error at: AMID=" & INTEGER'image(i) &
											 "    Device=" & str_trim(AddressMappingVector(i).DeviceName) &
											 "  K-PortID=" & INTEGER'image(AddressMappingVector(i).PortID_KMappings(j).PortID)
						severity error;
					MappingError	:= TRUE;
				else
					AddressMap16(AddressMappingVector(i).PortID_KMappings(j).PortID) := TRUE;
				end if;
			end loop;
		end loop;
		
		return not MappingError;
	end function;
	
	function pb_ExportAddressMapping(AddressMappingVector : T_PB_ADDRESS_MAPPING_VECTOR; tokenFileName : STRING) return boolean is
		constant prefixWrite		: STRING								:= "WR";
		constant prefixRead			: STRING								:= "RD";
		constant prefixWriteK		: STRING								:= "K";
		
		file tokenFile					: TEXT open WRITE_MODE is	tokenFileName;		-- declare ouput file
    variable tokenLine			: LINE;																			-- 
		variable PortID					: T_SLV_8;
	begin
		report "Exporting PicoBlaze address mappings to '" & tokenFileName & "'..." severity note;
		
		-- write file header
		write(tokenLine, "# SoFPGA - PortIDs");								writeline(tokenFile, tokenLine);
		write(tokenLine, "#");																writeline(tokenFile, tokenLine);
		write(tokenLine, "#");																writeline(tokenFile, tokenLine);
		write(tokenLine, "# ChipScope Token File Version");		writeline(tokenFile, tokenLine);
		write(tokenLine, "@FILE_VERSION=1.0.0");							writeline(tokenFile, tokenLine);
		write(tokenLine, "#");																writeline(tokenFile, tokenLine);
		write(tokenLine, "# Default token value");						writeline(tokenFile, tokenLine);
		write(tokenLine, "@DEFAULT_TOKEN=");									writeline(tokenFile, tokenLine);
		
		-- write per device entires
		for i in AddressMappingVector'range loop
			write(tokenLine, "#");																											writeline(tokenFile, tokenLine);
			write(tokenLine, "#" & str_trim(AddressMappingVector(i).DeviceName));				writeline(tokenFile, tokenLine);
			
			for j in 0 to AddressMappingVector(i).MappingCount - 1 loop
				PortID		:= to_slv(AddressMappingVector(i).PortID_Mappings(j).PortID, 8);
				-- Write
				write(tokenLine, prefixWrite & "_" & str_trim(AddressMappingVector(i).DeviceShort) & "=1" & to_string(PortID, 'h', 2));
				writeline(tokenFile, tokenLine);
				-- Read
				write(tokenLine, prefixRead & "_" & str_trim(AddressMappingVector(i).DeviceShort) & "=2" & to_string(PortID, 'h', 2));
				writeline(tokenFile, tokenLine);
			end loop;
			for j in 0 to AddressMappingVector(i).KMappingCount - 1 loop
				for k in 0 to 15 loop
					PortID	:= to_slv(k, 4) & to_slv(AddressMappingVector(i).PortID_KMappings(j).PortID, 4);
					-- WriteK
					write(tokenLine, prefixWriteK & "_" & str_trim(AddressMappingVector(i).DeviceShort) & "=4" & to_string(PortID, 'h', 2));
					writeline(tokenFile, tokenLine);
				end loop;
			end loop;
		end loop;
		file_close(tokenFile);
		
		return true;
	end function;
	
end package body;
