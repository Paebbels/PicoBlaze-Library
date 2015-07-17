The PicoBlaze-Library
=================================================
The PicoBlaze-Library offers several PicoBlaze devices and code routines
to extend a common PicoBlaze environment to a little System on a Chip (SoC or SoFPGA).

## Table of Content:
 1. [Overview](#1-overview)
 2. [Download](#2-download)
 3. [Requirements](#3-requirements)
	- [Dependencies](#dependencies)
	- [Common Requirements](#common-requirements)
	- [Optional Tools](#optional-tools)
 4. [Integrating PoC into projects](#4-integrating-picoblaze-library-into-projects)
 5. [Using PicoBlaze Library](#5-using-picoblaze-library)
 6. [Configuring a System-on-FPGA with PicoBlaze Library](#6-configuring-a-system-on-fpga-with-picoblaze-library)
 7. [Updating PicoBlaze Library](#7-updating-picoblaze-library)

------

> All Windows command line instructions are intended for **Windows PowerShell**, if not marked otherwise. So executing the following instructions in Windows Command Prompt (`cmd.exe`) won't function or result in errors! PowerShell is shipped with Windows since Vista. See the [requirements](Requirements) wiki page on where to download or update PowerShell.

## 1 Overview




## 2 Download

The PicoBlaze-Library can be downloaded as a [zip-file][download] or
cloned with `git clone` from GitHub. For SSH protocol use the URL `ssh://git@github.com:Paebbels/PicoBlaze-Library.git` or the command line instruction:

    cd <GitRoot>
    git clone --recursive git@github.com:Paebbels/PicoBlaze-Library.git L_PicoBlaze

**Note:** The option `--recursive` performs a recursive clone operation for all integrated [git submodules][git_submod]. An additional `git submodule init` and `git submodule update` is not needed anymore. 

The library is meant to be included into another git repository as a git submodule. This can be achieved with the following instructions:

    cd <ProjectRoot>
    mkdir lib -ErrorAction SilentlyContinue; cd lib
    git submodule add git@github.com:Paebbels/PicoBlaze-Library.git L_PicoBlaze
    cd L_PicoBlaze
    git remote rename origin github
    cd ..\..
    git add .gitmodules "lib\L_PicoBlaze"
    git commit -m "Added new git submodule L_PicoBlaze in 'lib\L_PicoBlaze' (PicoBalze-Library)."

A detailed explanation and full command line examples for Windows and Linux are provided on the [Download](Download) wiki page.

 [download]: https://github.com/Paebbels/PicoBlaze-Library/archive/master.zip

## 3 Requirements

##### Dependencies

The PicoBlaze Library depends on [**The PoC-Library**][poc], a platform independent HDL library, and
the [**Open PicoBlaze Assembler**][opbasm], a free and freature rich assembler for the PicoBlaze
processor. Both dependencies are available as GitHub repositories and can be downloaded via by `git clone` command. Alternatively, zip-files are offered by GitHub to download the latest `master` branches.

See the [dependencies](Requirements#dependencies) wiki page for more details. There is also a detailed page on [Integrating the PicoBlaze-Library into User Projects](Integration).

 [poc]:      https://github.com/VLSI-EDA/PoC
 [opbasm]:   https://github.com/kevinpt/opbasm

##### Common Requirements

A VHDL synthesis tool chain is need to compile all source files into a FPGA configuration. The library supports Xilinx ISE 14.7 and Xilinx Vivado 2015.2. If needed, a Xilinx tools compatible simulation tool chain can be used to simulate and debug the system or parts of it.

See the [requirements](Requirements#common-requirements) wiki page for more details.  


##### Optional Tools

There are several optional tools, which ease the use of this library or it's dependencies.

See the [optional tools](Requirements#optional-tools) wiki page for more details.


## 4 Integrating the library into projects


### 4.1 Adding the library and it's dependencies as git submodules

The PicoBlaze-Library is meant to be included in other project or repos as a submodule. Therefore it's recommended to create a library folder and add the PicoBlaze-Library and it's dependencies as git submodules.

The following command line instructions will create a library folder `lib/` and clone all depenencies
as git [submodules][git_submod] into subfolders.

    function gitsubmodule([string]$dir, [string]$url, [string]$name) {
      $p = pwd
      mkdir lib -ErrorAction SilentlyContinue; cd lib
      git submodule add $url $dir
      cd $dir
      git remote rename origin github
      cd $p
      git add .gitmodules "lib\$dir"
      git commit -m "Added new git submodule $dir in 'lib\$dir' ($name)."
    }
    
    cd <ProjectRoot>
    gitsubmodule "PoC" "git@github.com:VLSI-EDA/PoC.git" "PoC-Library"
    gitsubmodule "L_PicoBlaze" "git@github.com:Paebbels/PicoBlaze-Library.git" "PicoBalze-Library"
    gitsubmodule "opbasm" "git@github.com:Paebbels/opbasm.git" "Open PicoBlaze Assembler"

[git_submod]: http://git-scm.com/book/en/v2/Git-Tools-Submodules

### 4.2 Configuring PoC on a local system

To run PoC's automated testbenches or use the netlist compilaltion scripts of PoC, it's required to configure a synthesis and simulation tool chain.

    cd <ProjectRoot>
    cd lib\PoC\
    .\poc.ps1 --configure

### 4.3 Compiling shipped Xilinx IPCores (*.xco files) to netlists

The PicoBlaze-Library and the PoC-Library are shipped with some pre-configured IPCores from Xilinx. These IPCores are shipped as \*.xco files and need to be compiled to netlists (\*.ngc files) and there auxillary
files (\*.ncf files; \*.vhdl files; ...). This can be done by invoking PoC's `Netlist.py` through one of the
provided wrapper scripts: netlist.[sh|ps1].

**Example:** Compiling all needed IPCores from PoC for a KC705 board:

    cd <ProjectRoot>
    cd lib\PoC\netlist
    foreach ($i in 1..15) {
      .\netlist.ps1 --coregen PoC.xil.ChipScopeICON_$i --board KC705
    }

**Example:** Compiling all needed IPCores from L_PicoBlaze for a KC705 board:

    cd ....
    cd lib\L_PicoBlaze\netlist\<DeviceString>\
    # TODO: write a script to regenerate all IP Cores


## 5 Using PicoBlaze-Library


### 5.1 Standalone

### 5.1 In Xilinx ISE (XST and iSim)

### 5.2 In Xilinx Vivado (Synth and xSim)


## 6 Configuring a System-on-FPGA with the library



## 7 Updating PicoBlaze Library


