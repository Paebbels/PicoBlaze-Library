-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Patrick Lehmann
--
-- Module:					PicoBlaze Generic AddressDecoder Unit
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
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.io.all;

library	L_PicoBlaze;
use			L_PicoBlaze.pb.all;


entity PicoBlaze_AddressDecoder is
	generic (
		DEVICE_INSTANCE								: T_PB_DEVICE_INSTANCE
	);
	port (
		Clock													: in	STD_LOGIC;
		Reset													: in	STD_LOGIC;

		-- PicoBlaze interface
		In_WriteStrobe								: in	STD_LOGIC;
		In_WriteStrobe_K							: in	STD_LOGIC;
		In_ReadStrobe									: in	STD_LOGIC;
		In_Address										: in	T_SLV_8;
		In_Data												: in	T_SLV_8;
		Out_WriteStrobe								: out	STD_LOGIC;
		Out_ReadStrobe								: out	STD_LOGIC;
		Out_WriteAddress							: out	T_SLV_8;
		Out_ReadAddress								: out	T_SLV_8;
		Out_Data											: out	T_SLV_8
	);
end entity;


architecture rtl of PicoBlaze_AddressDecoder is
	attribute KEEP								: BOOLEAN;

	function filterMappings(DeviceInstance : T_PB_DEVICE_INSTANCE; MappingKind : T_PB_MAPPING_KIND) return T_PB_PORTNUMBER_MAPPING_VECTOR is
		variable Result				: T_PB_PORTNUMBER_MAPPING_VECTOR(0 to DeviceInstance.Mappings'length - 1);
		variable ResultCount	: NATURAL := 0;
	begin
		for i in DeviceInstance.Mappings'range loop
			if (DeviceInstance.Mappings(i).MappingKind = MappingKind) then
				Result(ResultCount)	:= DeviceInstance.Mappings(i);
				ResultCount					:= ResultCount + 1;
			end if;
		end loop;
		return Result(0 to ResultCount - 1);
	end function;

	signal WriteAddress						: T_SLV_8;
	signal WriteAddress_K					: T_SLV_8;
	signal ReadAddress						: T_SLV_8;
	signal WriteHit								: STD_LOGIC;
	signal WriteHit_K							: STD_LOGIC;
	signal ReadHit								: STD_LOGIC;

	signal Out_WriteStrobe_i			: STD_LOGIC			:= '0';
	signal Out_ReadStrobe_i				: STD_LOGIC;
	signal Out_WriteAddress_i			: T_SLV_8				:= (others => '0');
	signal Out_ReadAddress_i			: T_SLV_8;
	signal Out_Data_i							: T_SLV_8				:= (others => '0');
begin

	process(In_Address, In_WriteStrobe, In_WriteStrobe_K, In_ReadStrobe)
		constant READ_MAPPINGS		: T_PB_PORTNUMBER_MAPPING_VECTOR := filterMappings(DEVICE_INSTANCE, PB_MAPPING_KIND_READ);
		constant WRITE_MAPPINGS		: T_PB_PORTNUMBER_MAPPING_VECTOR := filterMappings(DEVICE_INSTANCE, PB_MAPPING_KIND_WRITE);
		constant WRITEK_MAPPINGS	: T_PB_PORTNUMBER_MAPPING_VECTOR := filterMappings(DEVICE_INSTANCE, PB_MAPPING_KIND_WRITEK);
	begin
		WriteAddress		<= x"00";
		WriteAddress_K	<= x"00";
		ReadAddress			<= x"00";
		WriteHit				<= '0';
		WriteHit_K			<= '0';
		ReadHit					<= '0';
		
		for i in WRITEK_MAPPINGS'range loop
			IF (In_Address(3 downto 0) = to_slv(WRITEK_MAPPINGS(i).PortNumber, 4)) then
				WriteAddress_K		<= to_slv(WRITEK_MAPPINGS(i).RegID, WriteAddress'length);
				WriteHit_K				<= In_WriteStrobe_K;
			end if;
		end loop;
		for i in WRITE_MAPPINGS'range loop
			if (In_Address = to_slv(WRITE_MAPPINGS(i).PortNumber, In_Address'length)) then
				WriteAddress			<= to_slv(WRITE_MAPPINGS(i).RegID, WriteAddress'length);
				WriteHit					<= In_WriteStrobe;
			end if;
		end loop;
		for i in READ_MAPPINGS'range loop
			if (In_Address = to_slv(READ_MAPPINGS(i).PortNumber, In_Address'length)) then
				ReadAddress			<= to_slv(READ_MAPPINGS(i).RegID, ReadAddress'length);
				ReadHit					<= In_ReadStrobe;
			end if;
		end loop;
	end process;
	
	Out_WriteStrobe_i		<= WriteHit OR WriteHit_K																				when rising_edge(Clock);
	Out_ReadStrobe_i		<= ReadHit;
	Out_WriteAddress_i	<= ite((In_WriteStrobe_K = '1'), WriteAddress_K, WriteAddress)	when rising_edge(Clock);
	Out_ReadAddress_i		<= ReadAddress;
	Out_Data_i					<= In_Data																											when rising_edge(Clock);
	
	Out_WriteStrobe			<= Out_WriteStrobe_i;
	Out_ReadStrobe			<= Out_ReadStrobe_i;
	Out_WriteAddress		<= Out_WriteAddress_i;
	Out_ReadAddress			<= Out_ReadAddress_i;
	Out_Data						<= Out_Data_i;
end;
