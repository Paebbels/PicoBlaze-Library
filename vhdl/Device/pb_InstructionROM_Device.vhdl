-- EMACS settings: -*-	tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- =============================================================================
--	 ____  _           ____  _                 _     _ _                          
--	|  _ \(_) ___ ___ | __ )| | __ _ _______  | |   (_) |__  _ __ __ _ _ __ _   _ 
--	| |_) | |/ __/ _ \|  _ \| |/ _` |_  / _ \ | |   | | '_ \| '__/ _` | '__| | | |
--	|  __/| | (_| (_) | |_) | | (_| |/ /  __/ | |___| | |_) | | | (_| | |  | |_| |
--	|_|   |_|\___\___/|____/|_|\__,_/___\___| |_____|_|_.__/|_|  \__,_|_|   \__, |
--	                                                                        |___/ 
-- =============================================================================
-- Authors:					Patrick Lehmann
--
-- Module:					Wrapper module for up to 8 PicoBlaze ROM pages. All ROMs are
--									reprogrammable via JTAG_Loader
--
-- Description:
-- ------------------------------------
--		TODO
-- 
-- 
-- License:
-- -----------------------------------------------------------------------------
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
-- =============================================================================

library	IEEE;
use			IEEE.STD_LOGIC_1164.all;
use			IEEE.NUMERIC_STD.all;
  
library PoC;
use			PoC.config.all;
use			PoC.utils.all;
use			PoC.vectors.all;
use			PoC.strings.all;
use			PoC.components.all;
use			PoC.ocram.all;
use			PoC.ocrom.all;

library L_PicoBlaze;
use			L_PicoBlaze.pb.all;
use			L_PicoBlaze.pb_comp.all;


entity pb_InstructionROM_Device is
	generic (
		PAGES								: POSITIVE							:= 1;
		SOURCE_DIRECTORY		: STRING								:= "";
		DEVICE_INSTANCE			: T_PB_DEVICE_INSTANCE;
		ENABLE_JTAG_LOADER      : BOOLEAN								:= FALSE;
		ENABLE_AXI_LOADER       : BOOLEAN								:= FALSE
	);
	port (
		Clock								: in	STD_LOGIC;
		Fetch								: in	STD_LOGIC;
		InstructionPointer	: in	T_PB_ADDRESS;
		Instruction					: out T_PB_INSTRUCTION;
		Reboot							: out STD_LOGIC;
		
		-- PicoBlaze interface
		Address							: in	T_SLV_8;
		WriteStrobe					: in	STD_LOGIC;
		WriteStrobe_K				: in	STD_LOGIC;
		ReadStrobe					: in	STD_LOGIC;
		DataIn							: in	T_SLV_8;
		DataOut							: out	T_SLV_8;
		
		Interrupt						: out	STD_LOGIC;
		Interrupt_Ack				: in	STD_LOGIC;
		Message							: out T_SLV_8;
		
		PageNumber					: out	STD_LOGIC_VECTOR(2 downto 0)
	);
end entity;


architecture rtl of pb_InstructionROM_Device is
	type T_PB_INSTRUCTION_VECTOR	is array (NATURAL range <>) of T_PB_INSTRUCTION;

	function reverse(vec : T_PB_INSTRUCTION_VECTOR) return T_PB_INSTRUCTION_VECTOR is
		variable res : T_PB_INSTRUCTION_VECTOR(vec'range);
	begin
		for i in vec'low to vec'high loop
			res(vec'low + (vec'high - i)) := vec(i);
		end loop;
		return	res;
	end function;

	constant ENABLE_LOADER				: BOOLEAN		:= ite((VENDOR = VENDOR_XILINX), ENABLE_JTAG_LOADER, FALSE);
	constant FILENAME_PATTERN			: STRING		:= ite((VENDOR = VENDOR_ALTERA), "main_Page#.mif", "main_Page#.hex");
	
	constant REG_RW_PAGE_NUMBER		: STD_LOGIC_VECTOR(0 downto 0)			:= "0";

	signal AdrDec_we							: STD_LOGIC;
	signal AdrDec_re							: STD_LOGIC;
	signal AdrDec_WriteAddress		: T_SLV_8;
	signal AdrDec_ReadAddress			: T_SLV_8;
	signal AdrDec_Data						: T_SLV_8;

	signal Reg_PageNumber					: T_SLV_8																		:= (others => '0');
	signal Reg_PageNumber_us			: UNSIGNED(log2ceilnz(PAGES) - 1 downto 0)	:= (others => '0');
	
	signal Page_Instructions			: T_PB_INSTRUCTION_VECTOR(PAGES - 1 downto 0);
	signal Pages_DataOut					: T_PB_INSTRUCTION_VECTOR(PAGES - 1 downto 0);
	
	signal JTAGLoader_Clock				: STD_LOGIC;
	signal JTAGLoader_Enable			: STD_LOGIC_VECTOR(PAGES - 1 downto 0);
	signal JTAGLoader_Address			: T_PB_ADDRESS;
	signal JTAGLoader_WriteEnable	: STD_LOGIC;
	signal JTAGLoader_DataOut			: T_PB_INSTRUCTION;
	
begin
	assert (PAGES <= 8) report "This ROM and JTAGLoader6 support 8 pages maximum." severity FAILURE;

	AdrDec : entity L_PicoBlaze.PicoBlaze_AddressDecoder
		generic map (
			DEVICE_NAME				=> str_trim(DEVICE_INSTANCE.DeviceShort),
			BUS_NAME					=> str_trim(DEVICE_INSTANCE.BusShort),
			READ_MAPPINGS			=> pb_FilterMappings(DEVICE_INSTANCE, PB_MAPPING_KIND_READ),
			WRITE_MAPPINGS		=> pb_FilterMappings(DEVICE_INSTANCE, PB_MAPPING_KIND_WRITE),
			WRITEK_MAPPINGS		=> pb_FilterMappings(DEVICE_INSTANCE, PB_MAPPING_KIND_WRITEK)
		)
		port map (
			Clock							=> Clock,
			Reset							=> Reboot,

			-- PicoBlaze interface
			In_WriteStrobe		=> WriteStrobe,
			In_WriteStrobe_K	=> WriteStrobe_K,
			In_ReadStrobe			=> ReadStrobe,
			In_Address				=> Address,
			In_Data						=> DataIn,
			Out_WriteStrobe		=> AdrDec_we,
			Out_ReadStrobe		=> AdrDec_re,
			Out_WriteAddress	=> AdrDec_WriteAddress,
			Out_ReadAddress		=> AdrDec_ReadAddress,
			Out_Data					=> AdrDec_Data
		);

	-- Registers
	process(Clock)
	begin
		if rising_edge(Clock) then
			if (Reboot = '1') then
				Reg_PageNumber		<= (others => '0');
			elsif (AdrDec_we = '1') then
				case AdrDec_WriteAddress(0 downto 0) is
					when REG_RW_PAGE_NUMBER =>	Reg_PageNumber		<= AdrDec_Data;
					when others =>							null;
				end case;
			end if;
		end if;
	end process;

	process(AdrDec_re, AdrDec_ReadAddress, Reg_PageNumber)
	begin
		case AdrDec_ReadAddress(0 downto 0) IS
			when REG_RW_PAGE_NUMBER =>		DataOut		<= Reg_PageNumber;
			when others =>								DataOut		<= Reg_PageNumber;
		end case;
	end process;
	
	Interrupt   <= '0';
	Message     <= x"00";
	
	-- 
	PageNumber        <= Reg_PageNumber(PageNumber'range);
	Reg_PageNumber_us <= unsigned(Reg_PageNumber(Reg_PageNumber_us'range));

	Instruction       <= Page_Instructions(to_index(Reg_PageNumber_us, Page_Instructions'length));
	
	genTemplate : if (str_length(SOURCE_DIRECTORY) = 0) generate
		genPage0 : if (TRUE) generate
			constant PAGE_NUMBER		: NATURAL := 0;
			constant PAGE_INDEX			: NATURAL	:= imin(PAGES - 1, PAGE_NUMBER);
		begin
			page : main_Page0
				port map (
					Clock										=> Clock,
					Fetch										=> Fetch,
					Address									=> InstructionPointer,
					Instruction							=> Page_Instructions(PAGE_INDEX),
					
					JTAGLoader_Clock				=> JTAGLoader_Clock,
					JTAGLoader_Enable				=> JTAGLoader_Enable(PAGE_INDEX),
					JTAGLoader_Address			=> JTAGLoader_Address,
					JTAGLoader_WriteEnable	=> JTAGLoader_WriteEnable,
					JTAGLoader_DataOut			=> Pages_DataOut(PAGE_INDEX),
					JTAGLoader_DataIn				=> JTAGLoader_DataOut
				);
		end generate;
		
		genPage1 : if (PAGES > 1) generate
			constant PAGE_NUMBER		: NATURAL := 1;
			constant PAGE_INDEX			: NATURAL	:= imin(PAGES - 1, PAGE_NUMBER);
		begin
			page : main_Page1
				port map (
					Clock										=> Clock,
					Fetch										=> Fetch,
					Address									=> InstructionPointer,
					Instruction							=> Page_Instructions(PAGE_INDEX),
					
					JTAGLoader_Clock				=> JTAGLoader_Clock,
					JTAGLoader_Enable				=> JTAGLoader_Enable(PAGE_INDEX),
					JTAGLoader_Address			=> JTAGLoader_Address,
					JTAGLoader_WriteEnable	=> JTAGLoader_WriteEnable,
					JTAGLoader_DataOut			=> Pages_DataOut(PAGE_INDEX),
					JTAGLoader_DataIn				=> JTAGLoader_DataOut
				);
		end generate;
		
		genPage2 : if (PAGES > 2) generate
			constant PAGE_NUMBER		: NATURAL := 2;
			constant PAGE_INDEX			: NATURAL	:= imin(PAGES - 1, PAGE_NUMBER);
		begin
			page : main_Page2
				port map (
					Clock										=> Clock,
					Fetch										=> Fetch,
					Address									=> InstructionPointer,
					Instruction							=> Page_Instructions(PAGE_INDEX),
					
					JTAGLoader_Clock				=> JTAGLoader_Clock,
					JTAGLoader_Enable				=> JTAGLoader_Enable(PAGE_INDEX),
					JTAGLoader_Address			=> JTAGLoader_Address,
					JTAGLoader_WriteEnable	=> JTAGLoader_WriteEnable,
					JTAGLoader_DataOut			=> Pages_DataOut(PAGE_INDEX),
					JTAGLoader_DataIn				=> JTAGLoader_DataOut
				);
		end generate;
		
		genPage3 : if (PAGES > 3) generate
			constant PAGE_NUMBER		: NATURAL := 3;
			constant PAGE_INDEX			: NATURAL	:= imin(PAGES - 1, PAGE_NUMBER);
		begin
			page : main_Page3
				port map (
					Clock										=> Clock,
					Fetch										=> Fetch,
					Address									=> InstructionPointer,
					Instruction							=> Page_Instructions(PAGE_INDEX),
					
					JTAGLoader_Clock				=> JTAGLoader_Clock,
					JTAGLoader_Enable				=> JTAGLoader_Enable(PAGE_INDEX),
					JTAGLoader_Address			=> JTAGLoader_Address,
					JTAGLoader_WriteEnable	=> JTAGLoader_WriteEnable,
					JTAGLoader_DataOut			=> Pages_DataOut(PAGE_INDEX),
					JTAGLoader_DataIn				=> JTAGLoader_DataOut
				);
		end generate;
		
		genPage4 : if (PAGES > 4) generate
			constant PAGE_NUMBER		: NATURAL := 4;
			constant PAGE_INDEX			: NATURAL	:= imin(PAGES - 1, PAGE_NUMBER);
		begin
			page : main_Page4
				port map (
					Clock										=> Clock,
					Fetch										=> Fetch,
					Address									=> InstructionPointer,
					Instruction							=> Page_Instructions(PAGE_INDEX),
					
					JTAGLoader_Clock				=> JTAGLoader_Clock,
					JTAGLoader_Enable				=> JTAGLoader_Enable(PAGE_INDEX),
					JTAGLoader_Address			=> JTAGLoader_Address,
					JTAGLoader_WriteEnable	=> JTAGLoader_WriteEnable,
					JTAGLoader_DataOut			=> Pages_DataOut(PAGE_INDEX),
					JTAGLoader_DataIn				=> JTAGLoader_DataOut
				);
		end generate;
		
		genPage5 : if (PAGES > 5) generate
			constant PAGE_NUMBER		: NATURAL := 5;
			constant PAGE_INDEX			: NATURAL	:= imin(PAGES - 1, PAGE_NUMBER);
		begin
			page : main_Page5
				port map (
					Clock										=> Clock,
					Fetch										=> Fetch,
					Address									=> InstructionPointer,
					Instruction							=> Page_Instructions(PAGE_INDEX),
					
					JTAGLoader_Clock				=> JTAGLoader_Clock,
					JTAGLoader_Enable				=> JTAGLoader_Enable(PAGE_INDEX),
					JTAGLoader_Address			=> JTAGLoader_Address,
					JTAGLoader_WriteEnable	=> JTAGLoader_WriteEnable,
					JTAGLoader_DataOut			=> Pages_DataOut(PAGE_INDEX),
					JTAGLoader_DataIn				=> JTAGLoader_DataOut
				);
		end generate;
		
		genPage6 : if (PAGES > 6) generate
			constant PAGE_NUMBER		: NATURAL := 6;
			constant PAGE_INDEX			: NATURAL	:= imin(PAGES - 1, PAGE_NUMBER);
		begin
			page : main_Page6
				port map (
					Clock										=> Clock,
					Fetch										=> Fetch,
					Address									=> InstructionPointer,
					Instruction							=> Page_Instructions(PAGE_INDEX),
					
					JTAGLoader_Clock				=> JTAGLoader_Clock,
					JTAGLoader_Enable				=> JTAGLoader_Enable(PAGE_INDEX),
					JTAGLoader_Address			=> JTAGLoader_Address,
					JTAGLoader_WriteEnable	=> JTAGLoader_WriteEnable,
					JTAGLoader_DataOut			=> Pages_DataOut(PAGE_INDEX),
					JTAGLoader_DataIn				=> JTAGLoader_DataOut
				);
		end generate;
		
		genPage7 : if (PAGES > 7) generate
			constant PAGE_NUMBER		: NATURAL := 7;
			constant PAGE_INDEX			: NATURAL	:= imin(PAGES - 1, PAGE_NUMBER);
		begin
			page : main_Page7
				port map (
					Clock										=> Clock,
					Fetch										=> Fetch,
					Address									=> InstructionPointer,
					Instruction							=> Page_Instructions(PAGE_INDEX),
					
					JTAGLoader_Clock				=> JTAGLoader_Clock,
					JTAGLoader_Enable				=> JTAGLoader_Enable(PAGE_INDEX),
					JTAGLoader_Address			=> JTAGLoader_Address,
					JTAGLoader_WriteEnable	=> JTAGLoader_WriteEnable,
					JTAGLoader_DataOut			=> Pages_DataOut(PAGE_INDEX),
					JTAGLoader_DataIn				=> JTAGLoader_DataOut
				);
		end generate;
	end generate;
	genLoadFile : if (str_length(SOURCE_DIRECTORY) /= 0) generate
		genPages : for i in 0 to PAGES - 1  generate
			constant FILENAME			: STRING		:= SOURCE_DIRECTORY & str_replace(FILENAME_PATTERN, "#", INTEGER'image(i));
			
			signal Port1_Address	: UNSIGNED(InstructionPointer'range);
			signal Port2_Address	: UNSIGNED(JTAGLoader_Address'range);
			
		begin
			assert PB_VERBOSE report "Loading ROM file: '" & FILENAME & "'" severity NOTE;

			genOCROM : if (ENABLE_LOADER = FALSE) generate
				Port1_Address		<= unsigned(InstructionPointer);
			
				genericMemory : ocrom_sp
					generic map (
						A_BITS		=> 12,
						D_BITS		=> 18,
						FILENAME	=> FILENAME
					)
					port map (
						clk		=> Clock,
						ce		=> Fetch,
						a			=> Port1_Address,
						q			=> Page_Instructions(i)
					);
			end generate;
			genOCRAM : if (ENABLE_LOADER = TRUE) generate
				Port1_Address		<= unsigned(InstructionPointer);
				Port2_Address		<= unsigned(JTAGLoader_Address);
			
				genericMemory : ocram_tdp
					generic map (
						A_BITS		=> 12,
						D_BITS		=> 18,
						FILENAME	=> FILENAME
					)
					port map (
						clk1	=> Clock,
						ce1		=> Fetch,
						we1		=> '0',
						a1		=> Port1_Address,
						d1		=> (others => '0'),
						q1		=> Page_Instructions(i),
						
						clk2	=> JTAGLoader_Clock,
						ce2		=> JTAGLoader_Enable(i),
						we2		=> JTAGLoader_WriteEnable,
						a2		=> Port2_Address,
						d2		=> JTAGLoader_DataOut,
						q2		=> Pages_DataOut(i)
					);
			end generate;
		end generate;
	end generate;
	
	genNoLoader : if ((ENABLE_JTAG_LOADER or ENABLE_AXI_LOADER) = FALSE) generate
		JTAGLoader_Clock				<= '0';
		JTAGLoader_Enable				<= (others => '0');
		JTAGLoader_Address			<= (others => '0');
		JTAGLoader_WriteEnable	<= '0';
		JTAGLoader_DataOut			<= (others => '0');
		
		Reboot                  <= '0';
	end generate;
	genJTAGLoader : if (ENABLE_JTAG_LOADER = TRUE) generate
		signal WorkAround_Enable			: STD_LOGIC_VECTOR(PAGES - 1 downto 0);
		signal WorkAround_DataIn			: T_PB_INSTRUCTION_VECTOR(PAGES - 1 downto 0);
		
		signal JTAGLoader_PB_Reset		: STD_LOGIC_VECTOR(PAGES - 1 downto 0);
		
		signal Page_n_rst							: STD_LOGIC;
		signal Page_0_rst							: STD_LOGIC;
		signal Page_n_rst_d						: STD_LOGIC		:= '0';
		signal Page_0_rst_d						: STD_LOGIC		:= '0';
		signal Page_n_rst_re					: STD_LOGIC;
		signal Page_0_rst_fe					: STD_LOGIC;
		signal Reset_r								: STD_LOGIC		:= '0';
	begin
		JTAGLoader : JTAGLoader6
			generic map (
				C_NUM_PICOBLAZE		=> PAGES,
				C_ADDR_WIDTH			=> (others => T_PB_ADDRESS'length)
			)
			port map (
				jtag_clk				=> JTAGLoader_Clock,
				jtag_en					=> WorkAround_Enable,
				jtag_din				=> JTAGLoader_DataOut,
				jtag_addr				=> JTAGLoader_Address,
				jtag_we					=> JTAGLoader_WriteEnable,
				jtag_dout_0			=> WorkAround_DataIn(imin(PAGES - 1, 0)),
				jtag_dout_1			=> WorkAround_DataIn(imin(PAGES - 1, 1)),
				jtag_dout_2			=> WorkAround_DataIn(imin(PAGES - 1, 2)),
				jtag_dout_3			=> WorkAround_DataIn(imin(PAGES - 1, 3)),
				jtag_dout_4			=> WorkAround_DataIn(imin(PAGES - 1, 4)),
				jtag_dout_5			=> WorkAround_DataIn(imin(PAGES - 1, 5)),
				jtag_dout_6			=> WorkAround_DataIn(imin(PAGES - 1, 6)),
				jtag_dout_7			=> WorkAround_DataIn(imin(PAGES - 1, 7)),
				picoblaze_reset	=> JTAGLoader_PB_Reset
			);
		
		-- work around for a bug in JTAGLoader.exe
		WorkAround_DataIn		<= reverse(Pages_DataOut);
		JTAGLoader_Enable		<= reverse(WorkAround_Enable);
		
		-- Reset control: keep PB in reset while programming, release after last ROM is written => reboot
		Page_n_rst		<= JTAGLoader_PB_Reset(PAGES - 1);
		Page_0_rst		<= JTAGLoader_PB_Reset(0);
		Page_n_rst_d	<= Page_n_rst	when rising_edge(Clock);
		Page_0_rst_d	<= Page_0_rst	when rising_edge(Clock);
		Page_n_rst_re	<= not Page_n_rst_d and Page_n_rst;
		Page_0_rst_fe	<= Page_0_rst_d and not Page_0_rst;
		
		Reset_r				<= ffrs(q => Reset_r, set => Page_n_rst_re, rst => Page_0_rst_fe) when rising_edge(Clock);
		Reboot				<= Reset_r;
	end generate;
	genAXILoader : if (ENABLE_AXI_LOADER = TRUE) generate
		component PB_JTAG_AXIMaster is
			port (
				aclk          : in  std_logic;
				aresetn       : in  std_logic;
				m_axi_awaddr  : out std_logic_vector(31 downto 0);
				m_axi_awprot  : out std_logic_vector(2 downto 0);
				m_axi_awvalid : out std_logic;
				m_axi_awready : in  std_logic;
				m_axi_wdata   : out std_logic_vector(31 downto 0);
				m_axi_wstrb   : out std_logic_vector(3 downto 0);
				m_axi_wvalid  : out std_logic;
				m_axi_wready  : in  std_logic;
				m_axi_bresp   : in  std_logic_vector(1 downto 0);
				m_axi_bvalid  : in  std_logic;
				m_axi_bready  : out std_logic;
				m_axi_araddr  : out std_logic_vector(31 downto 0);
				m_axi_arprot  : out std_logic_vector(2 downto 0);
				m_axi_arvalid : out std_logic;
				m_axi_arready : in  std_logic;
				m_axi_rdata   : in  std_logic_vector(31 downto 0);
				m_axi_rresp   : in  std_logic_vector(1 downto 0);
				m_axi_rvalid  : in  std_logic;
				m_axi_rready  : out std_logic
			);
		end component;
	
		component AXI_ILA is
			port (
				clk     : in  std_logic;
				probe0  : in  std_logic_vector(1 downto 0);
				probe1  : in  std_logic_vector(15 downto 0);
				probe2  : in  std_logic_vector(1 downto 0);
				probe3  : in  std_logic_vector(17 downto 0);
				probe4  : in  std_logic_vector(1 downto 0);
				probe5  : in  std_logic_vector(1 downto 0);
				probe6  : in  std_logic_vector(15 downto 0);
				probe7  : in  std_logic_vector(1 downto 0);
				probe8  : in  std_logic_vector(17 downto 0)
			);
		end component;
		
		signal AXIMaster_WriteAddress_Valid      : std_logic;
		signal AXIMaster_WriteAddress_Address    : std_logic_vector(31 downto 0);
		signal WriteAddress_Ack                  : std_logic;
		signal AXIMaster_WriteData_Valid         : std_logic;
		signal AXIMaster_WriteData_Data          : std_logic_vector(31 downto 0);
		signal WriteData_Ack                     : std_logic;
		signal WriteResponse_Valid               : std_logic;
		signal WriteResponse_Response            : std_logic_vector(1 downto 0);
		signal AXIMaster_WriteResponse_Ack       : std_logic;
		signal AXIMaster_ReadAddress_Valid       : std_logic;
		signal AXIMaster_ReadAddress_Address     : std_logic_vector(31 downto 0);
		signal ReadAddress_Ack                   : std_logic;
		signal ReadData_Valid                    : std_logic;
		signal ReadData_Data                     : std_logic_vector(31 downto 0);
		signal ReadData_Response                 : std_logic_vector(1 downto 0);
		signal AXIMaster_ReadData_Ack            : std_logic;
		
		signal ReadAddress_en                    : std_logic;
		signal WriteAddress_en                   : std_logic;
		signal WriteAddress_inc                  : std_logic;
		signal Address_r                         : std_logic_vector(15 downto 0) := (others => '0');
		signal WriteStatus_en                    : std_logic;
		signal Status_r                          : std_logic_vector(0 downto 0)  := (others => '0');
		
		type T_STATE is (ST_IDLE, ST_READING_1, ST_READING_2, ST_WRITING_1, ST_WRITING_2, ST_RESPONDING);
		signal CurrentState : T_STATE := ST_IDLE;
		signal NextState    : T_STATE;
		
	begin
		JTAG: pb_JTAG_AXIMaster
			port map (
				aclk          => Clock,
				aresetn       => '1',
				m_axi_awvalid => AXIMaster_WriteAddress_Valid,
				m_axi_awaddr  => AXIMaster_WriteAddress_Address,
				m_axi_awprot  => open,
				m_axi_awready => WriteAddress_Ack,
				
				m_axi_wvalid  => AXIMaster_WriteData_Valid,
				m_axi_wdata   => AXIMaster_WriteData_Data,
				m_axi_wstrb   => open,
				m_axi_wready  => WriteData_Ack,
				
				m_axi_bvalid  => WriteResponse_Valid,
				m_axi_bresp   => WriteResponse_Response,
				m_axi_bready  => AXIMaster_WriteResponse_Ack,
				
				m_axi_arvalid => AXIMaster_ReadAddress_Valid,
				m_axi_araddr  => AXIMaster_ReadAddress_Address,
				m_axi_arprot  => open,
				m_axi_arready => ReadAddress_Ack,

				m_axi_rvalid  => ReadData_Valid,
				m_axi_rdata   => ReadData_Data,
				m_axi_rresp   => ReadData_Response,
				m_axi_rready  => AXIMaster_ReadData_Ack
			);
		
		AXIDbg: AXI_ILA
			port map (
				clk     => Clock,
				probe0  => WriteAddress_Ack & AXIMaster_WriteAddress_Valid,
				probe1  => AXIMaster_WriteAddress_Address(15 downto 0),
				probe2  => WriteData_Ack & AXIMaster_WriteData_Valid,
				probe3  => AXIMaster_WriteData_Data(17 downto 0),
				probe4  => AXIMaster_WriteResponse_Ack & WriteResponse_Valid,
				probe5  => ReadAddress_Ack & AXIMaster_ReadAddress_Valid,
				probe6  => AXIMaster_ReadAddress_Address(15 downto 0),
				probe7  => AXIMaster_ReadData_Ack & ReadData_Valid,
				probe8  => ReadData_Data(17 downto 0)
			);
		
		JTAGLoader_Clock <= Clock;
		
		process(Clock)
		begin
			if rising_edge(Clock) then
				CurrentState <= NextState;
			end if;
		end process;
		
		process(CurrentState, Pages_DataOut, Address_r,
		        AXIMaster_WriteAddress_Valid, AXIMaster_WriteAddress_Address,
		        AXIMaster_WriteData_Valid, AXIMaster_WriteData_Data,
		        AXIMaster_WriteResponse_Ack,
						AXIMaster_ReadAddress_Valid,
						AXIMaster_ReadData_Ack)
			constant PAGE_ADDRESS_BITS : positive := log2ceilnz(PAGES);
		begin
			NextState               <= CurrentState;
		
			JTAGLoader_Enable       <= bin2onehot(Address_r(JTAGLoader_Address'length + PAGE_ADDRESS_BITS - 1 downto JTAGLoader_Address'length));
			JTAGLoader_WriteEnable  <= '0';
			JTAGLoader_Address      <= Address_r(JTAGLoader_Address'range);
			JTAGLoader_DataOut(15 downto 0)   <= AXIMaster_WriteData_Data(JTAGLoader_DataOut'high - 2 downto JTAGLoader_DataOut'low);
			JTAGLoader_DataOut(17 downto 16)  <= AXIMaster_WriteAddress_Address(25 downto 24);
			
			WriteAddress_Ack        <= '0';
			WriteData_Ack           <= '0';
			WriteResponse_Valid     <= '0';
			WriteResponse_Response  <= "00";
			ReadAddress_Ack         <= '0';
			ReadData_Valid          <= '0';
			ReadData_Data           <= (31 downto 18 => '0') & Pages_DataOut(to_index(AXIMaster_ReadAddress_Address(JTAGLoader_Address'length + PAGE_ADDRESS_BITS - 1 downto JTAGLoader_Address'length)));
			ReadData_Response       <= "00";
		
			WriteStatus_en          <= '0';
			ReadAddress_en          <= '0';
			WriteAddress_en         <= '0';
			WriteAddress_inc        <= '0';
		
			case CurrentState is
				when ST_IDLE =>
					if (AXIMaster_ReadAddress_Valid = '1') then
						ReadAddress_Ack         <= '1';
						ReadAddress_en          <= '1';
						
						NextState <= ST_READING_1;
					elsif ((AXIMaster_WriteAddress_Valid and AXIMaster_WriteData_Valid) = '1') then
						if (AXIMaster_WriteAddress_Address = x"00010000") then
							WriteAddress_Ack      <= '1';
							WriteStatus_en        <= '1';
							WriteData_Ack         <= '1';
							NextState             <= ST_RESPONDING;	
						else
							WriteAddress_en       <= '1';
							NextState             <= ST_WRITING_1;
						end if;
					end if;
				
				when ST_READING_1 =>
					NextState                 <= ST_READING_2;
				
				when ST_READING_2 =>
					ReadData_Valid            <= '1';
					ReadData_Response         <= "00";
					
					if (AXIMaster_ReadData_Ack = '1') then
						NextState               <= ST_IDLE;
					end if;
						
				when ST_WRITING_1 =>
					JTAGLoader_WriteEnable    <= '1';
					WriteAddress_inc          <= '1';
					
					NextState                 <= ST_WRITING_2;
						
				when ST_WRITING_2 =>
					JTAGLoader_WriteEnable    <= '1';
					JTAGLoader_DataOut(15 downto 0)   <= AXIMaster_WriteData_Data(16 + JTAGLoader_DataOut'high - 2 downto 16 + JTAGLoader_DataOut'low);
					JTAGLoader_DataOut(17 downto 16)  <= AXIMaster_WriteAddress_Address(29 downto 28);
			
					WriteAddress_Ack          <= '1';
					WriteData_Ack             <= '1';
					WriteResponse_Valid       <= '1';
					WriteResponse_Response    <= "00";
					
					if (AXIMaster_WriteResponse_Ack = '1') then
						NextState               <= ST_IDLE;
					else
						NextState               <= ST_RESPONDING;			
					end if;
				
				when ST_RESPONDING =>
					WriteResponse_Valid       <= '1';
					WriteResponse_Response    <= "00";
					
					if (AXIMaster_WriteResponse_Ack = '1') then
						NextState               <= ST_IDLE;
					end if;
				
			end case;
		end process;
		
		process(Clock)
		begin
			if rising_edge(Clock) then
				if (ReadAddress_en = '1') then
					Address_r     <= AXIMaster_ReadAddress_Address(Address_r'range);
				elsif (WriteAddress_en = '1') then
					Address_r     <= AXIMaster_WriteAddress_Address(Address_r'high downto Address_r'low + 1) & '0';
				elsif (WriteAddress_inc = '1') then
					Address_r(0)  <= '1';
				end if;
				
				if (WriteStatus_en = '1') then
					Status_r  <= AXIMaster_WriteData_Data(Status_r'range);
				end if;
			end if;
		end process;
		
		Reboot  <= Status_r(0);
	end generate;
end architecture;
