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
    
    
//--------------------------------------------------------------------------------
// This module generates the clock signal.
// The module is driven by "clock_active" signal, coming from "StimTasks" module.
// 
// (NB: Tasks of StimTasks module are invoked in "Stimuli" module).
//--------------------------------------------------------------------------------
`timescale 1ns / 1ns
    
    
module ClockGenerator (clock_active, C);

`include "include/DevParam.h"

input clock_active;
output C;
reg C;
   
   
    always begin : clock_generator

        if (clock_active) begin
            C = 1; #(T/2);
            C = 0; #(T/2);
        end else begin
            C = 0;
            @ clock_active;
        end

    end



endmodule    
