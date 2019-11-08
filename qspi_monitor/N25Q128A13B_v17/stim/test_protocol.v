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

//-----------------------------
// For the N25Qxxx device
//-----------------------------

`timescale 1ns / 1ns


`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file

    defparam Testbench.DUT.memory_file = "";

    reg [15:0] regData='b1111111111111111;

    reg [addrDim-1:0] A0='h0, A1, A2='h08,B1='h003300;

    integer i;
    
    initial begin

            A1='hFFFFFA;


        tasks.init;
        

        // dual program
        $display("\n --- Dual program");
        tasks.write_enable;
        tasks.send_command('hA2);
        tasks.send_address(B1);
        for (i=1; i<=8; i=i+1)
            tasks.send_data_dual('hC1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command('h03);
        tasks.send_address(B1);
        tasks.read(9);
        tasks.close_comm;


       
         // write volatile configuration register 
        $display("\n--- Write volatile configuration register");
        tasks.write_enable;
        tasks.send_command('h81);
        regData[6:2] = 'b01011; 
        tasks.send_data(regData[7:0]);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command('h85);
        tasks.read(2); 
        tasks.close_comm;
        #100;


           // write non volatile configuration register 
        $display("\n--- Write non volatile configuration register");
        tasks.write_enable;
        tasks.send_command('hB1);
        regData[6:2] = 'b01001; 
        tasks.send_data(regData[7:0]);
        tasks.send_data(regData[15:8]);
        tasks.close_comm;
        #(write_NVCR_delay+100);  


        $display("\n--- Power up");

        tasks.setVcc('d0);
        #100;
        tasks.setVcc('d1800);
        #full_access_power_up_delay;
         // read non volatile configuration register 
         $display("\n--- Read non volatile configuration register");

        tasks.send_command_quad('hB5);
        tasks.read_quad(2); 
        tasks.close_comm;
        #100;

          // write volatile enhanced configuration register 
        $display("\n--- Write volatile enhanced configuration register");
        tasks.write_enable_quad;
        tasks.send_command_quad('h61);
        regData[6:2] = 'b00011; 
        tasks.send_data_quad(regData[7:0]);
        tasks.close_comm;
        #(write_VECR_delay+100);  

         // read non volatile configuration register 
        $display("\n--- Read volatile  enhanced configuration register");
 
        tasks.send_command_dual('h65);
        tasks.read(2); 
        tasks.close_comm;
        #100;
        
          // Dual read  
        $display("\n---Testing dual command fast read");
        $display("\n---0B");
        tasks.send_command_dual('h0B);
        tasks.send_address_dual(A1);
        tasks.send_dummy_dual('h80); //dummy byte
        tasks.read_dual(8);
        tasks.close_comm;
        #100;

        $display("\n---Testing dual command fast read");
        $display("\n---3B");
        tasks.send_command_dual('h3B);
        tasks.send_address_dual(A0);
        tasks.send_dummy_dual('h80); //dummy byte
        tasks.read_dual(3);
        tasks.close_comm;
        #100;

        $display("\n---Testing dual command fast read");
        $display("\n---BB");
        tasks.send_command_dual('hBB);
        tasks.send_address_dual(A2);
        tasks.send_dummy_dual('h80); //dummy byte
        tasks.read_dual(3);
        tasks.close_comm;
        #100;

         $display("\n --- Dual command Page program");
        tasks.write_enable_dual;
        tasks.send_command_dual('hA2);
        tasks.send_address_dual(B1);
        for (i=1; i<=8; i=i+1)
            tasks.send_data_dual('hC1);
        tasks.close_comm;
        #(program_delay+100);

        // read
        $display("\n --- Read");
        tasks.send_command_dual('h0B);
        tasks.send_address_dual(B1);
        tasks.send_dummy_dual('h00); //dummy byte
        tasks.read_dual(9);
        tasks.close_comm;
        #100;



    end  


    endmodule
