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


module Stimuli (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
//!module Stimuli (S, RESET_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);
    `include "include/DevParam.h"
   
   
    output S;
    output [`VoltageRange] Vcc;

    inout DQ0, DQ1; 

    inout Vpp_W_DQ2;

    `ifdef HOLD_pin
        inout HOLD_DQ3; 
    `endif
    

    `ifdef RESET_pin
       inout RESET_DQ3;
    `endif
   
   
