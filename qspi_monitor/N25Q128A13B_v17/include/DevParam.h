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
//      _/_/_/   _/_/_/  _/_/_/      /                               Version 1.6 / 
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
--           PARAMETERS OF DEVICES                       --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


//-----------------------------
//  Customization Parameters
//-----------------------------

`define timingChecks


//-- Available devices 

 
 `define N25Q128A13B // available N25Q128A13B N25Q128A23B N25Q128A33B N25Q128A43B
                     //           N25Q128A11B N25Q128A21B N25Q128A31B N25Q128A41B
                                    
//----------------------------
// Model configuration
//----------------------------


parameter dataDim = 8;
parameter dummyDim = 15;


`ifdef N25Q128A13B // HOLD_pin , XIP_Numonyx ,VCC=2.7 V to 3.6 V, bottom


    parameter [12*8:1] devName = "N25Q128A13B";

    parameter addrDim = 24;
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA;
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18;
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h12; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define bottom
    `define XIP_Numonyx

    `define VCC_3V

`elsif N25Q128A23B // HOLD_pin , XIP_basic ,VCC=2.7 V to 3.6 V, bottom


    parameter [12*8:1] devName = "N25Q128A23B";

    parameter addrDim = 24;
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA;
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18;
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h12; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define HOLD_pin
    `define SubSect
    `define bottom
    `define XIP_basic
    `define VCC_3V


 `elsif N25Q128A33B // RESET_pin , XIP_Numonyx ,VCC=2.7 V to 3.6 V, bottom


    parameter [12*8:1] devName = "N25Q128A33B";

    parameter addrDim = 24;
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA;
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18;
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h12; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define RESET_pin
    `define SubSect
    `define bottom
    `define XIP_Numonyx
    `define VCC_3V


`elsif N25Q128A43B // RESET_pin , XIP_basic ,VCC=2.7 V to 3.6 V, bottom


    parameter [12*8:1] devName = "N25Q128A43B";

    parameter addrDim = 24;
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] MemoryType_ID = 'hBA;
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18;
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h12; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define RESET_pin
    `define SubSect
    `define bottom
    `define XIP_basic
    `define VCC_3V



`elsif N25Q128A21B // HOLD_pin , XIP_basic ,VCC=1.7 V to 2 V, bottom


    parameter [12*8:1] devName = "N25Q128A21B";

    parameter addrDim = 24;
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB;
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18;
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h11; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define PowDown
    `define HOLD_pin
    `define SubSect
    `define bottom
    `define XIP_basic
    `define VCC_1_8V


`elsif N25Q128A11B // HOLD_pin , Numonyx XIP ,VCC=1.7 V to 2 V, bottom


    parameter [12*8:1] devName = "N25Q128A11B";

    parameter addrDim = 24;
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB;
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18;
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h11; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define PowDown
    `define HOLD_pin
    `define SubSect
    `define bottom
    `define XIP_Numonyx
    `define VCC_1_8V



`elsif N25Q128A31B // RESET_pin , Numonyx XIP ,VCC=1.7 V to 2 V, bottom


    parameter [12*8:1] devName = "N25Q128A31B";

    parameter addrDim = 24;
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB;
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18;
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h11; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define PowDown
    `define RESET_pin
    `define SubSect
    `define bottom
    `define XIP_Numonyx
    `define VCC_1_8V


`elsif N25Q128A41B // RESET_pin , Basic XIP ,VCC=1.7 V to 2 V, bottom


    parameter [12*8:1] devName = "N25Q128A41B";

    parameter addrDim = 24;
    parameter sectorAddrDim = 8;
    parameter [dataDim-1:0] MemoryType_ID = 'hBB;
    parameter [dataDim-1:0] MemoryCapacity_ID = 'h18;
    parameter [dataDim-1:0] UID = 'h10; 
    parameter [dataDim-1:0] EDID_0 = 'h11; 
    parameter [dataDim-1:0] EDID_1 = 'h00; 
    parameter [dataDim-1:0] CFD_0 = 'h0; 
    parameter [dataDim-1:0] CFD_1 = 'h0; 
    parameter [dataDim-1:0] CFD_2 = 'h0; 
    parameter [dataDim-1:0] CFD_3 = 'h0; 
    parameter [dataDim-1:0] CFD_4 = 'h0; 
    parameter [dataDim-1:0] CFD_5 = 'h0; 
    parameter [dataDim-1:0] CFD_6 = 'h0; 
    parameter [dataDim-1:0] CFD_7 = 'h0; 
    parameter [dataDim-1:0] CFD_8 = 'h0; 
    parameter [dataDim-1:0] CFD_9 = 'h0;
    parameter [dataDim-1:0] CFD_10 = 'h0; 
    parameter [dataDim-1:0] CFD_11 = 'h0; 
    parameter [dataDim-1:0] CFD_12 = 'h0; 
    parameter [dataDim-1:0] CFD_13 = 'h0; 
   
    `define PowDown
    `define RESET_pin
    `define SubSect
    `define bottom
    `define XIP_basic
    `define VCC_1_8V


    
`endif





//----------------------------
// Include TimingData file 
//----------------------------


`include "/home/lvrj/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/TimingData.h"





//----------------------------------------
// Parameters constants for all devices
//----------------------------------------

`define VoltageRange 31:0




//---------------------------
// stimuli clock period
//---------------------------
// for a correct behavior of the stimuli, clock period should
// be multiple of 4

 parameter time T = 40;






//-----------------------------------
// Devices Parameters 
//-----------------------------------


// data & address dimensions

parameter cmdDim = 8;
parameter addrDimLatch = 24;


// memory organization

parameter memDim = 2 ** addrDim; 

parameter colAddrDim = 8;
parameter colAddr_sup = colAddrDim-1;
parameter pageDim = 2 ** colAddrDim;

parameter nSector = 2 ** sectorAddrDim;
parameter sectorAddr_inf = addrDim-sectorAddrDim; 

parameter sectorAddr_sup = addrDim-1;
parameter sectorSize = 2 ** (addrDim-sectorAddrDim);

 parameter bootSec_num = 8; 
 parameter subsecAddrDim = 4+sectorAddrDim;
 parameter subsecAddr_inf = 12;
 parameter subsecAddr_sup = addrDim-1;
 parameter subsecSize = 2 ** (addrDim-subsecAddrDim);
 

parameter pageAddrDim = addrDim-colAddrDim;
parameter pageAddr_inf = colAddr_sup+1;
parameter pageAddr_sup = addrDim-1;




// OTP section

 parameter OTP_dim = 65;
 parameter OTP_addrDim = 7;



//  signature 

parameter [dataDim-1:0] Manufacturer_ID = 'h20;



// others constants

parameter [dataDim-1:0] data_NP = 'hFF;



`ifdef VCC_3V

parameter [`VoltageRange] Vcc_wi = 'd2500; //write inhibit 
parameter [`VoltageRange] Vcc_min = 'd2700;
parameter [`VoltageRange] Vcc_max = 'd3600;

`else 

parameter [`VoltageRange] Vcc_wi = 'd1500; //write inhibit 
parameter [`VoltageRange] Vcc_min = 'd1700;
parameter [`VoltageRange] Vcc_max = 'd2000;

`endif

//-------------------------
// Alias used in the code
//-------------------------


// status register code

`define WIP N25Qxxx.stat.SR[0]

`define WEL N25Qxxx.stat.SR[1]

`define BP0 N25Qxxx.stat.SR[2]

`define BP1 N25Qxxx.stat.SR[3]

`define BP2 N25Qxxx.stat.SR[4]

`define TB N25Qxxx.stat.SR[5]

`define BP3 N25Qxxx.stat.SR[6]

`define SRWD N25Qxxx.stat.SR[7]









