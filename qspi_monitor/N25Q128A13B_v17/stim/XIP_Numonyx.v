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

    defparam Testbench.DUT.memory_file = "mem_Q128_bottom.vmf";

     integer i;

    reg [7:0] regData='b111111000;

    reg [15:0] regDataNVCR='b1111111111111111;


    reg [addrDim-1:0] A0='h0, A1, A2='h08,B1='h003300;

    initial begin


            A1='hFFFFFA;


        tasks.init;
        

        $display("\n---Enter XIP mode by setting the VCR");
          // write volatile configuration register 
        $display("\n--- Write volatile configuration register");
        tasks.write_enable;
        tasks.send_command('h81);
        regData[3] = 'b0; 
        tasks.send_data(regData);
        tasks.close_comm;
        #(write_VCR_delay+100);  

         // read volatile configuration register 
        tasks.send_command('h85);
        tasks.read(2); 
        tasks.close_comm;
        #100;
       

        // read
        $display("\n --- Read");
        tasks.send_command('h0B);
        tasks.send_address(A0);
        tasks.send_dummy('h0000,15); //dummy byte
        tasks.read(9);
        tasks.close_comm;
        #100;




        //read
        $display("\n --- Read XIP active");
        tasks.XIP_send_address(A2);
        tasks.send_dummy('h0000,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;
         
        //read
        $display("\n --- Read XIP active");
        tasks.XIP_send_address(A1);
        tasks.send_dummy('h4000,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;

 
         // read
        $display("\n --- Read XIP not active");
        tasks.send_command('h0B);
        tasks.send_address(A0);
        tasks.send_dummy('h4000,15); //dummy byte
        tasks.read_dual(9);
        tasks.close_comm;
        #100;


         $display("\n---Enter XIP mode by setting the NVCR");
          // write volatile configuration register 
        $display("\n--- Write non volatile configuration register");
        tasks.write_enable;
        tasks.send_command('hB1);
        regDataNVCR[11:9] = 'b000; 
        tasks.send_data(regDataNVCR[7:0]);
        tasks.send_data(regDataNVCR[15:8]);

        tasks.close_comm;
        #(write_NVCR_delay+100);  

         // read non volatile configuration register 
        tasks.send_command('hB5);
        tasks.read(2); 
        tasks.close_comm;
        #100;
        
          $display("\n--- Power up");

        tasks.setVcc('d0);
        #100;
        `ifdef VCC_3V
         tasks.setVcc('d3000);
        `else
        tasks.setVcc('d1800);
        `endif
        #full_access_power_up_delay;
        

        //read
        $display("\n --- Read XIP active");
        tasks.XIP_send_address(A2);
        tasks.send_dummy('h00,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;
         
        //read
        $display("\n --- Read XIP active");
        tasks.XIP_send_address(A1);
        tasks.send_dummy('h4000,15); //dummy byte
        tasks.read(3);
        tasks.close_comm;
        #100;

 
         // read
        $display("\n --- Read XIP not active");
        tasks.send_command('h0B);
        tasks.send_address(A0);
        tasks.send_dummy('h4000,15); //dummy byte
        tasks.read_dual(9);
        tasks.close_comm;
        #100;

    end  


    endmodule
