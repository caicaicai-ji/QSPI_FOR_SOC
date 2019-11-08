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
/*---------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------

            TESTBENCH

-----------------------------------------------------------
-----------------------------------------------------------
---------------------------------------------------------*/


`timescale 1ns / 1ns

module Testbench;


    `include "include/DevParam.h"

    wire S, C;
    wire [`VoltageRange] Vcc; 
    wire clock_active;

    
    wire DQ0, DQ1;
  

    wire Vpp_W_DQ2; 

    `ifdef HOLD_pin
        wire HOLD_DQ3; 
    `endif
    

    `ifdef RESET_pin
        wire RESET_DQ3; 
    `endif
    
    
    `ifdef N25Q128A13B
    
        N25Qxxx DUT (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        Stimuli stim (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        StimTasks tasks (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);

        ClockGenerator ck_gen (clock_active, C);

   `elsif  N25Q128A23B
    
        N25Qxxx DUT (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        Stimuli stim (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        StimTasks tasks (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);

        ClockGenerator ck_gen (clock_active, C);

    `elsif  N25Q128A33B
    
        N25Qxxx DUT (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        Stimuli stim (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        StimTasks tasks (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);

        ClockGenerator ck_gen (clock_active, C);
     
   `elsif  N25Q128A43B
    
        N25Qxxx DUT (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        Stimuli stim (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        StimTasks tasks (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);

        ClockGenerator ck_gen (clock_active, C);

  `elsif  N25Q128A11B
    
        N25Qxxx DUT (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        Stimuli stim (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        StimTasks tasks (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);

        ClockGenerator ck_gen (clock_active, C);

  `elsif  N25Q128A21B
    
        N25Qxxx DUT (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        Stimuli stim (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        StimTasks tasks (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);

        ClockGenerator ck_gen (clock_active, C);

   `elsif  N25Q128A31B
    
        N25Qxxx DUT (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        Stimuli stim (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        StimTasks tasks (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);

        ClockGenerator ck_gen (clock_active, C);
     
   `elsif  N25Q128A41B
    
        N25Qxxx DUT (S, C, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        Stimuli stim (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

        StimTasks tasks (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active);

        ClockGenerator ck_gen (clock_active, C);



    `endif



endmodule    
