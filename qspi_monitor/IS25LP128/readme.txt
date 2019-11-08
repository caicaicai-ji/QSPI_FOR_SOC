          _/             _/_/
        _/_/           _/_/_/
      _/_/_/_/         _/_/_/
      _/_/_/_/_/       _/_/_/              ____________________________________________ 
      _/_/_/_/_/       _/_/_/             /                                           / 
      _/_/_/_/_/       _/_/_/            /                               N25Q128A13B / 
      _/_/_/_/_/       _/_/_/           /                                           /  
      _/_/_/_/_/_/     _/_/_/          /                                   128Mbit / 
      _/_/_/_/_/_/     _/_/_/         /                              SERIAL FLASH / 
      _/_/_/ _/_/_/    _/_/_/        /                                           / 
      _/_/_/  _/_/_/   _/_/_/       /                  Verilog Behavioral Model / 
      _/_/_/   _/_/_/  _/_/_/      /                               Version 1.7 / 
      _/_/_/    _/_/_/ _/_/_/     /                                           /
      _/_/_/     _/_/_/_/_/_/    /           Copyright (c) 2011 Numonyx B.V. / 
      _/_/_/      _/_/_/_/_/    /___________________________________________/ 
      _/_/_/       _/_/_/_/      
      _/_/          _/_/_/  
 
     
             NUMONYX              

This README provides information on the following topics :

- VERILOG Behavioral Model description
- Version History
- Install / uninstall information
- File list
- Get support
- Bug reports
- Send feedback / requests for features
- Known issues
- Ordering information


-------------------------------------
VERILOG BEHAVIORAL MODEL DESCRIPTION
-------------------------------------

Behavioral modeling is a technic for the description of an hardware architecture at an 
algorithmic level where the designers do not necessarily think in terms of
logic gates or data flow, but in terms of the algorithm and its performance.
Only after the high-level architecture and algorithm are finalized, the designers 
start focusing on building the digital circuit to implement the algorithm.
To obtain this behavioral model we have used VERILOG Language.



---------------
VERSION HISTORY
---------------
Version 1.7

        Date    :   21/06/2011

        Note    :   added default dummycount functionality
                    when nvcr is set to default 15, dummy count is 8 for all
                    protocols except for Quad, then it is 10
        Developed by :
                         Rima Nazanda
        This version is based on the Datasheet: N25Q128 / Rev 3 /3-Sep 2009


Version 1.6

        Date    :   23/03/2011  

        Note    :   Minor bugs fixed.
            
        Developed by : 
            Lucia Di Martino

        This version is based on the Datasheet: N25Q128 / Rev 3 /3-Sep 2009


Version 1.5

        Date    :   24/02/2011  

        Note    :   Extended XIP bug fixed.
            
            Sector Erase in quad protocol bug fixed.
            
        Developed by : 
            Lucia Di Martino

        This version is based on the Datasheet: N25Q128 / Rev 3 /3-Sep 2009

 

Version 1.4

        Date    :   17/02/2011  

        Note    :    
            
            Sector Erase in quad protocol bug fixed.
            
        Developed by : 
            Lucia Di Martino

        This version is based on the Datasheet: N25Q128 / Rev 3 /3-Sep 2009


Version 1.3

        Date    :   10/12/2010  

        Note    :    
            
            Minor bug fixed.
            A race condition occured at posegde clock 

        Developed by : 
            Lucia Di Martino

        This version is based on the Datasheet: N25Q128 / Rev 3 /3-Sep 2009


Version 1.2

        Date    :   17/11/2010  

        Note    :    
            
            Minor bugs fixing

        Developed by : 
            Lucia Di Martino

        This version is based on the Datasheet: N25Q128 / Rev 3 /3-Sep 2009

 
Version 1.1

        Date    :   13/09/2010  

        Note    :    
            
            Added dummy clock cycles configuration

        Developed by : 
            Lucia Di Martino

        This version is based on the Datasheet: N25Q128 / Rev 3 /3-Sep 2009


Version 1.0

        Date    :   01/07/2010  

        Note    :    
            
            First release.

        Developed by : 
            Lucia Di Martino

        This version is based on the Datasheet: N25Q128 / Rev 3 /3-Sep 2009



---------------------------------
INSTALL / UNINSTALL INFORMATION
---------------------------------

For installing the model you have to process the NU_N25Q128A13B_3V_128Mb_65nm_VG1.5.zip delivery package.  

Compatibility: the model has been tested by Cadence NCsim 5.7 simulator, on SUN OS environment.

IMPORTANT:

******************************************************************************   
  
    THIS PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,        
    EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO, THE        
    IMPLIED WARRANTY OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR      
    PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF         
    THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU      
    ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.     
  
******************************************************************************





--------------------------------
  FILE LIST ("model" directory)
--------------------------------

main directory :

    ./readme.txt
    ./run_ncsim
    ./run_modelsim


code (source code files) 
    
    code/N25Q128A13B.v


include (source header files)

    include/DevParam.h
    include/TimingData.h
    include/Decoders.h


top (testbech file for simulation)

    top/StimGen_interface.h
    top/Testbench.v
    top/StimTasks.v
    top/ClockGenerator.v


stim (stimuli files for simulation) 

    stim/read.v
    stim/program.v
    stim/erase.v    
    stim/lock1.v
    stim/lock2.v
    stim/XIP_test.v
    stim/otp.v
    stim/lock_test_SR.v
    stim/power_up.v
    stim/test_protocol.v
    stim/test_reg.v



doc (model documentation) 

    doc/UserManual.pdf 


sim (files for simulation) 

    sim/mem_Q128_bottom.vmf
    

	

