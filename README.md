PicoBlaze-Library
=================================================
The PicoBlaze Library offers several PicoBlaze devices and code routines
to extend a common PicoBlaze environment to a little System on a Chip (SoC or SoFPGA).

Table of Content:
================================================================================
 1. [Overview](#1-overview)
 2. [Download](#2-download)
 3. [Requirements](#3-requirements)
 4. [Integrating PoC into projects](#4-integrating-picoblaze-library-into-projects)
 5. [Using PicoBlaze Library](#5-using-picoblaze-library)
 6. [Configuring a System-on-FPGA with PicoBlaze Library](#6-configuring-a-system-on-fpga-with-picoblaze-library)
 7. [Updating PicoBlaze Library](#7-updating-picoblaze-library)

1 Overview
================================================================================




2 Download
================================================================================
The PicoBlaze Library can be [downloaded][download] as a zip-file (latest 'master' branch) or
cloned with `git` from GitHub. GitHub offers HTTPS and SSH as transfer protocols.

For SSH protocol use the URL `ssh://git@github.com:Paebbels/PicoBlaze-Library.git` or command
line instruction:

    cd <GitRoot>
    git clone ssh://git@github.com:Paebbels/PicoBlaze-Library.git L_PicoBlaze

For HTTPS protocol use the URL `https://github.com/Paebbels/PicoBlaze-Library.git` or command
line instruction:

    cd <GitRoot>
    git clone https://github.com/Paebbels/PicoBlaze-Library.git L_PicoBlaze

 [download]: https://github.com/Paebbels/PicoBlaze-Library/archive/master.zip

3 Requirements
================================================================================
### 3.1 Dependencies:
The PicoBlaze Library depends on the [**PoC-Library**][poc], a platform independent HDL library, and
the [**Open PicoBlaze Assembler**][opbasm], a free and freature rich assembler for the PicoBlaze
processor. Both dependencies are available as GitHub repositoriesand can be downloaded via `git clone`.
See section [Integrating PicoBlaze Library into projects](#4-integrating-picoblaze-library-into-projects)
for more details.

 [poc]: https://github.com/VLSI-EDA/PoC

### 3.2 Common requirements:

 - Synthesis tool chains:
     - Xilinx ISE 14.7 or
     - Xilinx Vivado 2014.x or
 - Simulation tool chains:
     - Xilinx ISE Simulator 14.7 or
     - Xilinx Vivado Simulator 2014.x or
 - Programming languages and runtimes:
	- [Python 3][python] (&ge; 3.4):
	     - [colorama][colorama]
 - Assembler tool chains:
	 - KCPSM6.exe
	 - [Open PicoBlaze Assembler][opbasm] (opbasm)

 [python]:   https://www.python.org/downloads/
 [colorama]: https://pypi.python.org/pypi/colorama
 [opbasm]:   https://github.com/kevinpt/opbasm

##### Additional requirements on Linux:
 - m4 macro pre-processor
 - Debian specific:
	- bash is configured as `/bin/sh` ([read more](https://wiki.debian.org/DashAsBinSh))  
      `dpkg-reconfigure dash`


##### Additional requirements on Windows:

 - PowerShell 4.0 ([Windows Management Framework 4.0][wmf40])
    - Allow local script execution ([read more][execpol])  
      `PS> Set-ExecutionPolicy RemoteSigned`
    - PowerShell Community Extensions 3.2 ([pscx.codeplex.com][pscx])
 - m4 macro pre-processor

 [wmf40]:   http://www.microsoft.com/en-US/download/details.aspx?id=40855
 [execpol]: https://technet.microsoft.com/en-us/library/hh849812.aspx
 [pscx]:    http://pscx.codeplex.com/

### 3.3 Optional Tools:


##### Optional tools for Linux:
 - [Generic Colouriser][grc] (grc) &ge;1.9
	 - *.deb package for Debian -> [http://kassiopeia.juls.savba.sk/~garabik/software/grc/](http://kassiopeia.juls.savba.sk/~garabik/software/grc/)
	 - Git repository on GitHub -> [https://github.com/garabik/grc](https://github.com/garabik/grc)

 [grc]:     http://kassiopeia.juls.savba.sk/~garabik/software/grc.html

##### Optional tools for Windows:
 - [posh-git][posh_git] - PowerShell integration for Git  
   Installing posh-git with PsGet package manager: `Install-Module posh-git`
 
 [posh_git]: https://github.com/dahlbyk/posh-git
 

4 Integrating PicoBlaze Library into projects
================================================================================

All Windows command line instructions are intended for PowerShell. So executing the following instructions in `cmd.exe` won't function or result in errors! PowerShell is shipped with Windows since Vista.  

### 4.1 Adding PicoBlaze Library and it's dependencies as git submodules

The following command line instructions will create a library folder `/lib` and clone all depenencies
as git [submodules][git_submod] into subfolders.

    cd <ProjectRoot>
    
    mkdir lib\PoC\
    git submodule add ssh://git@github.com:VLSI-EDA/PoC.git lib\PoC
    git add .gitmodules lib\PoC
    git commit -m "Added new git submodule PoC in 'lib\PoC' (PoC Library)."
    
    mkdir lib\L_PicoBlaze\
    git submodule add ssh://git@github.com:Paebbels/PicoBlaze-Library.git lib\L_PicoBlaze
    git add .gitmodules lib\L_PicoBlaze
    git commit -m "Added new git submodule L_PicoBlaze in 'lib\L_PicoBlaze' (PicoBalze Library)."

    mkdir lib\opbasm\
    git submodule add ssh://git@github.com:Paebbels/opbasm.git lib\opbasm
    git add .gitmodules lib\opbasm
    git commit -m "Added new git submodule opbasm in 'lib\opbasm' (Open PicoBlaze Assembler)."

[git_submod]: http://git-scm.com/book/en/v2/Git-Tools-Submodules

### 4.2 Configuring PoC on a local system

To run PoC's automated testbenches or use the netlist compilaltion scripts of PoC, it's required to configure a synthesis and simulation tool chain.

    cd <ProjectRoot>
    cd lib\PoC\
    .\poc.ps1 --configure

### 4.3 Compiling shipped Xilinx IPCores (*.xco files) to netlists

The PicoBlaze Library and the PoC Library are shipped with some pre-configured IPCores from Xilinx. These IPCores are shipped as \*.xco files and need to be compiled to netlists (\*.ngc files) and there auxillary
files (\*.ncf files; \*.vhdl files; ...). This can be done by invoking PoC's `Netlist.py` through one of the
provided wrapper scripts: netlist.[sh|ps1].

Compiling needed IPCores from PoC for a KC705 board:

    cd <ProjectRoot>
    cd lib\PoC\netlist
    foreach ($i in 1..15) {
      .\netlist.ps1 --coregen PoC.xil.ChipScopeICON_$i --board KC705
    }

Compiling needed IPCores from L_PicoBlaze for a KC705 board:

    cd ....
    cd lib\L_PicoBlaze\netlist\<DeviceString>\
    # TODO: write a script to regenerate all IP Cores


5 Using PicoBlaze Library
================================================================================

### 6.1 Standalone

### 6.1 In Xilinx ISE (XST and iSim)

### 6.2 In Xilinx Vivado (Synth and xSim)


6 Configuring a System-on-FPGA with PicoBlaze Library
================================================================================


7 Updating PicoBlaze Library
================================================================================




