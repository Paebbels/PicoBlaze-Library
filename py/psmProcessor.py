# EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
# vim: tabstop=2:shiftwidth=2:noexpandtab
# kate: tab-width 2; replace-tabs off; indent-width 2;
# 
# ==============================================================================
# Authors:					Patrick Lehmann
#
# Python-Code:			Open PicoBlaze Assembler Log File Processor
# 
# Description:
# ------------------------------------
#		TODO
#		
#
# License:
# ==============================================================================
# Copyright 2007-2015 Technische Universitaet Dresden - Germany,
#											Chair for VLSI-Design, Diagnostics and Architecture
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#		http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
#
import argparse
from pathlib import Path
import re
import string
import sys
import textwrap

		
class LogProcessor:
	__workingDirectoryPath = None
	__verbose = False

	__outputFilePrefix = ""
	__logFileCount = 0
	__logFilePaths = None
	
	__ListOfPages = []
	
	def __init__(self, logFileNames, outputFilePrefix, debug, verbose):
		self.__workingDirectoryPath =	Path.cwd()
		self.__debug =			debug
		self.__verbose =		verbose
		
		self.__outputFilePrefix =	outputFilePrefix if outputFilePrefix is not None else "PicoBlaze"
		self.__logFileCount =			len(logFileNames)
		self.__logFilePaths =			[Path(logFileName) for logFileName in logFileNames]
		
		if (self.__debug):
			print("DEBUG: verbose mode: %s" % str(self.__verbose))
			print("DEBUG: working directory: %s" % self.__workingDirectoryPath)
			print()

	def PostProcess(self):
		if (self.__debug):
			print("DEBUG: input file count: %i" % self.__logFileCount)
	
		for logFilePath in self.__logFilePaths:
			self.ReadAssemblerLog(logFilePath)
			
		self.WriteVHDLPackage()
		self.WriteTokenFile()
		
		print("Post Processing completed")
			
	def ReadAssemblerLog(self, logFilePath):
		if (not logFilePath.exists()):
			raise FileNotFoundError("log file does not exist!")

		print("Reading assembler log file: %s" % str(logFilePath))
		
		ListOfFunctions = []
		
		with logFilePath.open(mode='r', encoding="utf-8") as logFile:
			newFunction = None
		
			for line in logFile:
				#self.__outputHeader += line
				
				regexp = r"\s?(?P<InstAdr>[0-9a-fA-F]{3})"			# Instruction address [hex, 3 digits]
				regexp += r"\s*"																# spacing
				regexp += r";PRAGMA "														#	PRAGMA line
				regexp += r"(?P<KeyWord>("											# define Keyword group and open keyword list
				regexp += r"(?P<kwFunction>function(?! end))|"	#		add named keyword for functions
				regexp += r"(?P<kwFunctionEnd>function end)"		#		add named keyword for ends
				regexp += r")"																	#		close keyword list
				regexp += r")"																	# close keyword group
				regexp += r"(?(kwFunction) "										# add additional matching rules if keyword = function
				regexp += r"(?P<FunctionName>[_a-zA-Z0-9]+)"		#		add function name
				regexp += r" begin"															# close additional matching rule
				regexp += r")"																	# close additional matching rule
				
				regExpMatch = re.compile(regexp).match(line)
				#print(str(regExpMatch))

				if (regExpMatch is not None):
					if (regExpMatch.group("KeyWord") == "function"):
						#print("begin-function: \"%s\" @ %s" % (regExpMatch.group("FunctionName"), regExpMatch.group("InstAdr")))
						
						if (newFunction is not None):
							if (newFunction['EndAddress'] == ""):
								newFunction['EndAddress'] = regExpMatch.group("InstAdr")
								
								print("WARNING: function '" + newFunction['FunctionName'] + "' was not popperly closed.")
						
						newFunction = {
							'FunctionName'	: regExpMatch.group("FunctionName"),
							'StartAddress'	: regExpMatch.group("InstAdr"),
							'EndAddress'		: ""
						}
						
						ListOfFunctions.append(newFunction)
						
					elif (regExpMatch.group("KeyWord") == "function end"):
						#print("end-function: @ %s" % regExpMatch.group("InstAdr"))
						
						newFunction['EndAddress'] = regExpMatch.group("InstAdr")
						
			if (newFunction is not None):
				if (newFunction['EndAddress'] == ""):
					newFunction['EndAddress'] = "FFF"
			
		self.__ListOfPages.append(ListOfFunctions)
			
	def WriteVHDLPackage(self):
		outputFileName = self.__outputFilePrefix + ".pkg.vhdl"
		outputFilePath = self.__workingDirectoryPath / outputFileName

		vhdlPreamble = textwrap.dedent('''\
			library IEEE;
			use			IEEE.STD_LOGIC_1164.all;
			use			IEEE.NUMERIC_STD.all;
			
			--library PoC;
			--use			PoC.utils.all;
			
			library L_PicoBlaze;
			use			L_PicoBlaze.pb.all;
			
			''')
		
		vhdlHeader = textwrap.dedent('''\
			package %s is
			
				type T_PB_FUNCTIONS is (
					UNKNOWN%s
				);
				
				function InstructionPointer2FunctionName(PageNumber : STD_LOGIC_VECTOR(2 downto 0); InstAdr : T_PB_ADDRESS) return T_PB_FUNCTIONS;
			end;

			
			''')
		
		vhdlBody = textwrap.dedent('''\
			package body %s is
				function InstructionPointer2FunctionName(PageNumber : STD_LOGIC_VECTOR(2 downto 0); InstAdr : T_PB_ADDRESS) return T_PB_FUNCTIONS is
					variable InstructionPointer		: UNSIGNED(InstAdr'range);
				begin
					InstructionPointer	:= unsigned(InstAdr);
				%s
					else
						return UNKNOWN;
					end if;
				end function;
			end package body;
			''')
			
		vhdlIf = '''
		if ((x"%s" <= InstructionPointer) and (InstructionPointer < x"%s")) then
			return p%i%s;'''
			
		vhdlElsIf = '''
		elsif ((x"%s" <= InstructionPointer) and (InstructionPointer < x"%s")) then
			return p%i%s;'''
		
		EnumMemberList = ""
		IfExpressions = ""
	
		for pageNumber in range(0, len(self.__ListOfPages) - 1):
			ListOfFunctions = self.__ListOfPages[pageNumber]
			
			for function in ListOfFunctions:
				EnumMemberList += ", p%i%s" % (pageNumber, function['FunctionName'])
		
				if (IfExpressions == ""):
					IfExpressions = vhdlIf % (function['StartAddress'], function['EndAddress'], pageNumber, function['FunctionName'])
				else:
					IfExpressions += vhdlElsIf % (function['StartAddress'], function['EndAddress'], pageNumber, function['FunctionName'])
		
				if (self.__verbose):
					print("p%i%s: from %s to %s" % (pageNumber, function['FunctionName'], function['StartAddress'], function['EndAddress']))

		# 
		vhdlHeader = vhdlHeader % (self.__outputFilePrefix + "_sim", EnumMemberList)
		vhdlBody = vhdlBody % (self.__outputFilePrefix + "_sim", IfExpressions)
	
		print("Writing VHDL package file: %s" % outputFileName)
		with outputFilePath.open(mode='w', encoding="utf-8") as vhdlFile:
			vhdlFile.write(vhdlPreamble)
			vhdlFile.write(vhdlHeader)
			vhdlFile.write(vhdlBody)
	
	def WriteTokenFile(self):
		outputFileName = self.__outputFilePrefix + ".tok"
		outputFilePath = self.__workingDirectoryPath / outputFileName
	
		outputContent = ""
	
		for pageNumber in range(len(self.__ListOfPages)):
			ListOfFunctions = self.__ListOfPages[pageNumber]
			
			for function in ListOfFunctions:
				for adr in range(int(function['StartAddress'], 16), int(function['EndAddress'], 16)):
					outputContent += "p{:d}{:s}={:x}\n".format(pageNumber, function['FunctionName'], ((pageNumber * 4096) + adr))

		print("Writing ChipScope token file: %s" % outputFileName)
		with outputFilePath.open(mode='w', encoding="utf-8") as tokenFile:
			tokenFile.write(outputContent)
	
# main program
#		file		- assembler log file
def main():
	print("Open PicoBlaze Assembler Log File Processor - Patrick Lehmann, Copyright (c) 2014-2015")
	print("========================================================================")
	print()
	
	try:
		# create a commandline argument parser
		argParser = argparse.ArgumentParser(
			formatter_class = argparse.RawDescriptionHelpFormatter,
			description = textwrap.dedent('''\
				Read the log file of the KCPSM6 assembler and:
				  - extract address regions of functions
				  - ...
				and:
				  - transform them into VHDL encoded debug information.
				'''))

		# add arguments
		argParser.add_argument('-d',							action='store_true', default=False, help='enable debug mode')
		argParser.add_argument('-v',							action='store_true', default=False, help='generate detailed report')
		argParser.add_argument('-p', "--prefix",	action='store',											help="Specify the ouput file prefix.")
		argParser.add_argument("files",						action='store', nargs='+',					help="Specify the assembler log file.")
		
		# parse command line options
		args = argParser.parse_args()

	except Exception as ex:
		print("EXCEPTION: %s" % ex.__str__())

	try:
		logProcessor = LogProcessor(args.files, args.prefix, args.d, args.v)
		logProcessor.PostProcess()
		#logProcessor.WriteVHDLPackage()
		#logProcessor.WriteTokenFile()
		
	except FileNotFoundError as ex:
		print("FileNotFoundError: %s" % ex.__str__())
	#except Exception as ex:
		#print("ERROR: %s" % ex.__str__())

	
# entry point
if __name__ == "__main__":
	main()
