//          _/             _/_/
//        _/_/           _/_/_/
//      _/_/_/_/         _/_/_/
//      _/_/_/_/_/       _/_/_/              ____________________________________________ 
//      _/_/_/_/_/       _/_/_/             /                                           / 
//      _/_/_/_/_/       _/_/_/            /                               N25Q128A13B / 
//      _/_/_/_/_/       _/_/_/           /                                           /  
//      _/_/_/_/_/_/     _/_/_/          /                                   128Mbit / 
//      _/_/_/_/_/_/     _/_/_/         /                              SERIAL FLASH / 
//      _/_/_/ _/_/_/    _/_/_/        /                                           / 
//      _/_/_/  _/_/_/   _/_/_/       /                  Verilog Behavioral Model / 
//      _/_/_/   _/_/_/  _/_/_/      /                               Version 1.7 / 
//      _/_/_/    _/_/_/ _/_/_/     /                                           /
//      _/_/_/     _/_/_/_/_/_/    /           Copyright (c) 2011 Numonyx B.V. / 
//      _/_/_/      _/_/_/_/_/    /___________________________________________/ 
//      _/_/_/       _/_/_/_/      
//      _/_/          _/_/_/  
// 
//     
//             NUMONYX              


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           TIMING CONSTANTS                            --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


// From datasheet N25Q128 - January 2008 - Rev 1


    //--------------------------------------
    // Max clock frequency (minimum period)
    //--------------------------------------
    
    parameter fC = 108; //max frequency in Mhz
    parameter time TC = 9; //9ns=111.1Mhz
    
    parameter fR = 54; //max frequency in Mhz during standard Read operation
    parameter time TR = 18; //18ns=55.55Mhz

    //NB: in special read operations 
    // (fast read, dual output fast read, read SR, 
    // read lock register, read ID, read OTP)
    // max clock frequency is fC 
    
    //---------------------------
    // Input signals constraints
    //---------------------------

    // Clock signal constraints
    parameter time tCH = 4;
    parameter time tCL = 4;
    parameter time tSLCH = 4;
    parameter time tDVCH = 2;
    parameter time tSHCH = 4;
    parameter time tHLCH = 4;
    parameter time tHHCH = 4;

    // Chip select constraints
    parameter time tCHSL = 4;
    parameter time tCHSH = 4;
    parameter time tSHSL = 20; 
    parameter time tVPPHSL = 200; //not implemented
    parameter time tWHSL = 20;  
    
    // Data in constraints
    parameter time tCHDX = 3;

    // W signal constraints
    parameter time tSHWL = 100;  


    // HOLD signal constraints
    parameter time tCHHH = 4;
    parameter time tCHHL = 4;

     // RESET signal constraints
    parameter time tRLRH = 50; 
    parameter time tSHRH = 2; 
    parameter time tRHSL_1 = 40; //during decoding
    parameter time tRHSL_2 = 30000; //during program-erase operation (except subsector erase and WRSR)
    parameter time tRHSL_3 = 500e6;  //during subsector erase operation=tSSE
    parameter time tRHSL_4 = 15e9; //during WRSR operation=tW

    //-----------------------
    // Output signal timings
    //-----------------------

    parameter time tSHQZ = 8;
    parameter time tCLQV = 7; // 8 under 30 pF - 6 under 10 pF
    parameter time tCLQX = 1; // min value
    parameter time tHHQX = 8;  
    parameter time tHLQZ = 8;


    //--------------------
    // Operation delays
    //--------------------
    
    parameter time tDP  = 3e3;
    parameter time tRDP = 30e3; 
    parameter time tW   = 15e9;
    parameter time tPP  = 5e6;
    parameter time tSSE = 500e6;
    parameter time tSE  = 3e9;
    parameter time tBE  = 770e9;
    //aggiunta
    parameter time tWNVCR   = 15e9;
    parameter time tWVCR  = 40;
    parameter time tWRVECR = 40;
    parameter time tCFSR = 40;
    
    // Startup delays
//!    parameter time tPUW = 10e6;
    parameter time tVTR = 100e3;
    parameter time tDTW = 500e3;
    parameter time tVTW = 600e3;
//---------------------------------
// Alias of timing constants above
//---------------------------------

parameter time program_delay = tPP;
parameter time write_SR_delay = tW;
parameter time clear_FSR_delay = tCFSR;
parameter time write_NVCR_delay = tWNVCR;
parameter time write_VCR_delay = tWVCR;
parameter time write_VECR_delay = tWRVECR;

parameter time erase_delay = tSE;
parameter time erase_bulk_delay = tBE;
parameter time full_access_power_up_delay = tVTW;
parameter time read_access_power_up_delay = tVTR;
parameter time write_access_power_up_delay = tDTW;

`ifdef SubSect 
  parameter time erase_ss_delay = tSSE;
`endif

`ifdef PowDown 

  parameter time deep_power_down_delay = tDP; 
  parameter time release_power_down_delay = tRDP;
`endif

