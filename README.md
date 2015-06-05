####Fluam a fluctuating hydrodynamic code

###Contents
1. Installation instructions
2. Use
3. Contact
4. License and Copyright



##1. Installation instructions
a) You will need a NVIDIA GPU with compute capability 1.3
or higher to use fluam. You don't need any GPU to compile 
and modify the code.

b) Third-party software: you will need the CUDA compiler
nvcc, CUDA libraries, and the cutil.h files that you can obtain
with the NVIDIA SDK package.

c) Edit the file fluam/bin/MakefileHeader
to include the right path to the NVIDIA SDK files
and the HydroGrid code in case you have it. 
Set the right architecture for your GPU in 
"NVCCFLAGS".

d) Move to fluam/bin/ and type 
make

e) To speed up the compilation process see fluam/work/README

##2. Use
To run fluam type
fluam data.main

data.main is a file with the option for the simulation, look
fluam/bin/data.main for the options.


##3. Contact
If you find problems contact the owner of the project
https://github.com/fbusabiaga/fluam


##4. License and Copyright
Source code is available at: https://github.com/fbusabiaga/fluam

Fluam is released under the terms of the GNU General Public License. See
"COPYING" for more details.

The source files included with this release are copyrighted by their
authors. See each file for more information.

