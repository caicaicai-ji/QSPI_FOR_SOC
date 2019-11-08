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

`timescale 1ns / 1ns



`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file
    
    defparam Testbench.DUT.memory_file = "";





    reg [addrDim-1:0] A1='h01ABCD1; 
    


    initial begin

        tasks.init;

        //--------------------------------------------------------
        // Testing locking features controlled by lock registers 
        //--------------------------------------------------------

        $display("\n\n-----Testing lock register features.\n");

        // read lock register
        tasks.send_command('hE8);
        tasks.send_address(A1);
        tasks.read(2);
        tasks.close_comm;
        #100;

         // page program ok
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A1);
        tasks.send_data('h1A);
        tasks.send_data('h2B);
        tasks.close_comm;
        #(program_delay+100);

        // read 1
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(3);
        tasks.close_comm;
        
        // write lock register (to lock sector to be programmed)
        tasks.write_enable;
        tasks.send_command('hE5);
        tasks.send_address(A1);
        tasks.send_data('h01);
        tasks.close_comm;
        #100;

        // read lock register
        tasks.send_command('hE8);
        tasks.send_address(A1);
        tasks.read(1);
        tasks.close_comm;
        #100;
        
         // page program (error)
        $display("\n Page Program (error)");
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A1);
        tasks.send_data('h1A);
        tasks.send_data('h2B);
        tasks.close_comm;
        #100;

        // read 1
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(3);
        tasks.close_comm;
        

        
        // write lock register (lock down sector programmed)
        tasks.write_enable;
        tasks.send_command('hE5);
        tasks.send_address(A1);
        tasks.send_data('h02);
        tasks.close_comm;
        #100;

        // write lock register (error because sector is locked down)
        tasks.write_enable;
        tasks.send_command('hE5);
        tasks.send_address(A1);
        tasks.send_data('h03);
        tasks.close_comm;
        #100;

    
    end


endmodule    
