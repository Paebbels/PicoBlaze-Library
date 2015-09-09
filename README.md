# The PicoBlaze-Library

The PicoBlaze-Library offers several PicoBlaze devices and code routines
to extend a common PicoBlaze environment to a little System on a Chip (SoC or SoFPGA).

Table of Content:
--------------------------------------------------------------------------------
 1. [Overview](#1-overview)
 2. [Download](#2-download)
 3. [Requirements](#3-requirements)
	- [Dependencies](#dependencies)
	- [Common Requirements](#common-requirements)
	- [Optional Tools](#optional-tools)
 4. [Integrating the Library into Projects](#4-integrating-the-library-into-projects)
 5. [Using PicoBlaze-Library](#5-using-picoblaze-library)
 6. [Configuring a System-on-FPGA with PicoBlaze-Library](#6-configuring-a-system-on-fpga-with-picoblaze-library)
 7. [Updating PicoBlaze-Library](#7-updating-picoblaze-library)

--------------------------------------------------------------------------------

## 1 Overview

TODO TODO TODO

Related repositories: [PicoBlaze-Examples][pb_ex]

 [pb_ex]:  https://github.com/VLSI-EDA/PoC-Examples

## 2 Download

**The PicoBlaze-Library** can be downloaded as a [zip-file][download] (latest 'master'
branch) or cloned with `git clone` from GitHub. GitHub offers HTTPS and SSH as transfer
protocols. See the [Download][wiki-download] wiki page for more details.

For SSH protocol use the URL `ssh://git@github.com:Paebbels/PicoBlaze-Library.git` or command
line instruction:

```PowerShell
cd <GitRoot>
git clone --recursive ssh://git@github.com:Paebbels/PicoBlaze-Library.git L_PicoBlaze
```

For HTTPS protocol use the URL `https://github.com/Paebbels/PicoBlaze-Library.git` or command
line instruction:

```PowerShell
cd <GitRoot>
git clone --recursive https://github.com/Paebbels/PicoBlaze-Library.git L_PicoBlaze
```

**Note:** The option `--recursive` performs a recursive clone operation for all
linked [git submodules][git_submod]. An additional `git submodule init` and
`git submodule update` call is not needed anymore. 

 [download]: https://github.com/Paebbels/PicoBlaze-Library/archive/master.zip


## 3 Dependencies:

**The PicoBlaze-Library** depends on:

 - [**The PoC-Library**][poc], a platform independent HDL library, and
 - [**Open PicoBlaze Assembler**][opbasm], a free and freature rich
   assembler for the PicoBlaze processor.

Both dependencies are available as GitHub repositories and can be downloaded
via `git clone`. See section the [Dependencies][wiki:dependencies] and/or
[Integration][wiki:integration] wiki pages for more details.

 [poc]: https://github.com/VLSI-EDA/PoC


## 4 Requirements

**The PicoBlaze-Library** comes with some scripts to ease most of the common tasks.
We choose to use Python as a platform independent scripting environment. All
Python scripts are wrapped in PowerShell or Bash scripts, to hide some platform
specifics of Windows or Linux. See the [Requirements][wiki:requirements] wiki
page for more details and download sources.

##### Common Requirements:

 - Programming languages and runtimes:
	- [Python 3][python] (&ge; 3.4):
	     - [colorama][colorama]
 - Synthesis tool chains:
     - Xilinx ISE 14.7 or
     - Xilinx Vivado &ge; 2014.1 or
     - Altera Quartus-II &ge; 13.0
 - Simulation tool chains:
     - Xilinx ISE Simulator 14.7 or
     - Xilinx Vivado Simulator &ge; 2014.1 or
     - Mentor Graphics ModelSim Altera Edition or
     - Mentor Graphics QuestaSim or
     - [GHDL][ghdl] and [GTKWave][gtkwave]
 - Assembler tool chains:
	 - KCPSM6.exe
	 - [Open PicoBlaze Assembler][opbasm] (opbasm)

 [python]:		https://www.python.org/downloads/
 [colorama]:	https://pypi.python.org/pypi/colorama
 [ghdl]:		https://sourceforge.net/projects/ghdl-updates/
 [gtkwave]:		http://gtkwave.sourceforge.net/
 [opbasm]:		https://github.com/kevinpt/opbasm

##### Additional requirements on Linux:

 - m4 macro pre-processor
 - Debian specific:
	- bash is configured as `/bin/sh` ([read more](https://wiki.debian.org/DashAsBinSh))  
      `dpkg-reconfigure dash`


##### Additional requirements on Windows:

 - m4 macro pre-processor
 - PowerShell 4.0 ([Windows Management Framework 4.0][wmf40])
    - Allow local script execution ([read more][execpol])  
      `Set-ExecutionPolicy RemoteSigned`
    - PowerShell Community Extensions 3.2 ([pscx.codeplex.com][pscx])

 [wmf40]:   http://www.microsoft.com/en-US/download/details.aspx?id=40855
 [execpol]: https://technet.microsoft.com/en-us/library/hh849812.aspx
 [pscx]:    http://pscx.codeplex.com/


## 4 Integrating PicoBlaze-Library into Projects

**The PicoBalze-Library** is meant to be integrated into HDL projects. Therefore it's
recommended to create a library folder and add the PicoBlaze-Library as a git submodule.
After the repository linking is done, some short configuration steps are required
to setup paths and tool chains. The following command line instructions show a
short example on how to integrate the PicoBlaze-Library. A detailed list of steps can
be found on the [Integration][wiki:integration] wiki page.

#### 4.1 Adding PicoBlaze-Library and it's Dependencies as git submodules

> All Windows command line instructions are intended for **Windows PowerShell**,
> if not marked otherwise. So executing the following instructions in Windows
> Command Prompt (`cmd.exe`) won't function or result in errors! See the
> [Requirements][wiki:requirements] wiki page on where to download or update
> PowerShell.

The following command line instructions will create a library folder `lib\` and clone all
depenencies as git [submodules][git_submod] into subfolders.

```PowerShell
cd <ProjectRoot>

mkdir lib\PoC\
git submodule add ssh://git@github.com:VLSI-EDA/PoC.git lib\PoC
git add .gitmodules lib\PoC
git commit -m "Added new git submodule PoC in 'lib\PoC' (PoC-Library)."

mkdir lib\L_PicoBlaze\
git submodule add ssh://git@github.com:Paebbels/PicoBlaze-Library.git lib\L_PicoBlaze
git add .gitmodules lib\L_PicoBlaze
git commit -m "Added new git submodule L_PicoBlaze in 'lib\L_PicoBlaze' (PicoBalze-Library)."

mkdir lib\opbasm\
git submodule add ssh://git@github.com:Paebbels/opbasm.git lib\opbasm
git add .gitmodules lib\opbasm
git commit -m "Added new git submodule opbasm in 'lib\opbasm' (Open PicoBlaze Assembler)."
```

 [git_submod]: http://git-scm.com/book/en/v2/Git-Tools-Submodules

#### 4.2 Configuring PoC on a Local System

The previous step cloned the PoC-Library into the folder `lib\PoC\`. This library needs to be
configured to provide its full potential.

```PowerShell
cd <ProjectRoot>
cd lib\PoC\
.\poc.ps1 --configure
```

#### 4.3 Creating PoC's my_config and my_project Files

The PoC-Library needs two VHDL files for it's configuration. These files are used to
determine the most suitable implementation depending on the provided platform information.
Copy these two template files into your project's source folder. Rename these files to
*.vhdl and configure the VHDL constants in these files.  

```PowerShell
cd <ProjectRoot>
cp lib\PoC\src\common\my_config.vhdl.template src\common\my_config.vhdl
cp lib\PoC\src\common\my_project.vhdl.template src\common\my_project.vhdl
```

`my_config.vhdl` defines two global constants, which need to be adjusted:

```VHDL
constant MY_BOARD            : string := "CHANGE THIS"; -- e.g. Custom, ML505, KC705, Atlys
constant MY_DEVICE           : string := "CHANGE THIS"; -- e.g. None, XC5VLX50T-1FF1136, EP2SGX90FF1508C3
```

`my_project.vhdl` also defines two global constants, which need to be adjusted:

```VHDL
constant MY_PROJECT_DIR      : string := "CHANGE THIS"; -- e.g. d:/vhdl/myproject/, /home/me/projects/myproject/"
constant MY_OPERATING_SYSTEM : string := "CHANGE THIS"; -- e.g. WINDOWS, LINUX
```


#### 4.4 Compiling shipped Xilinx IPCores (*.xco files) to netlists

**The PicoBlaze-Library** and the PoC-Library are shipped with some pre-configured IP cores
from Xilinx. These IPCores are shipped as \*.xco files and need to be compiled to netlists
(\*.ngc files) and there auxillary files (\*.ncf files; \*.vhdl files; ...). This can be done
by invoking PoC's `Netlist.py` through one of the provided wrapper scripts: netlist.[sh|ps1].

Compiling needed IP cores from PoC for a KC705 board:

```PowerShell
cd <ProjectRoot>
cd lib\PoC\netlist
foreach ($i in 1..15) {
  .\netlist.ps1 --coregen PoC.xil.ChipScopeICON_$i --board KC705
}
```

Compiling needed IP cores from L_PicoBlaze for a KC705 board:

```PowerShell
cd ....
cd lib\L_PicoBlaze\netlist\<DeviceString>\
# TODO: write a script to regenerate all IP Cores
```


## 5 Using PicoBlaze-Library


#### 6.1 Standalone

#### 6.1 In Xilinx ISE (XST and iSim)

#### 6.2 In Xilinx Vivado (Synth and xSim)


## 6 Configuring a System-on-FPGA with PicoBlaze-Library


## 7 Updating PicoBlaze-Library


 [wiki:requirements]:	https://github.com/Paebbels/PicoBlaze-Library/wiki/Requirements
 [wiki:dependencies]:	https://github.com/Paebbels/PicoBlaze-Library/wiki/Requirements#dependencies
 [wiki:integration]:	https://github.com/Paebbels/PicoBlaze-Library/wiki/Integration
