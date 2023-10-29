@ECHO OFF
SET vivado=C:\Xilinx\Vivado\2019.1\bin\vivado.bat
%vivado% -mode batch -source build.tcl
