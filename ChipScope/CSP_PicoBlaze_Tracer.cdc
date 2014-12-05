# EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
# vim: tabstop=2:shiftwidth=2:noexpandtab
# kate: tab-width 2; replace-tabs off; indent-width 2;
# 
# ==============================================================================
# Authors:					Patrick Lehmann
#
# CSP *.cdc file:		ChipScope Analyzer - ILA core signal names
# 
# Description:
# ------------------------------------
#		This file contains the signal names for the CSP_PicoBlaze_Tracer ILA.
#		Import this file into ChipScope Analyzer to name all used signals and
#		to create virtual busses.
#		
# License:
# ==============================================================================
# Copyright 2007-2015 Patrick Lehmann - Dresden, Germany
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
#ChipScope Core Generator Project File Version 3.0
#Tue Jul 22 13:50:07 Mitteleuropäische Sommerzeit 2014
SignalExport.clockChannel=CLK
SignalExport.bus<0000>.channelList=0 1 2 3 4 5 6 7 8 9 10 11
SignalExport.bus<0000>.name=InstAdr
SignalExport.bus<0000>.offset=0.0
SignalExport.bus<0000>.precision=0
SignalExport.bus<0000>.radix=Hex
SignalExport.bus<0000>.scaleFactor=1.0
SignalExport.bus<0001>.channelList=0 1 2 3 4 5 6 7 8 9 10 11
SignalExport.bus<0001>.name=Routine
SignalExport.bus<0001>.offset=0.0
SignalExport.bus<0001>.precision=0
SignalExport.bus<0001>.radix=Hex
SignalExport.bus<0001>.scaleFactor=1.0
SignalExport.bus<0002>.channelList=12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
SignalExport.bus<0002>.name=Instruction
SignalExport.bus<0002>.offset=0.0
SignalExport.bus<0002>.precision=0
SignalExport.bus<0002>.radix=hex
SignalExport.bus<0002>.scaleFactor=1.0
SignalExport.bus<0003>.channelList=12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
SignalExport.bus<0003>.name=Mnemonic
SignalExport.bus<0003>.offset=0.0
SignalExport.bus<0003>.precision=0
SignalExport.bus<0003>.radix=hex
SignalExport.bus<0003>.scaleFactor=1.0
SignalExport.bus<0004>.channelList=30 31 32 33 34 35 36 37 54 55 56
SignalExport.bus<0004>.name=PortID
SignalExport.bus<0004>.offset=0.0
SignalExport.bus<0004>.precision=0
SignalExport.bus<0004>.radix=Hex
SignalExport.bus<0004>.scaleFactor=1.0
SignalExport.bus<0004>.channelList=57 58 59
SignalExport.bus<0004>.name=System
SignalExport.bus<0004>.offset=0.0
SignalExport.bus<0004>.precision=0
SignalExport.bus<0004>.radix=Hex
SignalExport.bus<0004>.scaleFactor=1.0
SignalExport.dataChannel<0000>=InstAdr[0]
SignalExport.dataChannel<0001>=InstAdr[1]
SignalExport.dataChannel<0002>=InstAdr[2]
SignalExport.dataChannel<0003>=InstAdr[3]
SignalExport.dataChannel<0004>=InstAdr[4]
SignalExport.dataChannel<0005>=InstAdr[5]
SignalExport.dataChannel<0006>=InstAdr[6]
SignalExport.dataChannel<0007>=InstAdr[7]
SignalExport.dataChannel<0008>=InstAdr[8]
SignalExport.dataChannel<0009>=InstAdr[9]
SignalExport.dataChannel<0010>=InstAdr[10]
SignalExport.dataChannel<0011>=InstAdr[11]
SignalExport.dataChannel<0012>=Inst[0]
SignalExport.dataChannel<0013>=Inst[1]
SignalExport.dataChannel<0014>=Inst[2]
SignalExport.dataChannel<0015>=Inst[3]
SignalExport.dataChannel<0016>=Inst[4]
SignalExport.dataChannel<0017>=Inst[5]
SignalExport.dataChannel<0018>=Inst[6]
SignalExport.dataChannel<0019>=Inst[7]
SignalExport.dataChannel<0020>=Inst[8]
SignalExport.dataChannel<0021>=Inst[9]
SignalExport.dataChannel<0022>=Inst[10]
SignalExport.dataChannel<0023>=Inst[11]
SignalExport.dataChannel<0024>=Inst[12]
SignalExport.dataChannel<0025>=Inst[13]
SignalExport.dataChannel<0026>=Inst[14]
SignalExport.dataChannel<0027>=Inst[15]
SignalExport.dataChannel<0028>=Inst[16]
SignalExport.dataChannel<0029>=Inst[17]
SignalExport.dataChannel<0030>=PortID[0]
SignalExport.dataChannel<0031>=PortID[1]
SignalExport.dataChannel<0032>=PortID[2]
SignalExport.dataChannel<0033>=PortID[3]
SignalExport.dataChannel<0034>=PortID[4]
SignalExport.dataChannel<0035>=PortID[5]
SignalExport.dataChannel<0036>=PortID[6]
SignalExport.dataChannel<0037>=PortID[7]
SignalExport.dataChannel<0038>=DataOut[0]
SignalExport.dataChannel<0039>=DataOut[1]
SignalExport.dataChannel<0040>=DataOut[2]
SignalExport.dataChannel<0041>=DataOut[3]
SignalExport.dataChannel<0042>=DataOut[4]
SignalExport.dataChannel<0043>=DataOut[5]
SignalExport.dataChannel<0044>=DataOut[6]
SignalExport.dataChannel<0045>=DataOut[7]
SignalExport.dataChannel<0046>=DataIn[0]
SignalExport.dataChannel<0047>=DataIn[1]
SignalExport.dataChannel<0048>=DataIn[2]
SignalExport.dataChannel<0049>=DataIn[3]
SignalExport.dataChannel<0050>=DataIn[4]
SignalExport.dataChannel<0051>=DataIn[5]
SignalExport.dataChannel<0052>=DataIn[6]
SignalExport.dataChannel<0053>=DataIn[7]
SignalExport.dataChannel<0054>=PortID[8]
SignalExport.dataChannel<0055>=PortID[10]
SignalExport.dataChannel<0056>=PortID[9]
SignalExport.dataChannel<0057>=System[0]
SignalExport.dataChannel<0058>=System[1]
SignalExport.dataChannel<0059>=System[2]
SignalExport.dataEqualsTrigger=false
SignalExport.dataPortWidth=60
SignalExport.triggerChannel<0000><0000>=InstAdr[0]
SignalExport.triggerChannel<0000><0001>=InstAdr[1]
SignalExport.triggerChannel<0000><0002>=InstAdr[2]
SignalExport.triggerChannel<0000><0003>=InstAdr[3]
SignalExport.triggerChannel<0000><0004>=InstAdr[4]
SignalExport.triggerChannel<0000><0005>=InstAdr[5]
SignalExport.triggerChannel<0000><0006>=InstAdr[6]
SignalExport.triggerChannel<0000><0007>=InstAdr[7]
SignalExport.triggerChannel<0000><0008>=InstAdr[8]
SignalExport.triggerChannel<0000><0009>=InstAdr[9]
SignalExport.triggerChannel<0000><0010>=InstAdr[10]
SignalExport.triggerChannel<0000><0011>=InstAdr[11]
SignalExport.triggerChannel<0001><0000>=PortID[0]
SignalExport.triggerChannel<0001><0001>=PortID[1]
SignalExport.triggerChannel<0001><0002>=PortID[2]
SignalExport.triggerChannel<0001><0003>=PortID[3]
SignalExport.triggerChannel<0001><0004>=PortID[4]
SignalExport.triggerChannel<0001><0005>=PortID[5]
SignalExport.triggerChannel<0001><0006>=PortID[6]
SignalExport.triggerChannel<0001><0007>=PortID[7]
SignalExport.triggerChannel<0002><0000>=Write
SignalExport.triggerChannel<0002><0001>=WriteK
SignalExport.triggerChannel<0002><0002>=Read
SignalExport.triggerChannel<0002><0003>=Interrupt
SignalExport.triggerChannel<0002><0004>=Reboot
SignalExport.triggerChannel<0002><0005>=Trigger
SignalExport.triggerChannel<0003><0000>=DataOut[0]
SignalExport.triggerChannel<0003><0001>=DataOut[1]
SignalExport.triggerChannel<0003><0002>=DataOut[2]
SignalExport.triggerChannel<0003><0003>=DataOut[3]
SignalExport.triggerChannel<0003><0004>=DataOut[4]
SignalExport.triggerChannel<0003><0005>=DataOut[5]
SignalExport.triggerChannel<0003><0006>=DataOut[6]
SignalExport.triggerChannel<0003><0007>=DataOut[7]
SignalExport.triggerChannel<0003><0008>=DataIn[0]
SignalExport.triggerChannel<0003><0009>=DataIn[1]
SignalExport.triggerChannel<0003><0010>=DataIn[2]
SignalExport.triggerChannel<0003><0011>=DataIn[3]
SignalExport.triggerChannel<0003><0012>=DataIn[4]
SignalExport.triggerChannel<0003><0013>=DataIn[5]
SignalExport.triggerChannel<0003><0014>=DataIn[6]
SignalExport.triggerChannel<0003><0015>=DataIn[7]
SignalExport.triggerPort<0000>.name=InstAdr
SignalExport.triggerPort<0001>.name=PortID
SignalExport.triggerPort<0002>.name=Strobe
SignalExport.triggerPort<0003>.name=Data
SignalExport.triggerPortCount=4
SignalExport.triggerPortIsData<0000>=false
SignalExport.triggerPortIsData<0001>=false
SignalExport.triggerPortIsData<0002>=false
SignalExport.triggerPortIsData<0003>=false
SignalExport.triggerPortWidth<0000>=12
SignalExport.triggerPortWidth<0001>=8
SignalExport.triggerPortWidth<0002>=6
SignalExport.triggerPortWidth<0003>=16
SignalExport.type=ila
