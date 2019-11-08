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



`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file
  

      defparam Testbench.DUT.memory_file =  "mem_Q128_bottom.vmf";


    reg [addrDim-1:0] A='h0, B='h10;
    
    reg [`VoltageRange] V0='d0, V1=Vcc_wi, V2=Vcc_min;



    initial begin

        tasks.init;
       
       `ifdef PowDown
        tasks.send_command('hB9);
        tasks.close_comm;
        #deep_power_down_delay;

        tasks.send_command('h03);
        tasks.send_address('h00);
        tasks.read(1);
        tasks.close_comm;

        tasks.send_command('hAB);
        tasks.close_comm;
        #release_power_down_delay;

        `endif

    end


endmodule    
