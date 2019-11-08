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


    reg [dataDim-1:0] regData = 'h0;

    integer i;

    integer N;
    


    initial begin

          N=15;


        tasks.init;


        //-----------------------------------
        // Testing status register lock bits
        //-----------------------------------
        // serve per verificare se la corrispondenza
        //   bit di lock dello StatusReg <---> settori lockati
        //   e' quella prevista nel datasheet
        
        // write status register 
        
        for (i=0; i<=N; i=i+1) begin
              $display("\n-----Testing status register lock bits: (BP3,TB,BP2,BP1,BP0)=%5b",i);
            tasks.write_enable;
            tasks.send_command('h01);
            regData[6:2]=i; //(BP3,TB,BP2,BP1,BP0)=data
            tasks.send_data(regData); 
            tasks.close_comm;
            #write_SR_delay;
        end

        $display("\n-----Testing HPM");
        //setting W(W=0)
        tasks.set_Vpp_W(0);
        //setting SRWD to 1       
        tasks.write_enable;
        tasks.send_command('h01);
        regData[7:2]='h20; //(BP3,TB,BP2,BP1,BP0)=data
        tasks.send_data(regData); 
        tasks.close_comm;
        #write_SR_delay;

        $display("\n-----Write status register error");
        tasks.write_enable;
        tasks.send_command('h01);
        regData[6:2]='h0; //(BP3,TB,BP2,BP1,BP0)=data
        tasks.send_data(regData); 
        tasks.close_comm;
        #write_SR_delay;


    end


endmodule    
