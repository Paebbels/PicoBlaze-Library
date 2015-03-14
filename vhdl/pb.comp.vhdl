-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Patrick Lehmann
-- 
-- Package:					VHDL package for TODO
--									TODO
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


library IEEE;
use			IEEE.NUMERIC_STD.all;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.STD_LOGIC_TEXTIO.all;

package pb_comp is

	component main_Page0 is
		port (
			Clock										: in	std_logic;
			Fetch										: in	std_logic;
			Address									: in	std_logic_vector(11 downto 0);
			Instruction							: out	std_logic_vector(17 downto 0);
			
			JTAGLoader_Clock				: in	std_logic;
			JTAGLoader_Enable				: in	std_logic;
			JTAGLoader_Address			: in	std_logic_vector(11 downto 0);
			JTAGLoader_WriteEnable	: in	std_logic;
			JTAGLoader_DataIn				: in	std_logic_vector(17 downto 0);
			JTAGLoader_DataOut			: out	std_logic_vector(17 downto 0)
		);
	end component;
	
	component main_Page1 is
		port (
			Clock										: in	std_logic;
			Fetch										: in	std_logic;
			Address									: in	std_logic_vector(11 downto 0);
			Instruction							: out	std_logic_vector(17 downto 0);
			
			JTAGLoader_Clock				: in	std_logic;
			JTAGLoader_Enable				: in	std_logic;
			JTAGLoader_Address			: in	std_logic_vector(11 downto 0);
			JTAGLoader_WriteEnable	: in	std_logic;
			JTAGLoader_DataIn				: in	std_logic_vector(17 downto 0);
			JTAGLoader_DataOut			: out	std_logic_vector(17 downto 0)
		);
	end component;
	
	component main_Page2 is
		port (
			Clock										: in	std_logic;
			Fetch										: in	std_logic;
			Address									: in	std_logic_vector(11 downto 0);
			Instruction							: out	std_logic_vector(17 downto 0);
			
			JTAGLoader_Clock				: in	std_logic;
			JTAGLoader_Enable				: in	std_logic;
			JTAGLoader_Address			: in	std_logic_vector(11 downto 0);
			JTAGLoader_WriteEnable	: in	std_logic;
			JTAGLoader_DataIn				: in	std_logic_vector(17 downto 0);
			JTAGLoader_DataOut			: out	std_logic_vector(17 downto 0)
		);
	end component;
	
	component main_Page3 is
		port (
			Clock										: in	std_logic;
			Fetch										: in	std_logic;
			Address									: in	std_logic_vector(11 downto 0);
			Instruction							: out	std_logic_vector(17 downto 0);
			
			JTAGLoader_Clock				: in	std_logic;
			JTAGLoader_Enable				: in	std_logic;
			JTAGLoader_Address			: in	std_logic_vector(11 downto 0);
			JTAGLoader_WriteEnable	: in	std_logic;
			JTAGLoader_DataIn				: in	std_logic_vector(17 downto 0);
			JTAGLoader_DataOut			: out	std_logic_vector(17 downto 0)
		);
	end component;
	
	component main_Page4 is
		port (
			Clock										: in	std_logic;
			Fetch										: in	std_logic;
			Address									: in	std_logic_vector(11 downto 0);
			Instruction							: out	std_logic_vector(17 downto 0);
			
			JTAGLoader_Clock				: in	std_logic;
			JTAGLoader_Enable				: in	std_logic;
			JTAGLoader_Address			: in	std_logic_vector(11 downto 0);
			JTAGLoader_WriteEnable	: in	std_logic;
			JTAGLoader_DataIn				: in	std_logic_vector(17 downto 0);
			JTAGLoader_DataOut			: out	std_logic_vector(17 downto 0)
		);
	end component;
	
	component main_Page5 is
		port (
			Clock										: in	std_logic;
			Fetch										: in	std_logic;
			Address									: in	std_logic_vector(11 downto 0);
			Instruction							: out	std_logic_vector(17 downto 0);
			
			JTAGLoader_Clock				: in	std_logic;
			JTAGLoader_Enable				: in	std_logic;
			JTAGLoader_Address			: in	std_logic_vector(11 downto 0);
			JTAGLoader_WriteEnable	: in	std_logic;
			JTAGLoader_DataIn				: in	std_logic_vector(17 downto 0);
			JTAGLoader_DataOut			: out	std_logic_vector(17 downto 0)
		);
	end component;
	
	component main_Page6 is
		port (
			Clock										: in	std_logic;
			Fetch										: in	std_logic;
			Address									: in	std_logic_vector(11 downto 0);
			Instruction							: out	std_logic_vector(17 downto 0);
			
			JTAGLoader_Clock				: in	std_logic;
			JTAGLoader_Enable				: in	std_logic;
			JTAGLoader_Address			: in	std_logic_vector(11 downto 0);
			JTAGLoader_WriteEnable	: in	std_logic;
			JTAGLoader_DataIn				: in	std_logic_vector(17 downto 0);
			JTAGLoader_DataOut			: out	std_logic_vector(17 downto 0)
		);
	end component;
	
	component main_Page7 is
		port (
			Clock										: in	std_logic;
			Fetch										: in	std_logic;
			Address									: in	std_logic_vector(11 downto 0);
			Instruction							: out	std_logic_vector(17 downto 0);
			
			JTAGLoader_Clock				: in	std_logic;
			JTAGLoader_Enable				: in	std_logic;
			JTAGLoader_Address			: in	std_logic_vector(11 downto 0);
			JTAGLoader_WriteEnable	: in	std_logic;
			JTAGLoader_DataIn				: in	std_logic_vector(17 downto 0);
			JTAGLoader_DataOut			: out	std_logic_vector(17 downto 0)
		);
	end component;
end pb_comp;


package body pb_comp is
	
end package body;
