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
    
        parameter [20*8:1] mem = "mem_Q128_bottom.vmf";
    
    defparam Testbench.DUT.memory_file = mem;

    // transactions handles
    integer trans, fiber;


    reg [addrDim-1:0] S0='h080000; //sector 8
    reg [addrDim-1:0] S1='h08FFFE; //sector 8 last columns
    
    reg [addrDim-1:0] SS0='h07F000; //sector 7, last subsector (subsector begin) 
    reg [addrDim-1:0] SS1='h07FFFE; //sector 7, last subsector (subsector end)
    

    
      reg [addrDim-1:0] addr='hFFFFFA; //location programmed in memory file
    
    reg [dataDim-1:0] regData = 'h0;

    integer i;
    


    initial begin

        

        tasks.init;





        //---------------
        // Sector erase 
        //---------------

        $display("\n---- Sector erase");

        // sector erase 
        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(S0); 
        tasks.close_comm;
        #(erase_delay+100);

        // read 1 (begin of the sector) 
        tasks.send_command('h03);
        tasks.send_address(S0);
        tasks.read(3);
        tasks.close_comm;

        // read 2 (end of the sector) 
        tasks.send_command('h03);
        tasks.send_address(S1);
        tasks.read(4);
        tasks.close_comm;


         $display("\n---- Sector erase with suspend");
         // sector erase 
        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(S0); 
        tasks.close_comm;
        #100;
        $display("\n --- sector erase suspend");
        tasks.send_command('h75);
        tasks.close_comm;
        #200;

        $display("\n --- program");
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(SS0);
        for (i=1; i<=8; i=i+1)
            tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);

        $display("\n --- erase resume");

        tasks.send_command('h7A);
        tasks.close_comm;

        #(erase_delay+100);

        $display("\n---- Sector erase with suspend");
         // sector erase 
        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(S0); 
        tasks.close_comm;
        #100;
        $display("\n --- sector erase suspend");
        tasks.send_command('h75);
        tasks.close_comm;
        #200;
        
        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(SS0); 
        tasks.close_comm;
        #(erase_delay+100);




        $display("\n --- erase resume");

        tasks.send_command('h7A);
        tasks.close_comm;

        #(erase_delay+100);

        
        


        
        `ifdef SubSect
        
            //-----------------
            // Subsector erase 
            //-----------------

            $display("\n---- Subsector erase");

            // reload memory file
            DUT.f.load_memory_file(mem);

            // subsector esase 
            tasks.write_enable;
            tasks.send_command('h20);
            tasks.send_address(SS0); 
            tasks.close_comm;
            #(erase_ss_delay+100);

            // read 1 (begin of subsector) 
            tasks.send_command('h03);
            tasks.send_address(SS0);
            tasks.read(3);
            tasks.close_comm;

            // read 2 (end of subsector) 
            tasks.send_command('h03);
            tasks.send_address(SS1);
            tasks.read(4);
            tasks.close_comm;



            $display("\n---- Subsector erase");

            // reload memory file
            DUT.f.load_memory_file(mem);

            // subsector esase 
            tasks.write_enable;
            tasks.send_command('h20);
            tasks.send_address(SS0); 
            tasks.close_comm;
            #100;
            $display("\n --- subsector erase suspend");
            tasks.send_command('h75);
            tasks.close_comm;
            #200;
            tasks.send_command('h03);
            tasks.send_address(S0);
            tasks.read(3);
            tasks.close_comm;
            $display("\n --- erase resume");

            tasks.send_command('h7A);
            tasks.close_comm;

            #(erase_ss_delay);

            // read 1 (begin of subsector) 
            tasks.send_command('h03);
            tasks.send_address(SS0);
            tasks.read(3);
            tasks.close_comm;

            // read 2 (end of subsector) 
            tasks.send_command('h03);
            tasks.send_address(SS1);
            tasks.read(4);
            tasks.close_comm;

        `endif



        //-----------------
        // Bulk erase 
        //-----------------

        $display("\n---- Bulk erase");

        // reload memory file
        DUT.f.load_memory_file(mem);

            
            // write lock register (to lock one sector)
            tasks.write_enable;
            tasks.send_command('hE5);
            tasks.send_address(S0);
            tasks.send_data('h01);
            tasks.close_comm;
            #100;

            // bulk erase (error) 
            tasks.write_enable;
            tasks.send_command('hC7);
            tasks.close_comm;
            #100;

            // write lock register (to unlock the sector)
            tasks.write_enable;
            tasks.send_command('hE5);
            tasks.send_address(S0);
            tasks.send_data('h00);
            tasks.close_comm;
            #100;
        
        // clear flag status register 
        tasks.send_command('h50);
        tasks.close_comm;
        #clear_FSR_delay;


        // bulk erase (ok) 
        tasks.write_enable;
        tasks.send_command('hC7);
        tasks.close_comm;
        #100;

        // read SR 
        tasks.send_command('h05);
        tasks.read(2);
        tasks.close_comm;
        #erase_bulk_delay;
        
        // read  
        tasks.send_command('h03);
        tasks.send_address(addr);
        tasks.read(3);
        tasks.close_comm;
        



    end


endmodule    
