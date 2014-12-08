# EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
# vim: tabstop=2:shiftwidth=2:noexpandtab
# kate: tab-width 2; replace-tabs off; indent-width 2;
# 
# ============================================================================
# Authors:				Patrick Lehmann
# 
# Summary:				Token file generator for the PicoBlaze 6 instruction set.
#
# Description:
# ------------------------------------
#		The default register set defines:
#		- 4 argument registers
#			* if more arguments are needed, REG_TMP_ can be used
#		- 6 temporary registers
#		- 6 special purpose registers
#			* 1 pointer register group (high & low)
#			* 1 next thread register
#			* 1 loop counter register
#			* 1 return value register - mostly used with LOAD&RETURN statements
#			* 1 stack pointer register
#
#		Requirements:
#		=============
#			Python 3.4+
#
# License:
# ============================================================================
# Copyright 2012-2015 Patrick Lehmann - Dresden, Germany
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
# ============================================================================
#
#
# Configuration
# ==================
#
# define your output filename
tokenFileName = "KCPSM6.tok"

# define your register names s0..sF
regNames = ["Arg0", "Arg1", "Arg2", "Arg3", "Tmp0", "Tmp1", "Tmp2", "Tmp3", "Tmp4", "Tmp5", "PtrL", "PtrH", "NxtTh", "Cnt", "LaR", "SP"]

# Format function
# ==============================================================================
#
# expand **XY0 instructions
def op_sXsY(opname, opcode):
	lines = ""
	for x in range(0, 16):
		for y in range(0, 16):
			lines += "{:s}_{:s}_{:s}={:s}{:1x}{:1x}0\n".format(opname, regNames[x], regNames[y], opcode, x, y)
	return lines

# expand **XY0 instructions
def op_sXsY2(opname, opcode):
	lines = ""
	for x in range(0, 16):
		for y in range(0, 16):
			if (x != y):
				lines += "{:s}_{:s}_{:s}={:s}{:1x}{:1x}0\n".format(opname, regNames[x], regNames[y], opcode, x, y)
			else:
				lines += "{:s}={:s}{:1x}{:1x}0\n".format("NOP", opcode, x, y)
	return lines
	
# expand **Xkk instructions
def op_sXkk(opname, opcode):
	lines = ""
	for x in range(0, 16):
		for kk in range(0, 256):
			lines += "{:s}_{:s}_0x{:02x}={:s}{:01x}{:02x}\n".format(opname, regNames[x], kk, opcode, x, kk)
	return lines

# expand **X** instructions
def op_sX(opname, opcode1, opcode2):
	lines = ""
	for x in range(0, 16):
		lines += "{:s}_{:s}={:s}{:1x}{:s}\n".format(opname, regNames[x], opcode1, x, opcode2)
	return lines

# expand **Xpp instructions
def op_sXpp(opname, opcode):
	lines = ""
	for x in range(0, 16):
		for pp in range(0, 256):
			lines += "{:s}_{:s}_P{:d}={:s}{:01x}{:02x}\n".format(opname, regNames[x], pp, opcode, x, pp)
	
	return lines

# expand **Xss instructions
def op_sXss(opname, opcode):
	lines = ""
	for x in range(0, 16):
		for pp in range(0, 256):
			lines += "{:s}_{:s}_P{:d}={:s}{:01x}{:02x}\n".format(opname, regNames[x], pp, opcode, x, pp)
	
	return lines
	
# expand **kkp instructions
def op_kkp(opname, opcode):
	lines = ""
	for kk in range(0, 256):
		for p in range(0, 16):
			lines += "{:s}_0x{:02x}_P{:d}={:s}{:02x}{:01x}\n".format(opname, kk, p, opcode, kk, p)
	
	return lines

# expand **aaa instructions
def op_aaa(opname, opcode):
	lines = ""
	for aaa in range(0, 4096):
		lines += "{:s}_{:03x}={:s}{:03x}\n".format(opname, aaa, opcode, aaa)
	
	return lines


tokenFileContent = ""

# Expand all instructions and append them to tokenFileContent
# ==============================================================================
# Register loading					Mnemonic		OpCode
tokenFileContent += op_sXsY2("MOVE",	"00")
tokenFileContent += op_sXkk("CONST",	"01")
tokenFileContent += op_sXsY("STAR",		"16")
tokenFileContent += op_sXkk("STAR",		"17")
# Logical
tokenFileContent += op_sXsY("AND",		"02")
tokenFileContent += op_sXkk("AND",		"03")
tokenFileContent += op_sXsY("OR",			"04")
tokenFileContent += op_sXkk("OR",			"05")
tokenFileContent += op_sXsY("XOR",		"06")
tokenFileContent += op_sXkk("XOR",		"07")
# Arithmetic
tokenFileContent += op_sXsY("ADD",		"10")
tokenFileContent += op_sXkk("ADD",		"11")
tokenFileContent += op_sXsY("ADDCY",	"12")
tokenFileContent += op_sXkk("ADDCY",	"13")
tokenFileContent += op_sXsY("SUB",		"18")
tokenFileContent += op_sXkk("SUB",		"19")
tokenFileContent += op_sXsY("SUBCY",	"1A")
tokenFileContent += op_sXkk("SUBCY",	"1B")
# Test and compare
tokenFileContent += op_sXsY("TST",		"0C")
tokenFileContent += op_sXkk("TST",		"0D")
tokenFileContent += op_sXsY("TSTCY",	"0E")
tokenFileContent += op_sXkk("TSTCY",	"0F")
tokenFileContent += op_sXsY("CMP",		"1C")
tokenFileContent += op_sXkk("CMP",		"1D")
tokenFileContent += op_sXsY("CMPCY",	"1E")
tokenFileContent += op_sXkk("CMPCY",	"1F")
# Shift and Rotate
tokenFileContent += op_sX("SL0",	"14", "06")
tokenFileContent += op_sX("SL1",	"14", "07")
tokenFileContent += op_sX("SLX",	"14", "04")
tokenFileContent += op_sX("SLA",	"14", "00")
tokenFileContent += op_sX("RL",		"14", "02")
tokenFileContent += op_sX("SR0",	"14", "0E")
tokenFileContent += op_sX("SR1",	"14", "0F")
tokenFileContent += op_sX("SRX",	"14", "0A")
tokenFileContent += op_sX("SRA",	"14", "08")
tokenFileContent += op_sX("RR",		"14", "0C")
# Interrupt handling
tokenFileContent += "BNKA=37000\n"
tokenFileContent += "BNKB=37001\n"
# Input and Output
tokenFileContent += op_sXsY("IN",			"08")
tokenFileContent += op_sXpp("IN",			"09")
tokenFileContent += op_sXsY("OUT",		"2C")
tokenFileContent += op_sXpp("OUT",		"2D")
tokenFileContent += op_kkp("OUTK",		"2B")
# Memory
tokenFileContent += op_sXsY("STORE",	"2E")
tokenFileContent += op_sXss("STORE",	"2F")
tokenFileContent += op_sXsY("FETCH",	"0A")
tokenFileContent += op_sXss("FETCH",	"0B")
# Interrupt handling
tokenFileContent += "INTdis=28000\n"
tokenFileContent += "INTen=28001\n"
tokenFileContent += "RETIdis=29000\n"
tokenFileContent += "RETIen=29001\n"
# Jump
tokenFileContent += op_aaa("JMP",			"22")
tokenFileContent += op_aaa("JMPz",		"32")
tokenFileContent += op_aaa("JMPnz",		"36")
tokenFileContent += op_aaa("JMPc",		"3A")
tokenFileContent += op_aaa("JMPna",		"3E")
tokenFileContent += op_sXsY("JMP@",		"26")
# Call
tokenFileContent += op_aaa("CALL",		"20")
tokenFileContent += op_aaa("CALLz",		"30")
tokenFileContent += op_aaa("CALLnz",	"34")
tokenFileContent += op_aaa("CALLc",		"38")
tokenFileContent += op_aaa("CALLnc",	"3C")
tokenFileContent += op_sXsY("CALL@",	"24")
tokenFileContent += "RET=25000\n"
tokenFileContent += "RETz=31000\n"
tokenFileContent += "RETnz=35000\n"
tokenFileContent += "RETc=39000\n"
tokenFileContent += "RETnc=3D000\n"
tokenFileContent += op_sXkk("LaR",		"21")

# Write tokenFileContent to disk
import pathlib
outputFilePath = pathlib.Path(tokenFileName)
print("Writing PicoBlaze Instructions to token file: %s" % outputFilePath)
with outputFilePath.open(mode='w', encoding="utf-8") as tokenFile:
	tokenFile.write(tokenFileContent)

print("finished")
