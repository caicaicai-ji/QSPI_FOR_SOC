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



/*-------------------------------------------------------------------------
-- The procedures here following may be used to send
-- commands to the serial flash.
-- These procedures must be combined using one of the following sequences:
--  
-- 1) send_command / close_comm 
-- 2) send_command / send_address / close_comm
-- 3) send_command / send_address / send_data /close_comm
-- 4) send_command / send_address / read / close_comm
-- 5) send_command / read / close_comm
-------------------------------------------------------------------------*/

`timescale 1ns / 1ns

module StimTasks (S, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, clock_active); 


`include "include/DevParam.h"

    output S;
    reg S;
    
    output [`VoltageRange] Vcc;
    reg [`VoltageRange] Vcc;

    output clock_active;
    reg clock_active;

    
    output DQ0, DQ1; 
    reg DQ0='bZ; reg DQ1='bZ; 
    
    output Vpp_W_DQ2;
    reg Vpp_W_DQ2;

    
    `ifdef HOLD_pin
        output HOLD_DQ3; reg HOLD_DQ3; 
    `endif
    
    `ifdef RESET_pin
        output RESET_DQ3; reg RESET_DQ3; 
    `endif



    //-----------------
    // Initialization
    //-----------------


    task init;
    begin
        
        S = 1;
        `ifdef HOLD_pin
          HOLD_DQ3 = 1; 
        `endif
        `ifdef RESET_pin
          RESET_DQ3 = 1;
        `endif
        power_up;

    end
    endtask

//init if FAST POR is selected
     task init_FastPOR;
    begin
        
        S = 1;
        `ifdef HOLD_pin
          HOLD_DQ3 = 1; 
        `endif
        `ifdef RESET_pin
          RESET_DQ3 = 1;
        `endif
        power_up;

    end
    endtask


    task power_up;
    begin
      `ifdef VCC_3V
        Vcc='d3000;
      `else
         Vcc='d1800;
      `endif
        Vpp_W_DQ2=1;
        #(full_access_power_up_delay+100);

    end
    endtask

   //power if FAST POR is selected

    task power_up_FastPOR_read;
    begin
         
      `ifdef VCC_3V
        Vcc='d3000;
      `else
         Vcc='d1800;
      `endif
  
        Vpp_W_DQ2=1;
        #(read_access_power_up_delay+100);
        
    end
    endtask

  task power_up_FastPOR_complete;
    begin

        send_command('h06); //write enable
        close_comm;
        #(write_access_power_up_delay+100);
        
    end
    endtask





    //----------------------------------------------------------
    // Tasks for send commands, send adressses, and read memory
    //----------------------------------------------------------


    task send_command;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin

        clock_active = 1;  #(T/4);
        S=0; #(T/4); 

        
        for (i=cmdDim-1; i>=1; i=i-1) begin
            DQ0=cmd[i]; #T;
        end

        DQ0=cmd[0]; #(T/2+T/4); 


    end
    endtask



   task send_command_dual;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin

        clock_active = 1;  #(T/4);
        S=0; #(T/4); 
        

        for (i=cmdDim-1; i>=3; i=i-2) begin
             DQ1=cmd[i]; 
             DQ0=cmd[i-1];
             #T;
        end
        DQ1 =cmd[1];
        DQ0=cmd[0]; #(T/2+T/4); 
        DQ1=1'bZ;



    end
    endtask


    task send_command_quad;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin

        clock_active = 1;  #(T/4);
        S=0; #(T/4); 
        

        for (i=cmdDim-1; i>=7; i=i-4) begin
            `ifdef HOLD_pin
             HOLD_DQ3=cmd[i];
             `endif
             `ifdef RESET_pin
              RESET_DQ3 = 1;
             `endif

             Vpp_W_DQ2=cmd[i-1];
             DQ1=cmd[i-2]; 
             DQ0=cmd[i-3];
            #T;
        end    
            `ifdef HOLD_pin
             HOLD_DQ3=cmd[i];
            `endif
            `ifdef RESET_pin
              RESET_DQ3 =cmd[i];
            `endif
            Vpp_W_DQ2=cmd[i-1];
            DQ1=cmd[i-2]; 
            DQ0=cmd[i-3]; #(T/2+T/4);
         
           `ifdef HOLD_pin
            HOLD_DQ3=1'bZ;
           `endif
           `ifdef RESET_pin 
            RESET_DQ3 = 1'bZ;
           `endif
           Vpp_W_DQ2=1'bZ;
           DQ1=1'bZ;




    end
    endtask



    task send_address;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin

        #(T/4);



        for (i=addrDim-1; i>=1; i=i-1) begin
            DQ0 = addr[i]; #T;
        end    

        DQ0 = addr[0];  #(T/2+T/4);


    end
    endtask 


 task XIP_send_address;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin
        
        clock_active = 1;  #(T/4);
        S=0;  
        #(T/4);


        for (i=addrDim-1; i>=1; i=i-1) begin
            DQ0 = addr[i]; #T;
        end    

        DQ0 = addr[0];  #(T/2+T/4);


    end
    endtask 


  task send_address_dual;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin

        #(T/4);

        for (i=addrDim-1; i>=3; i=i-2) begin
            DQ1 = addr[i];
            DQ0 = addr[i-1];
            #T;
        end    
        DQ1 = addr[1];
        DQ0 = addr[0];  #(T/2+T/4);
        DQ1=1'bZ;


    end
    endtask 

    task XIP_send_address_dual;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin
        clock_active = 1;  #(T/4);
        S=0;
        #(T/4);

        for (i=addrDim-1; i>=3; i=i-2) begin
            DQ1 = addr[i];
            DQ0 = addr[i-1];
            #T;
        end    
        DQ1 = addr[1];
        DQ0 = addr[0];  #(T/2+T/4);
        DQ1=1'bZ;


    end
    endtask 

    task send_address_quad;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin

        #(T/4);

        for (i=addrDim-1; i>=7; i=i-4) begin
            `ifdef HOLD_pin
            HOLD_DQ3=addr[i];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=addr[i];
            `endif

            Vpp_W_DQ2=addr[i-1];
            DQ1 = addr[i-2];
            DQ0 = addr[i-3];
            #T;
        end 
            `ifdef HOLD_pin
            HOLD_DQ3=addr[i];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=addr[i];
            `endif

            Vpp_W_DQ2=addr[i-1];
            DQ1 = addr[i-2];
            DQ0 = addr[i-3]; #(T/2+T/4);

        `ifdef HOLD_pin
        HOLD_DQ3=1'bZ;
        `endif
        `ifdef RESET_pin
          RESET_DQ3=1'bZ;
        `endif

        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;


    end
    endtask 


    task XIP_send_address_quad;

    input [addrDim-1 : 0] addr;

    integer i;
    
    begin
        
        clock_active = 1;  #(T/4);
        S=0;
        #(T/4);

        for (i=addrDim-1; i>=7; i=i-4) begin
           
           `ifdef HOLD_pin
            HOLD_DQ3=addr[i];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=addr[i];
            `endif
            Vpp_W_DQ2=addr[i-1];
            DQ1 = addr[i-2];
            DQ0 = addr[i-3];
            #T;
        end  
            
            `ifdef HOLD_pin
            HOLD_DQ3=addr[i];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=addr[i];
            `endif
            Vpp_W_DQ2=addr[i-1];
            DQ1 = addr[i-2];
            DQ0 = addr[i-3]; #(T/2+T/4);
        
         `ifdef HOLD_pin
        HOLD_DQ3=1'bZ;
        `endif
        `ifdef RESET_pin
          RESET_DQ3=1'bZ;
        `endif

        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;


    end
    endtask 



    task send_data;

    input [dataDim-1:0] data;
    
    integer i;
    
    begin

        #(T/4);

        
        for (i=dataDim-1; i>=1; i=i-1) begin
            DQ0=data[i]; #T;
        end

        DQ0=data[0]; #(T/2+T/4); 


    end
    endtask





        task send_data_dual;

        input [dataDim-1:0] data;
        
        integer i;
        
        begin

            #(T/4);

            
            for (i=dataDim-1; i>=3; i=i-2) begin
                DQ1=data[i]; 
                DQ0=data[i-1];
                #T;
            end

            DQ1=data[1];
            DQ0=data[0]; #(T/2+T/4);
            DQ1=1'bZ;


        end
        endtask



        task send_data_quad;

        input [dataDim-1:0] data;
        
        integer i;
        
        begin

            #(T/4);

            
            for (i=dataDim-1; i>=7; i=i-4) begin
                
                `ifdef HOLD_pin
                HOLD_DQ3=data[i];
                `endif
                `ifdef RESET_pin
                RESET_DQ3=data[i];
                `endif
                Vpp_W_DQ2=data[i-1];
                DQ1=data[i-2]; 
                DQ0=data[i-3];
                #T;
            end
            
            `ifdef HOLD_pin
            HOLD_DQ3=data[3];
            `endif
            `ifdef RESET_pin
            RESET_DQ3=data[3];
            `endif

            Vpp_W_DQ2=data[2];
            DQ1=data[1];
            DQ0=data[0]; #(T/2+T/4);
            
            `ifdef HOLD_pin
            HOLD_DQ3=1'bZ;
            `endif
            `ifdef RESET_pin
             RESET_DQ3=1'bZ;
            `endif
            Vpp_W_DQ2=1'bZ;
            DQ1=1'bZ;


        end
        endtask


task send_dummy;

    input [dummyDim-1:0] data;

    input integer n;
    
    integer i;
    
    begin

        #(T/4);

        for (i=n-1; i>=1; i=i-1) begin
            DQ0=data[i]; #T;
        end

        DQ0=data[0]; #(T/2+T/4); 


    end
    endtask

  task send_dummy_dual;

    input [dummyDim-1:0] data;

    input integer n;
    
    integer i;
    
    begin

        #(T/4);

        for (i=n-1; i>=1; i=i-1) begin
            DQ1=data[i]; 
            DQ0=data[i]; #T;
        end
        
        DQ1=data[0];
        DQ0=data[0]; #(T/2+T/4); 
       
        DQ1=1'bZ;

    end
    endtask




   task send_dummy_quad;

    input [dummyDim-1:0] data;

    input integer n;

    
    integer i;
    
    begin

        #(T/4);

        
        for (i=n-1; i>=1; i=i-1) begin
           
           `ifdef HOLD_pin
             HOLD_DQ3=data[i];
           `endif
           `ifdef RESET_pin
             RESET_DQ3=data[i];
           `endif
             Vpp_W_DQ2=data[i];

             DQ1=data[i]; 
             DQ0=data[i]; #T;
        end
        
        `ifdef HOLD_pin
         HOLD_DQ3=data[0];
        `endif
        `ifdef RESET_pin
         RESET_DQ3=data[0];
        `endif
        Vpp_W_DQ2=data[0];
        DQ1=data[0];
        DQ0=data[0]; #(T/2+T/4); 
       `ifdef HOLD_pin
         HOLD_DQ3=1'bZ;
       `endif
       `ifdef RESET_pin
        RESET_DQ3=1'bZ;
       `endif

        Vpp_W_DQ2=1'bZ;
        DQ1=1'bZ;


    end
    endtask



    task read;

    input n;
    integer n, i;

    for (i=1; i<=n; i=i+1) begin 
        #(8*T);
    end  

    endtask



    
    task read_dual;

    input n;
    integer n, i;

    begin
    DQ0 = 1'bZ;
    for (i=1; i<=2*n; i=i+1) begin 
        #(4*T);
    end   
    end
    endtask

   
   task read_quad;

    input n;
    integer n, i;

    begin
    DQ0 = 1'bZ;
    for (i=1; i<=4*n; i=i+1) begin 
        #(2*T);
    end   
    end
    endtask




    // shall be used in a sequence including send command
    // and close communication tasks
    
    task add_clock_cycle;

    input integer n;
    integer i;

        for(i=1; i<=n; i=i+1) #T;

    endtask







    task close_comm;

    begin

        S = 1;
        clock_active = 0;
        # T;
        # 100;

    end
    endtask





    //------------------
    // others tasks
    //------------------


    `ifdef HOLD_pin
    task set_HOLD;
    input value;
        HOLD_DQ3 = value;
    endtask
    `endif


    task set_clock;
    input value;
        clock_active = value;
    endtask 


    task set_S;
    input value;
        S = value;
    endtask


    task setVcc;
    input [`VoltageRange] value;
        Vcc = value;
    endtask


    task Vcc_waveform;
    input [`VoltageRange] V1; input time t1;
    input [`VoltageRange] V2; input time t2;
    input [`VoltageRange] V3; input time t3;
    begin
      Vcc=V1; #t1;
      Vcc=V2; #t2;
      Vcc=V3; #t3;
    end
    endtask



    task set_Vpp_W;
    input value;
        Vpp_W_DQ2 = value;
    endtask



    `ifdef RESET_pin
    
    task set_RESET;
    input value;
        RESET_DQ3 = value;
    endtask

    task RESET_pulse;
    begin
        RESET_DQ3 = 0;
        #100;
        RESET_DQ3 = 1;
    end
    endtask
    
    `endif

    




    //------------------------------------------
    // Tasks to send complete command sequences
    //------------------------------------------


    task write_enable;
    begin
        send_command('h06); //write enable
        close_comm;
        #100;
    end  
    endtask

    task write_enable_dual;
    begin
        send_command_dual('h06); //write enable
        close_comm;
        #100;
    end  
    endtask

    task write_enable_quad;
    begin
        send_command_quad('h06); //write enable
        close_comm;
        #100;
    end  
    endtask

    task unlock_sector;
    input [addrDim-1:0] A;
    begin
        // write lock register (to unlock sector to be programmed)
        tasks.write_enable;
        tasks.send_command('hE5);
        tasks.send_address(A);
        tasks.send_data('h00);
        tasks.close_comm;
        #100;
    end 
    endtask

     task unlock_sector_dual;
    input [addrDim-1:0] A;
    begin
        // write lock register (to unlock sector to be programmed)
        tasks.write_enable_dual;
        tasks.send_command_dual('hE5);
        tasks.send_address_dual(A);
        tasks.send_data_dual('h00);
        tasks.close_comm;
        #100;
    end 
    endtask

     task unlock_sector_quad;
    input [addrDim-1:0] A;
    begin
        // write lock register (to unlock sector to be programmed)
        tasks.write_enable_quad;
        tasks.send_command_quad('hE5);
        tasks.send_address_quad(A);
        tasks.send_data_quad('h00);
        tasks.close_comm;
        #100;
    end 
    endtask



endmodule    
