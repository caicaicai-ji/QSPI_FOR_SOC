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

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           TOP LEVEL MODULE                            --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/



module N25Qxxx (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2);

`include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"

input S;
input C;
input [`VoltageRange] Vcc;

inout DQ0; 
inout DQ1;

`ifdef HOLD_pin
inout HOLD_DQ3; //input HOLD, inout DQ3
`endif

`ifdef RESET_pin
inout RESET_DQ3; //input RESET, inout DQ3

`endif

inout Vpp_W_DQ2; //input Vpp_W, inout DQ2 (VPPH not implemented)


parameter [72*8:1] memory_file = "../sim_common/dpram_8.coe";
reg PollingAccessOn = 0;
reg ReadAccessOn = 0;
wire WriteAccessOn; 

// indicate type of data that will be latched by the model:
//  C=command, A=address, I= address on two pins; E= address on four pins; D=data, N=none, Y=dummy, F=dual_input(F=fast),Q=Quad_io 
reg [8:1] latchingMode = "N";

reg [8*8:1] protocol="extended";

reg [cmdDim-1:0] cmd='h0;
reg [addrDimLatch-1:0] addrLatch='h0;
reg [addrDim-1:0] addr='h0;
reg [dataDim-1:0] data='h0;
reg [dummyDim-1:0] dummy='h0;
reg [dataDim-1:0] LSdata='h0;
reg [dataDim-1:0] dataOut='h0;
reg [40*8:1] cmdRecName;

integer dummyDimEff;
//----------------------
// HOLD signal
//----------------------
//dovrebbe essere abilitato attraverso il bit 4 del VECR o anche attraverso il bit 4 del NVECR
reg NVCR_HoldResetEnable;

`ifdef HOLD_pin

    reg intHOLD=1;

//aggiunta verificare
   //latchingMode=="E"                                                                                                                                                                 
    assign HOLD = (read.enable_quad || latchingMode=="Q" || cmdRecName=="Quad Output Read" || cmdRecName=="Quad I/O Fast Read" || latchingMode=="E" || protocol=="quad" || VolatileEnhReg.VECR[4]==0 || NVCR_HoldResetEnable==0)  ? 1 : HOLD_DQ3; //serve per disabilitare la funzione di hold nel caso di quad read


    always @(HOLD) if (S==0 && C==0) 
        intHOLD = HOLD;
    
    always @(negedge C) if(S==0 && intHOLD!=HOLD) 
        intHOLD = HOLD;

    always @(posedge HOLD) if(S==1)
        intHOLD = 1;
    
    always @intHOLD if (Vcc>=Vcc_min) begin
        if(intHOLD==0)
            $display("[%0t ns] ==INFO== Hold condition enabled: communication with the device has been paused.", $time);
        else if(intHOLD==1)
            $display("[%0t ns] ==INFO== Hold condition disabled: communication with the device has been activated.", $time);  
   end
`endif


//-------------------------
// Internal signals
//-------------------------

reg busy=0;

reg [2:0] ck_count = 0; //clock counter (modulo 8) 

reg reset_by_powerOn = 1; //reset_by_powerOn is updated in "Power Up & Voltage check" section

`ifdef RESET_pin

 assign RESET = (read.enable_quad || latchingMode=="Q" || cmdRecName=="Quad Output Read" || cmdRecName=="Quad I/O Fast Read" || latchingMode=="E" || protocol=="quad" || VolatileEnhReg.VECR[4]==0 || NVCR_HoldResetEnable==0)  ? 1 : RESET_DQ3;  //|| cmdRecName=="Quad I/O Fast Read")  ? 1 : RESET_DQ3; //serve per disabilitare la funzione di reset nel caso di quad read
 
 assign int_reset = (RESET===0 || RESET===1 && protocol!="quad") ? !RESET || reset_by_powerOn : reset_by_powerOn;

`else
  assign int_reset = reset_by_powerOn;
`endif  

`ifdef HOLD_pin
  assign logicOn = !int_reset && !S && intHOLD; 
`else
  assign logicOn = !int_reset && !S;
`endif  

reg deep_power_down = 0; //updated in "Deep power down" processes





//---------------------------------------
//  Vpp_W signal : write protect feature
//---------------------------------------

assign W_int = Vpp_W_DQ2;

//----------------------------
// CUI decoders istantiation
//----------------------------

`include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/Decoders.h"




//---------------------------
// Modules istantiations
//---------------------------

Memory          mem ();

UtilFunctions   f ();

Program         prog ();

StatusRegister  stat ();

FlagStatusRegister flag ();

NonVolatileConfigurationRegister NonVolatileReg ();

VolatileEnhancedConfigurationRegister VolatileEnhReg ();

VolatileConfigurationRegister VolatileReg ();

Read            read ();

LockManager     lock ();

`ifdef timingChecks
 
 `ifdef N25Q128A230B
  TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
  `elsif N25Q128A13B
  TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
 `elsif N25Q128A11B 
  TimingCheck     timeCheck (S, C, DQ0, DQ1, W_int, HOLD_DQ3);
 `endif

`endif  
  
 `ifdef HOLD_pin

  DualQuadOps     dualQuad (S, C, ck_count, DQ0, DQ1, Vpp_W_DQ2, HOLD_DQ3); 

  `elsif RESET_pin
 
 DualQuadOps     dualQuad (S, C, ck_count, DQ0, DQ1, Vpp_W_DQ2, RESET_DQ3); 
 
 `endif


  OTP_memory      OTP (); 



reg XIP=0; //XIP mode status (XIP=0 XIP mode not selected, XIP=1 XIP mode selected)

//----------------------------------
//  Signals for latching control
//----------------------------------

integer iCmd, iAddr, iData, iDummy;

always @(negedge S) begin : CP_latchInit

    if (!XIP) latchingMode = "C";  
   // $stop;
    ck_count = 0;
    iCmd = cmdDim - 1;
    iAddr = addrDimLatch - 1;
    iData = dataDim - 1;
    iDummy = dummyDimEff - 1;
end


always @(posedge C) if(logicOn) begin 
    ck_count = ck_count + 1;
end
//-------------------------
// Latching commands
//-------------------------


event cmdLatched;


always @(posedge C) if(logicOn && latchingMode=="C" && protocol=="extended") begin : CP_latchCmd

    cmd[iCmd] = DQ0;
   // $display("get spi_cmd[%h]",iCmd);
    if (iCmd>0)
        iCmd = iCmd - 1;
    else if(iCmd==0) begin
        latchingMode = "N";
        -> cmdLatched;
    end    
        
end

always @(posedge C) if(logicOn && latchingMode=="C" && protocol=="dual") begin : CP_latchCmdDual

    cmd[iCmd] = DQ1;
    cmd[iCmd-1] = DQ0;

    if (iCmd>=3)
        iCmd = iCmd - 2;
    else if(iCmd==1) begin
        latchingMode = "N";
        -> cmdLatched;
    end    
        
end

`ifdef HOLD_pin
always @(posedge C) if(logicOn && latchingMode=="C" && protocol=="quad") begin : CP_latchCmdQuad

    cmd[iCmd] = HOLD_DQ3;
    cmd[iCmd-1] = Vpp_W_DQ2;
    cmd[iCmd-2] = DQ1;
    cmd[iCmd-3] = DQ0;

    if (iCmd>=7)
        iCmd = iCmd - 4;
    else if(iCmd==3) begin
        latchingMode = "N";
        -> cmdLatched;
    end    
        
end

`elsif RESET_pin

always @(posedge C) if(logicOn && latchingMode=="C" && protocol=="quad") begin : CP_latchCmdQuad

    cmd[iCmd] = RESET_DQ3;
    cmd[iCmd-1] = Vpp_W_DQ2;
    cmd[iCmd-2] = DQ1;
    cmd[iCmd-3] = DQ0;

    if (iCmd>=7)
        iCmd = iCmd - 4;
    else if(iCmd==3) begin
        latchingMode = "N";
        -> cmdLatched;
    end    
        
end

`endif

//-------------------------
// Latching address
//-------------------------


event addrLatched;


always @(posedge C) if (logicOn && latchingMode=="A") begin : CP_latchAddr

    addrLatch[iAddr] = DQ0;
    if (iAddr>0)
        iAddr = iAddr - 1;
    else if(iAddr==0) begin
        latchingMode = "N";
        addr = addrLatch[addrDim-1:0];
        -> addrLatched;
    end

end



always @(posedge C) if (logicOn && latchingMode=="I") begin : CP_latchAddrDual

    addrLatch[iAddr] = DQ1;
    addrLatch[iAddr-1]= DQ0;
    
    if (iAddr>=3)
        iAddr = iAddr - 2;
    else if(iAddr==1) begin
        latchingMode = "N";
        addr = addrLatch[addrDim-1:0];
        -> addrLatched;
    end

end

`ifdef HOLD_pin
always @(posedge C) if (logicOn && latchingMode=="E") begin : CP_latchAddrQuad

    addrLatch[iAddr] = HOLD_DQ3;
    addrLatch[iAddr-1]= Vpp_W_DQ2;
    addrLatch[iAddr-2]= DQ1;
    addrLatch[iAddr-3]= DQ0;
   
    if (iAddr>=7)
        iAddr = iAddr - 4;

    else if(iAddr==3) begin
        latchingMode = "N";
        addr = addrLatch[addrDim-1:0];
        -> addrLatched;
    end

end
 `elsif RESET_pin

always @(posedge C) if (logicOn && latchingMode=="E") begin : CP_latchAddrQuad

    addrLatch[iAddr] = RESET_DQ3;
    addrLatch[iAddr-1]= Vpp_W_DQ2;
    addrLatch[iAddr-2]= DQ1;
    addrLatch[iAddr-3]= DQ0;
   
    if (iAddr>=7)
        iAddr = iAddr - 4;

    else if(iAddr==3) begin
        latchingMode = "N";
        addr = addrLatch[addrDim-1:0];
        -> addrLatched;
    end

end

`endif

//-----------------
// Latching data
//-----------------

event dataLatched;

always @(posedge C) if (logicOn && latchingMode=="D") begin : CP_latchData

    data[iData] = DQ0;

    if (iData>0)
        iData = iData-1;
    else begin
     if (cmdRecName=="Write NV Configuration Reg" && prog.LSByte) begin
        LSdata=data;
         prog.LSByte=0;
     end   
        -> dataLatched;
        $display("  [%0t ns] Data latched: %h", $time, data);
        iData=dataDim-1;
    end    

end
event dummyLatched;
event dummyDimEff_changed;


always @(dummyDimEff_changed)
   iDummy=dummyDimEff-2;


//-----------------
// Latching dummy
//-----------------


integer dummyDimEff_temp;


always @(posedge C) if (logicOn && latchingMode=="Y") begin : CP_latchDummy

    dummy[iDummy] = DQ0;

         
    //if the default dummy cycle is used, then we need to use 10 dummy cycles for
    // qiofr and 8 for all other types of reads
    if ((NonVolatileReg.NVCR[15:12]=='b0000 || NonVolatileReg.NVCR[15:12]=='b1111) &&
        (VolatileReg.VCR[7:4]=='b0000 || VolatileReg.VCR[7:4]=='b1111)) begin
     dummyDimEff_temp = dummyDimEff;
     if (protocol=="quad" || cmdRecName=="Quad I/O Fast Read")
       dummyDimEff_temp = 10;
     else
       dummyDimEff_temp = 8;
     if (dummyDimEff_temp != dummyDimEff)
        -> dummyDimEff_changed;
     dummyDimEff = dummyDimEff_temp;
    end

    
    //XIP mode setting
`ifdef XIP_basic

    if(iDummy==dummyDimEff-1 &&  dummy[iDummy]==0) begin

        XIP=1;


    end else if (iDummy==dummyDimEff-1 &&  dummy[iDummy]==1) begin

        if (XIP) begin $display("  [%0t ns] XIP mode exit.", $time);
 
     
            XIP=0;

        end

    end     

 `elsif XIP_Numonyx
 
    if(iDummy==dummyDimEff-1 &&  dummy[iDummy]==0 && VolatileReg.VCR[3]==0) begin
    
        XIP=1; 
       

    end else if (iDummy==dummyDimEff-1 &&  dummy[iDummy]==1) begin
        
        if (XIP) $display("  [%0t ns] XIP mode exit.", $time);
            XIP=0;


   end
 `endif  
    

    if (iDummy>0) begin 
        iDummy = iDummy-1;
        end
        else begin
        -> dummyLatched;
        $display("  [%0t ns] Dummy clock cycles latched.", $time);


    end    

end


// check dummy clock cycles 

always @(dummyLatched) begin
    
    iDummy=dummyDimEff-1;
    ck_count=0;

    case (dummyDimEff)

        1: begin

            if(((fC>78) && (cmdRecName=="Read Fast" || cmdRecName=="Dual Output Fast Read")) ||
              ((fC>39) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read")) ||
              ((fC>44) && (cmdRecName=="Quad Output Fast Read")) ||
              ((fC>20) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns]  ==ERROR== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        
           end

        2: begin

            if(((fC>98) && (cmdRecName=="Read Fast")) ||
              ((fC>88) && (cmdRecName=="Dual Output Fast Read")) ||
              ((fC>59) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read")) ||
              ((fC>61) && (cmdRecName=="Quad Output Fast Read")) ||
              ((fC>39) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==ERROR== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
        
           end

        3: begin
             
              if(((fC>98) && (cmdRecName=="Dual Output Fast Read")) ||
                 ((fC>78) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                 ((fC>49) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
               $display("  [%0t ns] ==ERROR== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
           end

        4 : begin
             
              if(((fC>88) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                ((fC>59) && (cmdRecName=="Quad I/O Fast Read")))
                  $display("  [%0t ns] ==ERROR== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
           end

        
        5 : begin
             
              if(((fC>98) && (cmdRecName=="Dual I/O Fast Read" || cmdRecName=="Dual Command Fast Read" || cmdRecName=="Quad Output Fast Read")) ||
                ((fC>69) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read")))
                  $display("  [%0t ns] ==ERROR== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
           end
        
        6 : begin
             if  ((fC>78) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read"))
                  $display("  [%0t ns] ==ERROR== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
            end
        
        7 : begin
             if  ((fC>88) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read"))
                  $display("  [%0t ns] ==ERROR== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
            end
        8 : begin
             if  ((fC>98) && (cmdRecName=="Quad I/O Fast Read" || cmdRecName=="Quad Command Fast Read"))
                  $display("  [%0t ns] ==ERROR== Dummy clock number is not sufficient for the operating frequency. The memory reads wrong data",$time);
            end
 
            
        default : begin end
                        
    endcase
 
end

       
//------------------------------
// Commands recognition control
//------------------------------


event codeRecognized, seqRecognized, startCUIdec;







always @(cmdLatched) fork : CP_cmdRecControl

    -> startCUIdec; // i CUI decoders si devono attivare solo dopo
                    // che e' partito il presente processo
                    // NB: l'attivazione dell'evento startCUIdec fa partire i CUIdec
                    // immediatamente (nello stesso delta time in cui si attiva l'evento),
                    // e non nel delta time successivo


    begin : ok
        @(codeRecognized or seqRecognized) 
          disable error;
    end
    
    
    begin : error
        #0; 
        #0; //wait until CUI decoders execute recognition process (2 delta time maximum)
            //questo secondo ritardo si puo' anche togliere (perche' il ritardo max e' 1 delta)
        if (busy)   
            $display("[%0t ns] **WARNING** Device is busy. Command not accepted.", $time);
         else if (deep_power_down)
            $display("[%0t ns] **WARNING** Deep power down mode. Command not accepted.", $time);
    
        else if (!ReadAccessOn || !WriteAccessOn || !PollingAccessOn) 
            $display("[%0t ns] **WARNING** Power up is ongoing. Command not accepted.", $time);    
        else if (!busy)  
            $display("[%0t ns] **ERROR** Inst[%h] Command Not Recognized.", $time,cmd);
        disable ok;
    end    

join



//------------------------------------
// Power Up, Fast POR & Voltage check
//------------------------------------



//--- Reset internal logic (latching disabled when Vcc<Vcc_wi)

assign Vcc_L1 = (Vcc>=Vcc_wi) ?  1 : 0 ;

always @Vcc_L1 
  if (reset_by_powerOn && Vcc_L1)
    reset_by_powerOn = 0;
  else if (!reset_by_powerOn && !Vcc_L1) 
    reset_by_powerOn = 1;
    


assign Vcc_L2 = (Vcc>=Vcc_min) ?  1 : 0 ;

assign FastPOR_enable= (NonVolatileReg.NVCR[5]==0) ?  1 : 0 ;

event checkProtocol;

event checkHoldResetEnable;

event checkDummyClockCycle;

//----------------------------
// Power Up Fast POR Selected 
//----------------------------

//--- Read access

always @Vcc_L2 if(Vcc_L2 && FastPOR_enable && PollingAccessOn==0 && ReadAccessOn==0) fork : CP_powUp_ReadAccess
    
    begin : p1

     $display("[%0t ns] ==INFO== Power up: fast POR enabled.",$time );
    
      PollingAccessOn=1;
      
      #read_access_power_up_delay;
      $display("[%0t ns] ==INFO== Power up: read access enabled.",$time );
      ReadAccessOn=1;
      deep_power_down=0;
      // starting protocol defined by NVCR
      -> checkProtocol;
      //checking hold_enable defined by NVCR
      -> checkHoldResetEnable;
      -> checkDummyClockCycle;
      disable p2;
    end 

    begin : p2
      @Vcc_L2 if(!Vcc_L2)
        disable p1;
    end

join    



//--- Write access

reg WriteAccessCondition = 0;

always @seqRecognized if (cmdRecName=="Write Enable" && WriteAccessCondition==0 && Vcc_L2 && PollingAccessOn && ReadAccessOn && FastPOR_enable) fork : CP_powUp_WriteAccess
    
    begin : p1
        
        ReadAccessOn=0;  
        #write_access_power_up_delay;
        $display("[%0t ns] ==INFO== Power up: write access enabled (device fully accessible)", $time);
        ReadAccessOn=1;
        WriteAccessCondition=1;
        disable p2;
    
    end  

    begin : p2
      @Vcc_L1 if(!Vcc_L1)
        disable p1;
    end

join    


//----------------------------
// Power Up Fast POR Selected 
//----------------------------


always @Vcc_L2 if(Vcc_L2 && !FastPOR_enable && PollingAccessOn==0 && ReadAccessOn==0 && WriteAccessCondition==0) fork : CP_powUp_FullAccess
    
    begin : p1
      $display("[%0t ns] ==INFO== Power up: fast POR disabled.",$time );
      PollingAccessOn=1;
      
      #full_access_power_up_delay;
      $display("[%0t ns] ==INFO== Power up: device fully accessible.",$time );
      ReadAccessOn=1;
      WriteAccessCondition=1;
      // starting protocol defined by NVCR
      -> checkProtocol; 
      //checking hold_enable defined by NVCR
      -> checkHoldResetEnable;
      -> checkDummyClockCycle;
            disable p2;
    end 

    begin : p2
      @Vcc_L2 if(!Vcc_L2)
        disable p1;
    end

join    

always @(checkDummyClockCycle) begin
    if(NonVolatileReg.NVCR[15:12]=='b0000) dummyDimEff=15;
    else  dummyDimEff=NonVolatileReg.NVCR[15:12];

end

always @(checkHoldResetEnable) begin
 if (NonVolatileReg.NVCR[4]==1) NVCR_HoldResetEnable=1;
 else NVCR_HoldResetEnable=0;
end


assign WriteAccessOn =PollingAccessOn && ReadAccessOn && WriteAccessCondition;


always @(checkProtocol) begin
if (NonVolatileReg.NVCR[3]==0) protocol="quad";
      else if (NonVolatileReg.NVCR[2]==0) protocol="dual";
      else if(NonVolatileReg.NVCR[3]==1 && NonVolatileReg.NVCR[2]==1) protocol="extended";
      $display("[%0t ns] ==INFO== Protocol selected is %0s",$time, protocol);
      

       case (NonVolatileReg.NVCR[11:9])
       'b000 : begin
                XIP=1;
                protocol="extended";
                cmdRecName="Read Fast";
               end
        
       'b001 : begin 
                 XIP=1;
                 cmdRecName="Dual Output Fast Read"; 
                 protocol="extended";
               end
       'b010 : begin
                 XIP=1;
                 cmdRecName="Dual I/O Fast Read";
                 protocol="dual";
               end
 
       'b011 : begin
                 XIP=1;
                 cmdRecName="Quad Output Read"; 
                 protocol="extended";
               end

       'b100 :  begin
                 XIP=1;
                 cmdRecName="Quad I/O Fast Read"; 
                 protocol="quad";
               end

       'b111: XIP=0;
         default : XIP=0;
       endcase  

end

//---Dummy clock cycle

always @VolatileReg.VCR begin
    if (VolatileReg.VCR[7:4]=='b0000) dummyDimEff=15;
    else dummyDimEff=VolatileReg.VCR[7:4];

end

//--- Voltage drop (power down)

always @Vcc_L1 if (!Vcc_L1 && (PollingAccessOn|| ReadAccessOn || WriteAccessCondition)) begin : CP_powerDown
    $display("[%0t ns] ==INFO== Voltage below the threshold value: device not accessible.", $time);
    ReadAccessOn=0;
    WriteAccessCondition=0;
    PollingAccessOn=0;
    prog.Suspended=0; //the suspended state is reset  
    
end    




//--- Voltage fault (used during program and erase operations)

event voltageFault; //used in Program and erase dynamic check (see also "CP_voltageCheck" process)

assign VccOk = (Vcc>=Vcc_min && Vcc<=Vcc_max) ?  1 : 0 ;

always @VccOk if (!VccOk) ->voltageFault; //check is active when device is not reset
                                          //(this is a dynamic check used during program and erase operations)
        






//---------------------------------
// Vpp (auxiliary voltage) checks
//---------------------------------

//VPP pin Enhanced Supply Voltage feature not implemented



                   

//-----------------
// Read execution
//-----------------


reg [addrDim-1:0] readAddr;
reg bitOut='hZ;

event sendToBus;


// values assumed by DQ0 and DQ1, when they are not forced
assign DQ0 = 1'bZ;
assign DQ1 = 1'bZ;


//  DQ1 : release of values assigned with "force statement"
always @(posedge S) #tSHQZ release DQ1;


// effect on DQ1 by HOLD signal
`ifdef HOLD_pin
    
    reg temp;
    
    always @(intHOLD) if(intHOLD===0) begin : CP_HOLD_out_effect 
        
        begin : out_effect
            temp = DQ1;
            #tHLQZ;
            disable guardian;
            release DQ1;
            @(posedge intHOLD) #tHHQX force DQ1=temp;
        end  

        begin : guardian 
            @(posedge intHOLD)
            disable out_effect;
        end
        
    end   

`endif    



reg firstNVCR = 1;
// read with DQ1 out bit

always @(negedge(C)) if(logicOn && protocol=="extended") begin : CP_read

    if(read.enable==1 || read.enable_fast==1) begin    
        
        if(ck_count==0) begin
            readAddr = mem.memAddr;
            mem.readData(dataOut); //read data and increments address
            f.out_info(readAddr, dataOut);
        end
        
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

    end else if (stat.enable_SR_read==1) begin
        
        if(ck_count==0) begin
            dataOut = stat.SR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

     end else if (flag.enable_FSR_read==1) begin
        
        if(ck_count==0) begin
            dataOut = flag.FSR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

     end else if (VolatileReg.enable_VCR_read==1) begin
        
        if(ck_count==0) begin
            dataOut = VolatileReg.VCR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

     end else if (flag.enable_FSR_read==1) begin
        
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

     end else if (flag.enable_FSR_read==1) begin
        
        if(ck_count==0) begin
            dataOut = flag.FSR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

     end else if (VolatileReg.enable_VCR_read==1) begin
        
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;
    
      end else if (VolatileEnhReg.enable_VECR_read==1) begin
        
        if(ck_count==0) begin
            dataOut = VolatileEnhReg.VECR;
            f.out_info(readAddr, dataOut);
        end    
       
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;
    

     end else if (NonVolatileReg.enable_NVCR_read==1) begin
        
        if(ck_count==0 && firstNVCR == 1) begin
            dataOut = NonVolatileReg.NVCR[7:0];
            f.out_info(readAddr, dataOut);
            firstNVCR=0;
          
        end else if(ck_count==0 && firstNVCR == 0) begin
           dataOut = NonVolatileReg.NVCR[15:8];
           f.out_info(readAddr, dataOut);
           firstNVCR=1;
                                   
        end

        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

   

      
      end else if (lock.enable_lockReg_read==1) begin

          if(ck_count==0) begin 
              readAddr = f.sec(addr);
              f.out_info(readAddr, dataOut);
          end
          // dataOut is set in LockManager module
          
          #tCLQX
          bitOut = dataOut[dataDim-1-ck_count];
          -> sendToBus;
    

    
      end else if (read.enable_OTP==1) begin 

          if(ck_count==0) begin
              readAddr = 'h0;
              readAddr = OTP.addr;
              OTP.readData(dataOut); //read data and increments address
              f.out_info(readAddr, dataOut);
          end
          
          #tCLQX
          bitOut = dataOut[dataDim-1-ck_count];
          -> sendToBus;

   
   
    end else if (read.enable_ID==1) begin 

        if(ck_count==0) begin
        
            readAddr = 'h0;
            readAddr = read.ID_index;
            
            if (read.ID_index==0)      dataOut=Manufacturer_ID;
            else if (read.ID_index==1) dataOut=MemoryType_ID;
            else if (read.ID_index==2) dataOut=MemoryCapacity_ID;
            else if (read.ID_index==3) dataOut=UID;
            else if (read.ID_index==4) dataOut=EDID_0;
            else if (read.ID_index==5) dataOut=EDID_1;
            else if (read.ID_index==6) dataOut=CFD_0;
            else if (read.ID_index==7) dataOut=CFD_1;
            else if (read.ID_index==8) dataOut=CFD_2;
            else if (read.ID_index==9) dataOut=CFD_3;
            else if (read.ID_index==10) dataOut=CFD_4;
            else if (read.ID_index==11) dataOut=CFD_5;
            else if (read.ID_index==12) dataOut=CFD_6;
            else if (read.ID_index==13) dataOut=CFD_7;
            else if (read.ID_index==14) dataOut=CFD_8;
            else if (read.ID_index==15) dataOut=CFD_9;
            else if (read.ID_index==16) dataOut=CFD_10;
            else if (read.ID_index==17) dataOut=CFD_11;
            else if (read.ID_index==18) dataOut=CFD_12;
            else if (read.ID_index==19) dataOut=CFD_13;
            
            if (read.ID_index<=18) read.ID_index=read.ID_index+1;
            else read.ID_index=0;


            f.out_info(readAddr, dataOut);
        
        end
        
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

    end

    
   
end





always @sendToBus fork : CP_sendToBus


    force DQ1 = 1'bX;
    
    #(tCLQV - tCLQX) 
        force DQ1 = bitOut;

join



//-----------------------
//  Reset Signal
//-----------------------
//dovrebbe essere abilitato attraverso il bit 4 del VECR


event resetEvent; //Activated only in devices with RESET pin.

reg resetDuringDecoding=0; //These two boolean variables are used in TimingCheck 
reg resetDuringBusy=0;     //entity to check tRHSL timing constraint

`ifdef RESET_pin   

    always @RESET if (!RESET) begin : CP_reset

        ->resetEvent;
        
        if(S===0 && !busy) 
            resetDuringDecoding=1; 
        else if (busy)
            resetDuringBusy=1; 
        
        release DQ1;
        ck_count = 0;
        latchingMode = "N";
        cmd='h0;
        addrLatch='h0;
        addr='h0;
        data='h0;
        dataOut='h0;

        iCmd = cmdDim - 1;
        iAddr = addrDimLatch - 1;
        iData = dataDim - 1;
        iDummy = dummyDimEff - 1;

        // commands waiting to be executed are disabled internally
        
        // read enabler are resetted internally, in the read processes
        
        // CUIdecoders are internally disabled by reset signal
        
        #0 $display("[%0t ns] ==INFO== Reset Signal has been driven low : internal logic will be reset.", $time);

    end

`endif    


//-----------------------
//  Deep power down 
//-----------------------


`ifdef PowDown


    always @seqRecognized if (cmdRecName=="Deep Power Down") fork : CP_deepPowerDown

        begin : exe
          @(posedge S);
          disable reset;
          busy=1;
          $display("  [%0t ns] Device is entering in deep power down mode...",$time);
          #deep_power_down_delay;
          $display("  [%0t ns] ...power down mode activated.",$time);
          busy=0;
          deep_power_down=1;
        end

        begin : reset
          @resetEvent;
          disable exe;
        end

    join


    always @seqRecognized if (cmdRecName=="Release Deep Power Down") fork : CP_releaseDeepPowerDown

        begin : exe
          @(posedge S);
          disable reset;
          busy=1;
          $display("  [%0t ns] Release from deep power down is ongoing...",$time);
          #release_power_down_delay;
          $display("  [%0t ns] ...release from power down mode completed.",$time);
          busy=0;
          deep_power_down=0;
        end 

        begin : reset
          @resetEvent;
          disable exe;
        end

    join


`endif







//-----------------
//   XIP mode
//-----------------


//-----------------
// Latching address 
//-----------------


always @(negedge S) if (XIP) begin : XIP_latchInit

    $display("[%0t ns] The device is entered in XIP mode.", $time);

    if (protocol=="extended") begin
       
       if (cmdRecName=="Dual I/O Fast Read") begin
            latchingMode = "I";
       end else if (cmdRecName=="Quad I/O Fast Read") begin
            latchingMode = "E";
       end else latchingMode = "A";
       
       $display("[%0t ns] %0s. Address expected ...", $time,cmdRecName);
            
            fork : XipProc1 

                @(addrLatched) begin
                    
                    $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 addr, f.col(addr), f.pag(addr), f.sec(addr));
                    -> seqRecognized;
                    disable XipProc1;
                end

                @(posedge S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable XipProc1;
                end

                @(resetEvent or voltageFault) begin
                    disable XipProc1;
                end
            
            join

    end else  if (protocol=="dual") begin

       latchingMode = "I";
       $display("[%0t ns] %0s. Address expected ...", $time,cmdRecName);
        
              fork : XipProc2 

                @(addrLatched) begin
                     $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 addr, f.col(addr), f.pag(addr), f.sec(addr));
                     -> seqRecognized;
                     disable XipProc2;
                end

                @(posedge S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable XipProc2;
                end

                @(resetEvent or voltageFault) begin
                    disable XipProc2;
                end
            
            join

    end else  if (protocol=="quad") begin

       latchingMode = "E";
       $display("[%0t ns]  %0s. Address expected ...", $time,cmdRecName);
        
              fork : XipProc3 

                @(addrLatched) begin
                     $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 addr, f.col(addr), f.pag(addr), f.sec(addr));
                    -> seqRecognized;
                    disable XipProc3;
                end

                @(posedge S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable XipProc3;
                end

                @(resetEvent or voltageFault) begin
                    disable XipProc3;
                end
            
            join
    
    end
 
end 



endmodule















/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           CUI DECODER                                 --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns 

module CUIdecoder (cmdAllowed);


    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h" 

    input cmdAllowed;

    parameter [40*8:1] cmdName = "Write Enable";
    parameter [cmdDim-1:0] cmdCode = 'h06;
    parameter withAddr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with2Addr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with4Addr = 1'b0; // 1 -> command with address  /  0 -> without address 
     


    always @N25Qxxx.startCUIdec if (cmdAllowed && cmdCode==N25Qxxx.cmd) begin

        if(!withAddr && !with2Addr && !with4Addr) begin
            N25Qxxx.cmdRecName = cmdName;
            $display("[%0t ns] COMMAND RECOGNIZED: %0s,cmdCode : %h.", $time, cmdName,cmdCode);
            -> N25Qxxx.seqRecognized; 
        
        end else if (withAddr) begin
            
            N25Qxxx.latchingMode = "A";
            $display("[%0t ns] COMMAND RECOGNIZED: %0s.cmdCode:%h Address expected ...", $time, cmdName,cmdCode);
            -> N25Qxxx.codeRecognized;
            
            fork : proc1 

                @(N25Qxxx.addrLatched) begin
                    if (cmdName!="Read OTP" && cmdName!="Program OTP")
                        $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 N25Qxxx.addr, f.col(N25Qxxx.addr), f.pag(N25Qxxx.addr), f.sec(N25Qxxx.addr));
                    else
                        $display("  [%0t ns] Address latched: column %0d", $time, N25Qxxx.addr);
                    N25Qxxx.cmdRecName = cmdName;
                    -> N25Qxxx.seqRecognized;
                    disable proc1;
                end

                @(posedge N25Qxxx.S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable proc1;
                end

                @(N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
                    disable proc1;
                end
            
            join


         end else if (with2Addr) begin
            
            N25Qxxx.latchingMode = "I";
            $display("[%0t ns] COMMAND RECOGNIZED: %0s. Address expected ...", $time, cmdName);
            -> N25Qxxx.codeRecognized;
            
            fork : proc2 

                @(N25Qxxx.addrLatched) begin
                    if (cmdName!="Read OTP" && cmdName!="Program OTP")
                        $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 N25Qxxx.addr, f.col(N25Qxxx.addr), f.pag(N25Qxxx.addr), f.sec(N25Qxxx.addr));
                    else
                    $display("  [%0t ns] Address latched: column %0d", $time, N25Qxxx.addr);
                    N25Qxxx.cmdRecName = cmdName;
                    -> N25Qxxx.seqRecognized;
                    disable proc2;
                end

                @(posedge N25Qxxx.S) begin
                    $display("  - [%0t ns] S high: command aborted", $time);
                    disable proc2;
                end

                @(N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
                    disable proc2;
                end
            
            join


        end  else if (with4Addr) begin
                    
                                N25Qxxx.latchingMode = "E";
                                $display("[%0t ns] COMMAND RECOGNIZED: %0s. Address expected ...", $time, cmdName);
                                -> N25Qxxx.codeRecognized;
                                            
                                fork : proc3 
                                   
                                   @(N25Qxxx.addrLatched) begin
                                    if (cmdName!="Read OTP" && cmdName!="Program OTP")
                        $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d)", $time, 
                                 N25Qxxx.addr, f.col(N25Qxxx.addr), f.pag(N25Qxxx.addr), f.sec(N25Qxxx.addr));
                    else
                                       $display("  [%0t ns] Address latched: column %0d", $time, N25Qxxx.addr);
                                       N25Qxxx.cmdRecName = cmdName;
                                       -> N25Qxxx.seqRecognized;
                                       disable proc3;
                                   end

                                   @(posedge N25Qxxx.S) begin
                                       $display("  - [%0t ns] S high: command aborted", $time);
                                       disable proc3;
                                   end

                                   @(N25Qxxx.resetEvent or N25Qxxx.voltageFault) begin
                                       disable proc3;
                                   end
                                                                                                                                                                                                                                                                                                                                        
                                join

      end    

                                                                                                                                                                                                                                                                                                                                                            
    end



    


endmodule    













/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           MEMORY MODULE                               --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns

module Memory;

    

    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"



    //-----------------------------
    // data structures definition
    //-----------------------------

    reg [dataDim-1:0] memory [0:memDim-1];
    reg [dataDim-1:0] page [0:pageDim];




    //------------------------------
    // Memory management variables
    //------------------------------

    reg [addrDim-1:0] memAddr;
    reg [addrDim-1:0] pageStartAddr;
    reg [colAddrDim-1:0] pageIndex = 'h0;
    reg [colAddrDim-1:0] zeroIndex = 'h0;

    integer i;




    //-----------
    //  Init
    //-----------

    initial begin 

        for (i=0; i<=memDim-1; i=i+1) 
            memory[i] = data_NP;
        
        if ( N25Qxxx.memory_file!="" && N25Qxxx.memory_file!=" ") begin
            $readmemh(N25Qxxx.memory_file, memory);
            $display("[%0t ns] ==INFO== Load memory content from file: \"%0s\".", $time, N25Qxxx.memory_file);
        end    
    
    end



    always @(N25Qxxx.Vcc_L2) if((N25Qxxx.Vcc_L2) && ( N25Qxxx.memory_file!="" && N25Qxxx.memory_file!=" ")) begin
         
         $readmemh(N25Qxxx.memory_file, memory);
         $display("[%0t ns] ==INFO== Load memory content from file: \"%0s\".", $time, N25Qxxx.memory_file);
                     

   end      


    //-----------------------------------------
    //  Task used in program & read operations  
    //-----------------------------------------
    

    
    // set start address & page index
    // (for program and read operations)
    
    task setAddr;

    input [addrDim-1:0] addr;

    begin

        memAddr = addr;
        pageStartAddr = {addr[addrDim-1:pageAddr_inf], zeroIndex};
        pageIndex = addr[colAddrDim-1:0];
    
    end
    
    endtask



    
    // reset page with FF data

    task resetPage;

    for (i=0; i<=pageDim-1; i=i+1) 
        page[i] = data_NP;

    endtask    


    

    // in program operations data latched 
    // are written in page buffer

    task writeDataToPage;

    input [dataDim-1:0] data;

    begin

        page[pageIndex] = data;
        pageIndex = pageIndex + 1; 

    end

    endtask



    // page buffer is written to the memory

    task programPageToMemory; //logic and between old_data and new_data

    for (i=0; i<=pageDim-1; i=i+1)
        memory[pageStartAddr+i] = memory[pageStartAddr+i] & page[i];
    endtask





    // in read operations data are readed directly from the memory

    task readData;

    output [dataDim-1:0] data;

    begin

        data = memory[memAddr];
        if (memAddr < memDim-1)
            memAddr = memAddr + 1;
        else begin
            memAddr=0;
            $display("  [%0t ns] **WARNING** Highest address reached. Next read will be at the beginning of the memory!", $time);
        end    

    end

    endtask




    //---------------------------------------
    //  Tasks used for Page Write operation
    //---------------------------------------


    // page is written into the memory (old_data are over_written)
    
    task writePageToMemory; 

    for (i=0; i<=pageDim-1; i=i+1)
        memory[pageStartAddr+i] = page[i];
        // before page program the page should be reset
    endtask


    // pageMemory is loaded into the pageBuffer
    
    task loadPageBuffer; 

    for (i=0; i<=pageDim-1; i=i+1)
        page[i] = memory[pageStartAddr+i];
        // before page program the page should be reset
    endtask





    //-----------------------------
    //  Tasks for erase operations
    //-----------------------------

    task eraseSector;
    input [addrDim-1:0] A;
    reg [sectorAddrDim-1:0] sect;
    reg [sectorAddr_inf-1:0] zeros;
    reg [addrDim-1:0] mAddr;
    begin
    
        sect = f.sec(A);
        zeros = 'h0;
        mAddr = {sect, zeros};
        for(i=mAddr; i<=(mAddr+sectorSize-1); i=i+1)
            memory[i] = data_NP;
    
    end
    endtask



    `ifdef SubSect 
    
     task eraseSubsector;
     input [addrDim-1:0] A;
     reg [subsecAddrDim-1:0] subsect;
     reg [subsecAddr_inf-1:0] zeros;
     reg [addrDim-1:0] mAddr;
     begin
    
         subsect = f.sub(A);
         zeros = 'h0;
         mAddr = {subsect, zeros};
         for(i=mAddr; i<=(mAddr+subsecSize-1); i=i+1)
             memory[i] = data_NP;
    
     end
     endtask

    `endif



    task eraseBulk;

        for (i=0; i<=memDim-1; i=i+1) 
            memory[i] = data_NP;
    
    endtask



    task erasePage;
    input [addrDim-1:0] A;
    reg [pageAddrDim-1:0] page;
    reg [pageAddr_inf-1:0] zeros;
    reg [addrDim-1:0] mAddr;
    begin
    
        page = f.pag(A);
        zeros = 'h0;
        mAddr = {page, zeros}; 
        for(i=mAddr; i<=(mAddr+pageDim-1); i=i+1)
            memory[i] = data_NP;
    
    end
    endtask






    

endmodule













/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           UTILITY FUNCTIONS                           --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns 

module UtilFunctions;

    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"

    integer i;

    
    //----------------------------------
    // Utility functions for addresses 
    //----------------------------------


    function [sectorAddrDim-1:0] sec;
    input [addrDim-1:0] A;
        sec = A[sectorAddr_sup:sectorAddr_inf];
    endfunction   

    `ifdef SubSect
      function [subsecAddrDim-1:0] sub;
      input [addrDim-1:0] A;
      `ifdef bottom
          if (sec(A)<=bootSec_num-1)
          sub = A[subsecAddr_sup:subsecAddr_inf];
      `endif    
      endfunction
    `endif

    function [pageAddrDim-1:0] pag;
    input [addrDim-1:0] A;
        pag = A[pageAddr_sup:pageAddr_inf];
    endfunction

    function [pageAddrDim-1:0] col;
    input [addrDim-1:0] A;
        col = A[colAddr_sup:0];
    endfunction
    
    
    
    
    
    //----------------------------------
    // Console messages 
    //----------------------------------

    task clock_error;

        $display("  [%0t ns] **WARNING** Number of clock pulse isn't multiple of eight: operation aborted!", $time);

    endtask



    task WEL_error;

        $display("  [%0t ns] **WARNING** WEL bit not set: operation aborted!", $time);

    endtask



    task out_info;
    
        input [addrDim-1:0] A;
        input [dataDim-1:0] D;


          if (stat.enable_SR_read)          
         $display("  [%0t ns] Data are going to be output: %b. [Read Status Register]",
                  $time, D);
         else if (NonVolatileReg.enable_NVCR_read==1)
         $display("  [%0t ns] Data are going to be output: %b. [Read Non Volatile Register]",
                  $time, D);
         else if (VolatileReg.enable_VCR_read==1)
         $display("  [%0t ns] Data are going to be output: %b. [Read Volatile Register]",
                  $time, D);
         else if (VolatileEnhReg.enable_VECR_read==1)
         $display("  [%0t ns] Data are going to be output: %b. [Read Enhanced Volatile Register]",
                  $time, D);

         else if (flag.enable_FSR_read)
         $display("  [%0t ns] Data are going to be output: %b. [Read Flag Status Register]",
                  $time, D);

          else if (lock.enable_lockReg_read)
          $display("  [%0t ns] Data are going to be output: %h. [Read Lock Register of sector %0d]",
                    $time, D, A);


          else if (read.enable_ID)
            $display("  [%0t ns] Data are going to be output: %h. [Read ID, byte %0d]", $time, D, A);
        
          else if (read.enable_OTP) begin
              if (A!=OTP_dim-1)
                  $display("  [%0t ns] Data are going to be output: %h. [Read OTP memory, column %0d]", $time, D, A);
              else  
                  $display("  [%0t ns] Data are going to be output: %b. [Read OTP memory, column %0d (control byte)]", $time, D, A);
          end






        `ifdef bottom
        else        
        if (sec(A)<=bootSec_num-1) begin
          
          if (read.enable || read.enable_fast)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, subsector %0d of sector %0d)] ",
                  $time, D, A, col(A), pag(A), sub(A), sec(A)); 
        
          else if (read.enable_dual)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, subsector %0d  sector %0d)] ",
                    $time, D, A, col(A), pag(A), sub(A), sec(A));

          else if (read.enable_quad)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, subsector %0d sector %0d)] ",
                    $time, D, A, col(A), pag(A),  sub(A),sec(A));
        end
        
        
        else if (read.enable || read.enable_fast)
        $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, sector %0d)] ",
                  $time, D, A, col(A), pag(A), sec(A)); 
        
        else if (read.enable_dual)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d,sector %0d)] ",
                    $time, D, A, col(A), pag(A), sec(A));
                  
        else if (read.enable_quad)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, sector %0d)] ",
                    $time, D, A, col(A), pag(A), sec(A));
                  
        `endif 
        


















    endtask





    //----------------------------------------------------
    // Special tasks used for testing and debug the model
    //----------------------------------------------------
    

    //
    // erase the whole memory, and resets pageBuffer and cacheBuffer
    //
    
    task fullErase;
    begin
    
        for (i=0; i<=memDim-1; i=i+1) 
            mem.memory[i] = data_NP; 
        
        $display("[%0t ns] ==INFO== The whole memory has been erased.", $time);

    end
    endtask




    //
    // unlock all sectors of the memory
    //
    
    task unlockAll;
    begin

        for (i=0; i<=nSector-1; i=i+1) begin
            `ifdef LockReg
              lock.LockReg_WL[i] = 0;
              lock.LockReg_LD[i] = 0;
            `endif
            lock.lock_by_SR[i] = 0;
        end

        $display("[%0t ns] ==INFO== The whole memory has been unlocked.", $time);

    end
    endtask




    //
    // load memory file
    //

    task load_memory_file;

    input [40*8:1] memory_file;

    begin
    
        for (i=0; i<=memDim-1; i=i+1) 
            mem.memory[i] = data_NP;
        
        $readmemh(memory_file, mem.memory);
        $display("[%0t ns] ==INFO== Load memory content from file: \"%0s\".", $time, N25Qxxx.memory_file);
    
    end
    endtask





endmodule












/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           PROGRAM MODULE                              --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns

module Program;

    

    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"

    

    
    event errorCheck, error, noError;
    
    reg [40*8:1] operation; //get the value of the command currently decoded by CUI decoders
    reg [40*8:1] oldOperation; // tiene traccia di quale operazione e' stata sospesa
    reg [40*8:1] holdOperation;// tiene traccia nel caso di suspend innestati della prima operazione sospesa

    time delay,delay_resume,startTime;                 
                                 
//variabili aggiunte per gestire il prog/erase suspend
    reg [pageAddrDim-1:0] page_susp; //pagina sospesa
 

    reg [sectorAddrDim-1:0] sec_susp;
    reg [subsecAddrDim-1:0] subsec_susp;
    reg Suspended = 0; //variabile che indica se un'operazione di suspend e' attiva
    reg doubleSuspend = 0; //variabile che indica se ci sono due suspend innestati
    reg prog_susp = 0;//indica che l'operazione sospesa e' un program
    reg sec_erase_susp =0; //indica che l'operazione sospesa e' un sector erase
    reg subsec_erase_susp =0; //indica che l'operazione sospesa e' un subsector erase



    //--------------------------------------------
    //  Page Program  Dual Program & Quad Program
    //--------------------------------------------


    reg writePage_en=0;
    reg [addrDim-1:0] destAddr;



    always @N25Qxxx.seqRecognized 
    if(N25Qxxx.cmdRecName==="Page Program" || N25Qxxx.cmdRecName==="Dual Program" || N25Qxxx.cmdRecName==="Quad Program" ||
       N25Qxxx.cmdRecName==="Dual Extended Program" ||  N25Qxxx.cmdRecName==="Quad Extended Program" || 
       N25Qxxx.cmdRecName==="Dual Command Page Program" || N25Qxxx.cmdRecName==="Quad Command Page Program" )

       if(flag.FSR[4]) begin
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction. Program Status bit is high!",$time); 
                disable program_ops;
       end else if(operation=="Program Erase Suspend" && prog_susp) begin
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction after a program suspend",$time); 
                disable program_ops;
                
       `ifdef Subsect    
       end else if(operation=="Program Erase Suspend" && subsec_erase_susp) begin
           
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction after a subsector erase suspend",$time); 
                disable program_ops;
       `endif
       end else if(operation=="Program Erase Suspend" && sec_erase_susp && sec_susp==f.sec(N25Qxxx.addr)) begin
           
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction in the sector whose erase cycle is suspend",$time); 
                disable program_ops;

       end else

       
    fork : program_ops

           begin

            operation = N25Qxxx.cmdRecName;
            mem.resetPage;
            destAddr = N25Qxxx.addr;
            mem.setAddr(destAddr);
            
            if(operation=="Page Program")
                N25Qxxx.latchingMode="D";
            else if(operation=="Dual Program" || operation=="Dual Extended Program" || operation=="Dual Command Page Program") begin
                N25Qxxx.latchingMode="F";
                release N25Qxxx.DQ1;
            end else if(operation=="Quad Program" || operation=="Quad Extended Program" || operation=="Quad Command Page Program") begin
                N25Qxxx.latchingMode="Q";
                release N25Qxxx.DQ1;
                release N25Qxxx.Vpp_W_DQ2;
                `ifdef HOLD_pin
                release N25Qxxx.HOLD_DQ3;
                `else
                release N25Qxxx.RESET_DQ3;
                `endif
            end
  
            
            writePage_en = 1;

          end   
        
                                                                                                                                                                             

        begin : exe
            
           @(posedge N25Qxxx.S);
            
            disable reset;
            writePage_en=0;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: %0s.", $time, operation);
            
                delay=program_delay;

                -> errorCheck;

                @(noError) begin

                   mem.programPageToMemory;
                    $display("  [%0t ns] Command execution completed: %0s.", $time, operation);
                end
           
        end 


        begin : reset
        
          @N25Qxxx.resetEvent;
            writePage_en=0;
            operation = "None";
            disable exe;    
        
        end

    join





    always @N25Qxxx.dataLatched if(writePage_en) begin

        mem.writeDataToPage(N25Qxxx.data);
    
    end








    //------------------------
    //  Write Status register
    //------------------------


    reg [dataDim-1:0] SR_data;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write SR") begin : write_SR_ops

       //prova
       if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";
        
        @(posedge N25Qxxx.S) begin
            operation=N25Qxxx.cmdRecName;
            SR_data=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            //aggiunta verificare
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write SR.",$time);
            delay=write_SR_delay;
            -> errorCheck;

            @(noError) begin
                
                `SRWD = SR_data[7];  
                `BP3  = SR_data[6];  
                `TB   = SR_data[5]; 
                `BP2  = SR_data[4]; 
                `BP1  = SR_data[3]; 
                `BP0  = SR_data[2]; 
 
               #0 $display("  [%0t ns] Command execution completed: Write SR. SR=%h, (SRWD,BP3,TB,BP2,BP1,BP0)=%b",
                           $time, stat.SR, {`SRWD,`BP3,`TB,`BP2,`BP1,`BP0} );
            
            end
                
        end
    
    end

    //----------------------------------------
    //  Write Volatile Configuration register
    //----------------------------------------


    reg [dataDim-1:0] VCR_data;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Volatile Configuration Reg") begin : write_VCR_ops

         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";
        
        @(posedge N25Qxxx.S) begin
            operation=N25Qxxx.cmdRecName;
            VCR_data=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write Volatile Configuration Reg",$time);
            delay=write_VCR_delay;
            -> errorCheck;

            @(noError) begin
                
                VolatileReg.VCR=VCR_data;
                $display("  [%0t ns] Command execution completed: Write Volatile Configuration Reg. VCR=%h", 
                           $time, VolatileReg.VCR);
            
            end
                
        end
    
    end



    //--------------------------------------------------
    //  Write Volatile Enhanced Configuration register
    //--------------------------------------------------


    reg [dataDim-1:0] VECR_data;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write VE Configuration Reg") begin : write_VECR_ops

         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";
        
        @(posedge N25Qxxx.S) begin
            operation=N25Qxxx.cmdRecName;
            VECR_data=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write Volatile Enhanced Configuration Reg",$time);
            delay=write_VECR_delay;
            -> errorCheck;

            @(noError) begin
                
                VolatileEnhReg.VECR=VECR_data;
                $display("  [%0t ns] Command execution completed: Write Volatile Enhanced Configuration Reg. VECR=%h", 
                           $time, VolatileEnhReg.VECR);
            
            end
                
        end
    
    end

    //---------------------------------------------
    //  Write Non Volatile Configuration register
    //--------------------------------------------


    reg [dataDim-1:0] NVCR_LSByte;
    
    reg [dataDim-1:0] NVCR_MSByte;

    reg LSByte;


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write NV Configuration Reg") begin : write_NVCR_ops

         if (N25Qxxx.protocol=="dual") N25Qxxx.latchingMode="F";
       else if (N25Qxxx.protocol=="quad") N25Qxxx.latchingMode="Q";
       else
              N25Qxxx.latchingMode="D";
        LSByte=1;
        
        @(posedge N25Qxxx.S) begin
            operation=N25Qxxx.cmdRecName;
            NVCR_LSByte=N25Qxxx.LSdata;
            NVCR_MSByte=N25Qxxx.data;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write Non Volatile Configuration Register.",$time);
            delay=write_NVCR_delay;
            -> errorCheck;

            @(noError) begin
                
                NonVolatileReg.NVCR={NVCR_MSByte,NVCR_LSByte}; 
                
                $display("  [%0t ns] Command execution completed: Write Non Volatile Configuration Register. NVCR=%h (%b)",
                           $time, NonVolatileReg.NVCR,NonVolatileReg.NVCR);
            
            end
                
        end
    
    end



    //--------------
    // Erase
    //--------------

    always @N25Qxxx.seqRecognized 
    
    if (N25Qxxx.cmdRecName==="Sector Erase" || N25Qxxx.cmdRecName==="Subsector Erase" ||
        N25Qxxx.cmdRecName==="Bulk Erase") 
    
        if(flag.FSR[5]) begin
                $display(" [%0t ns] **WARNING** It's not allowed to perform an erase instruction. Erase Status bit is high!",$time); 
                disable erase_ops;
                
        end else if(operation=="Program Erase Suspend" && prog_susp) begin
           
                 $display(" [%0t ns] **WARNING** It's not allowed to perform an erase instruction after a program suspend",$time); 
                 disable erase_ops;

        end else  if(operation=="Program Erase Suspend" && sec_erase_susp) begin
        
                 $display(" [%0t ns] **WARNING** It's not allowed to perform an erase instruction after a sector erase suspend",$time); 
                 disable erase_ops;
        `ifdef Subsect
        end else  if(operation=="Program Erase Suspend" && subsec_erase_susp) begin
                 
                 $display(" [%0t ns] **WARNING** It's not allowed to perform an erase instruction after a subsector erase suspend",$time); 
                 disable erase_ops;
        `endif      
        end else      
        fork : erase_ops

        begin : exe
        
           @(posedge N25Qxxx.S);

            disable reset;
             

            operation = N25Qxxx.cmdRecName;
            destAddr = N25Qxxx.addr;
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy = 1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: %0s.", $time, operation);
            if (operation=="Sector Erase") delay=erase_delay;
            else if (operation=="Bulk Erase") delay=erase_bulk_delay;
            `ifdef SubSect
              else if (operation=="Subsector Erase")  delay=erase_ss_delay; 
            `endif  
            
            -> errorCheck;

            @(noError) begin
                if (operation=="Sector Erase")          mem.eraseSector(destAddr);
                else if (operation=="Bulk Erase")       mem.eraseBulk;
                `ifdef SubSect
                  else if (operation=="Subsector Erase")  mem.eraseSubsector(destAddr); 
                `endif
                $display("  [%0t ns] Command execution completed: %0s.", $time, operation);
             end
        end


        begin : reset
        
          @N25Qxxx.resetEvent;
            operation = "None";
            disable exe;    
        
        end

            
    join


//------------------------
// Program Erase Suspend
//-------------------------


 always @N25Qxxx.seqRecognized 
    
    if (N25Qxxx.cmdRecName==="Program Erase Suspend") begin
    
        if (operation=="Bulk Erase" || operation=="Program OTP") $display("[%0t ns] %0s can't be suspended", $time, operation);

        else fork : progerasesusp_ops

        
        begin : exe
        
           @(posedge N25Qxxx.S);

            disable reset;
            if (Suspended) begin 
                holdOperation=oldOperation;
                doubleSuspend=1;
            end     
            oldOperation = operation; //operazione sospesa
            operation = N25Qxxx.cmdRecName;
            N25Qxxx.latchingMode="N";
            //#latency_tyme (non definito ancora)
            N25Qxxx.busy = 0; //WIP =0; FSR[2]=1
            Suspended = 1;
            
            if (oldOperation=="Sector Erase") begin
                delay_resume=erase_delay-($time - startTime);
                sec_erase_susp = 1;
                sec_susp= f.sec(destAddr);
                disable erase_ops;
                disable errorCheck_ops;
            end
            `ifdef SubSect
              else if (oldOperation=="Subsector Erase") begin
                    delay_resume=erase_ss_delay-($time - startTime);
                    subsec_erase_susp = 1;
                    sec_susp= f.sec(destAddr);
                    disable erase_ops;
                    disable errorCheck_ops;
              end  
            `endif  
              else if (oldOperation=="Page Program" || oldOperation=="Dual Program" || oldOperation=="Quad Program" ||
                       oldOperation=="Dual Extended Program" || oldOperation=="Quad Extended Program" || 
                       oldOperation=="Dual Command Page Program" || oldOperation=="Quad Command Page Program") begin
                       delay_resume=program_delay-($time - startTime);
                       prog_susp = 1;
                       page_susp = f.pag(destAddr);
                       disable program_ops;
                       disable errorCheck_ops;
              end


        end


        begin : reset
        
          @N25Qxxx.resetEvent;
            operation = "None";
            disable exe;    
        
        end

            
    join

  end


 //------------------------
 // Program Erase Resume
 //-------------------------

always @N25Qxxx.seqRecognized 
    
    if (N25Qxxx.cmdRecName==="Program Erase Resume") fork :resume_ops

                                                                                                                                                                             

        begin : exe
            
           @(posedge N25Qxxx.S);
            
            disable reset;
            operation = N25Qxxx.cmdRecName;
            N25Qxxx.latchingMode="N";
            delay=delay_resume;
            
            if (doubleSuspend==1) begin 
                Suspended=1;
            end 
            else Suspended=0;
            N25Qxxx.busy=1;
            
            -> errorCheck;

            @(noError) begin
                
                if (oldOperation=="Sector Erase")  begin
                    mem.eraseSector(destAddr);
                    sec_erase_susp = 0;
                end    
                `ifdef SubSect
                else if (oldOperation=="Subsector Erase") begin
                    mem.eraseSubsector(destAddr); 
                    subsec_erase_susp = 0;
                end    
                    
                `endif
                else begin
                    mem.writePageToMemory;
                    prog_susp = 0;
                end 
                
                $display(" [%0t ns] Command execution completed: %0s.", $time, oldOperation);
                if (doubleSuspend==1) begin 
                   doubleSuspend=0;
                   oldOperation=holdOperation;
               end    
            end
                
        end 


        begin : reset
        
          @N25Qxxx.resetEvent;
            writePage_en=0;
            operation = "None";
            disable exe;    
        
        end

    join




    //---------------------------
    //  Program OTP 
    //---------------------------

    
        reg write_OTP_buffer_en=0;
     
         `define OTP_lockBit N25Qxxx.OTP.mem[OTP_dim-1][0]

        always @N25Qxxx.seqRecognized if(N25Qxxx.cmdRecName=="Program OTP")

           if(flag.FSR[4]) begin
                $display(" [%0t ns] **WARNING** It's not allowed to perform a program instruction. Program Status bit is high!",$time); 
                disable OTP_prog_ops;
           end else

        fork : OTP_prog_ops

            begin
                OTP.resetBuffer;
                OTP.setAddr(N25Qxxx.addr);
                N25Qxxx.latchingMode="D";
                write_OTP_buffer_en = 1;
            end

            begin : exe
               @(posedge N25Qxxx.S);
                disable reset;
                operation=N25Qxxx.cmdRecName;
                write_OTP_buffer_en=0;
                N25Qxxx.latchingMode="N";
                N25Qxxx.busy=1;
                startTime = $time;
                $display("  [%0t ns] Command execution begins: OTP Program.",$time);
                delay=program_delay;
                -> errorCheck;

                @(noError) begin
                    OTP.writeBufferToMemory;
                    $display("  [%0t ns] Command execution completed: OTP Program.",$time);
                end
            end  

            begin : reset
               @N25Qxxx.resetEvent;
                write_OTP_buffer_en=0;
                operation = "None";
                disable exe;    
            end
        
        join



        always @N25Qxxx.dataLatched if(write_OTP_buffer_en) begin

            OTP.writeDataToBuffer(N25Qxxx.data);
        
        end









    //------------------------
    //  Error check
    //------------------------
    // This process also models  
    // the operation delays
    

    always @(errorCheck) fork : errorCheck_ops
    
    
        begin : static_check

            if((operation=="Dual Extended Program" || N25Qxxx.protocol=="dual") && N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=0) begin
                N25Qxxx.f.clock_error;
                -> error;
            end else if ((operation=="Quad Extended Program"|| N25Qxxx.protocol=="quad") && N25Qxxx.ck_count!=0 && N25Qxxx.ck_count!=2 && 
                         N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=6) begin 
                        N25Qxxx.f.clock_error;
                        -> error;
            end else if(operation!="Dual Extended Program" && operation!="Quad Extended Program" && operation!="Dual Command Page Program" && N25Qxxx.protocol=="extended" && N25Qxxx.ck_count!=0) begin 

                N25Qxxx.f.clock_error;
                -> error;
                            
            end else if(`WEL==0) begin
               
                N25Qxxx.f.WEL_error;
                -> error;
            
            end else if ( (operation=="Page Program" || operation=="Dual Program" || operation=="Dual Extended Program" || 
                           operation=="Quad Extended Program" || operation=="Quad Program" || operation=="Dual Command Page Program" || 
                           operation=="Sector Erase" ||  operation=="Subsector Erase")

                                                        &&
                          (lock.isProtected_by_SR(destAddr)!==0 || lock.isProtected_by_lockReg(destAddr)!==0) ) begin
           
                -> error;

                if (lock.isProtected_by_SR(destAddr)!==0 && lock.isProtected_by_lockReg(destAddr)!==0)
                $display("  [%0t ns] **WARNING** Sector locked by Status Register and by Lock Register: operation aborted.", $time);
            
                else if (lock.isProtected_by_SR(destAddr)!==0)
                $display("  [%0t ns] **WARNING** Sector locked by Status Register: operation aborted.", $time);
            
                else if (lock.isProtected_by_lockReg(destAddr)!==0) 
                $display("  [%0t ns] **WARNING** Sector locked by Lock Register: operation aborted.", $time);
            
            end else if (operation=="Bulk Erase" && lock.isAnySectorProtected(0)) begin
                
                $display("  [%0t ns] **WARNING** Some sectors are locked: bulk erase aborted.", $time);
                -> error;
            
            end 
            else if (operation=="Bulk Erase" && N25Qxxx.Vpp_W_DQ2==0) begin
                 $display("  [%0t ns] **WARNING** Vpp_W=0 : bulk erase aborted.", $time);
                 -> error;
            
            end 
            
              else if(operation=="Write SR" && `SRWD==1 && N25Qxxx.W_int===0) begin
                  $display("  [%0t ns] **WARNING** SRWD bit set to 1, and W=0: write SR isn't allowed!", $time);
                  -> error;
              end

 
            
                
                    else if (operation=="Program OTP" && `OTP_lockBit==0) begin 
                    $display("  [%0t ns] **WARNING** OTP is read only, because lock bit has been programmed to 0: operation aborted.", $time);
                    -> error;    
                    end
            
        end


        fork : dynamicCheck

            @(N25Qxxx.voltageFault) begin
                $display("  [%0t ns] **WARNING** Operation Fault because of Vcc Out of Range!", $time);
                -> error;
            end
            
            `ifdef RESET_pin
              if (operation!="Write SR") @(N25Qxxx.resetEvent) begin
                $display("  [%0t ns] **WARNING** Operation Fault because of Device Reset!", $time);
                -> error;
              end
            `endif  
            #delay begin 
            N25Qxxx.busy=0;
                if(!Suspended) -> stat.WEL_reset;
                -> noError;
                disable dynamicCheck;
                disable errorCheck_ops;
            end
        join

        
    join




    always @(error) begin

        N25Qxxx.busy = 0;
        -> stat.WEL_reset;
        disable errorCheck_ops;
        if (operation=="Page Program" || operation=="Dual Program" || operation=="Quad Program" || operation=="Dual Command Page Program" 
             || operation=="Dual Extended Program" || operation=="Quad Extended Program") disable program_ops;
        else if (operation=="Sector Erase" || operation=="Subsector Erase" || operation=="Bulk Erase") disable erase_ops;
        else if (operation=="Write SR") disable write_SR_ops;
        else if (operation=="Write NV Configuration Reg") disable write_NVCR_ops;
        else if (operation=="Write Volatile Configuration Reg") disable write_VCR_ops; 
        else if (operation=="Write VE Configuration Reg") disable write_VECR_ops;
        else if (operation=="Program OTP") disable OTP_prog_ops;

    end






endmodule












/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           STATUS REGISTER MODULE                      --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module StatusRegister;


    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"

    event errorCheck, error, noError ;

    // status register
    reg [7:0] SR;
    




    //--------------
    // Init
    //--------------


    initial begin
        
        //see alias in DevParam.h
        
        SR[2] = 0; // BP0 - block protect bit 0 
        SR[3] = 0; // BP1 - block protect bit 1
        SR[4] = 0; // BP2 - block protect bit 2
        SR[5] = 0; // TB (block protect top/bottom) 
        SR[6] = 0; // BP3 - block protect bit 3
        SR[7] = 0; // SRWD

    end


    always @(N25Qxxx.PollingAccessOn) if(N25Qxxx.PollingAccessOn) begin
        
        SR[0] = 1; // WIP - write in progress
        SR[1] = 0; // WEL - write enable latch

    end

    always @(N25Qxxx.checkProtocol) begin
        
        SR[0] = 0; // WIP - write in progress
        SR[1] = 0; // WEL - write enable latch

    end

    always @(N25Qxxx.ReadAccessOn) if(N25Qxxx.ReadAccessOn) begin
        
        SR[0] = 0; // WIP - write in progress
       // SR[1] = 0; // WEL - write enable latch

    end


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Enable" && N25Qxxx.FastPOR_enable) begin
        
       SR[0] = 1;

     
    end  

    //----------
    // WIP bit
    //----------
    
    always @(N25Qxxx.busy)
        `WIP = N25Qxxx.busy;

   
    //----------
    // WEL bit 
    //----------
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Enable") fork : WREN 
        
        begin : exe
          @(posedge N25Qxxx.S); 
          disable reset;
           -> errorCheck;
           @ (noError) begin
             `WEL = 1;
              $display("  [%0t ns] Command execution: WEL bit set.", $time);
            end
        end

        begin : reset
          @N25Qxxx.resetEvent;
          disable exe;
        end
    
    join


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Disable") fork : WRDI 
        
        begin : exe
          @(posedge N25Qxxx.S);
          disable reset;
          -> errorCheck;
          @ (noError) begin
            `WEL = 0;
             $display("  [%0t ns] Command execution: WEL bit reset.", $time);
          end 
        end
        
        begin : reset
          @N25Qxxx.resetEvent;
          disable exe;
        end
        
    join


    event WEL_reset;
    always @(WEL_reset)
        `WEL = 0;


    

    //------------------------
    // write status register
    //------------------------

    // see "Program" module



    //----------------------
    // read status register
    //----------------------
    // NB : "Read SR" operation is also modelled in N25Qxxx.module

    reg enable_SR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read SR") fork 
        
        enable_SR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_SR_read=0;
        
    join    

    


    

 always @(errorCheck) begin : errorCheck_ops

  begin : static_check


            if(N25Qxxx.protocol=="dual" && N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=0) begin
                N25Qxxx.f.clock_error;
                -> error;
            end else if (N25Qxxx.protocol=="quad" && N25Qxxx.ck_count!=0 && N25Qxxx.ck_count!=2 && 
                         N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=6) begin 
                        N25Qxxx.f.clock_error;
                        -> error;
            end else if(N25Qxxx.protocol=="extended" && N25Qxxx.ck_count!=0) begin 

                N25Qxxx.f.clock_error;
                -> error;
            end else -> noError;  
  end
  
  fork : dynamicCheck

            @(N25Qxxx.voltageFault) begin
                $display("  [%0t ns] **WARNING** Operation Fault because of Vcc Out of Range!", $time);
                -> error;
            end
            
            #0 begin 
            N25Qxxx.busy=0;
                -> noError;
                disable dynamicCheck;
                disable errorCheck_ops;
            end
  join

            
end

    always @(error) begin

        N25Qxxx.busy = 0;
        ->WEL_reset;
        disable errorCheck_ops;
        if (N25Qxxx.cmdRecName=="Write Enable") disable WREN; 

        else if (N25Qxxx.cmdRecName=="Write Disable") disable WRDI;

    end

endmodule   














/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           STATUS REGISTER MODULE                      --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module FlagStatusRegister;


    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"


    event errorCheck, error, noError;
    
    // flag status register
    reg [7:0] FSR;
    
    time delay;



    //--------------
    // Init
    //--------------


    initial begin
        FSR[0] = 0; // Reserved 
        FSR[1] = 0; // Protection Status bit 
        FSR[2] = 0; // Program Suspend Status bit 
        FSR[3] = 0; // VPP status bit not implemented
        FSR[4] = 0; // Program Status bit
        FSR[5] = 0; // Erase Status bit 
        FSR[6] = 0; // Erase Suspend status bit 
        FSR[7] = 1; // P/E Controller bit(!WIP)


    end



    //-----------------------
    // P/E Controller bit
    //-----------------------

    
    always @(`WIP)
        FSR[7]=!(`WIP);


    //------------------------------
    // Erase and Program Suspend bit 
    //------------------------------
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Program Erase Suspend" && FSR[7]==1) begin  
        if (prog.oldOperation=="Sector Erase" || prog.oldOperation=="Subsector Erase")  FSR[6]=1;
        else FSR[2]=1;  
    end

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Program Erase Resume") begin
       if (prog.oldOperation=="Sector Erase" || prog.oldOperation=="Subsector Erase")  FSR[6]=0;
       else FSR[2]=0;
        end
        


//------------------------------------------
// Erase Status bit and Program Status bit 
//------------------------------------------

     always @ prog.error begin

       if (prog.operation=="Sector Erase" || prog.operation=="Subsector Erase" || prog.operation=="Bulk Erase" )  FSR[5]=1;
        else if (prog.operation=="Program OTP" || prog.operation=="Page Program" || prog.operation=="Dual Program" ||
                 prog.operation=="Quad Program" || prog.operation=="Dual Extended Program" || prog.operation=="Quad Extended Program") 
             FSR[4]=1;  

     end

//-------------------
// Vpp Status bit 
//-------------------

//not implemented 


 `define OTP_lockBit N25Qxxx.OTP.mem[OTP_dim-1][0]
//------------------------
// Protection Status bit 
//------------------------

always @ prog.error  if (((prog.operation=="Page Program" || prog.operation=="Dual Program" ||
                           prog.operation=="Dual Extended Program" || prog.operation=="Quad Extended Program" ||
                           prog.operation=="Quad Program" || prog.operation=="Sector Erase" || 
                           prog.operation=="Subsector Erase")
                                                        &&
                          (lock.isProtected_by_SR(prog.destAddr)!==0 || lock.isProtected_by_lockReg(prog.destAddr)!==0))
                                                           ||
                           (prog.operation=="Bulk Erase" && lock.isAnySectorProtected(0)) 
                                                           ||
                           (prog.operation=="Write SR" && `SRWD==1 && N25Qxxx.W_int===0)
                                                           ||
                            (prog.operation=="Program OTP" && `OTP_lockBit==0))  
                               
                          
                    begin
           
                         FSR[1]=1;

                    end




 //---------------------------
 // read flag status register
 //---------------------------
    // NB : "Read FSR" operation is also modelled in N25Qxxx.module

    reg enable_FSR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Flag SR") fork 
        
        enable_FSR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_FSR_read=0;
        
    join  

//---------------------------
// clear flag status register
//---------------------------
     always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Clear Flag SR") begin : FSR_clear_ops
        
         @(posedge N25Qxxx.S) begin
         
            N25Qxxx.latchingMode="N";
            N25Qxxx.busy=1;
            $display("  [%0t ns] Command execution begins:Clear Flag Status Register.",$time);
            
            delay=clear_FSR_delay;

            -> errorCheck;

                @(noError) begin

            
            #0;
            FSR[1] = 0; // Protection Status bit 
            FSR[3] = 0; // VPP status bit
            FSR[4] = 0; // Program Status bit
            FSR[5] = 0; // Erase Status bit 
            $display("  [%0t ns] Command execution completed: Clear Flag Status Register. FSR=%b",
                         $time, FSR);
            end            
         end

     end    




 //------------------------
    //  Error check
    //------------------------
    // This process also models  
    // the operation delays
    

    always @(errorCheck) fork : errorCheck_ops
    
    
        begin : static_check

            if(N25Qxxx.protocol=="dual" && N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=0) begin
                N25Qxxx.f.clock_error;
                -> error;
            end else if (N25Qxxx.protocol=="quad" && N25Qxxx.ck_count!=0 && N25Qxxx.ck_count!=2 && 
                         N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=6) begin 
                        N25Qxxx.f.clock_error;
                        -> error;
            end else if(N25Qxxx.protocol=="extended" && N25Qxxx.ck_count!=0) begin 

                N25Qxxx.f.clock_error;
                -> error;
                            
            end
        
        end

        fork : dynamicCheck

            @(N25Qxxx.voltageFault) begin
                $display("  [%0t ns] **WARNING** Operation Fault because of Vcc Out of Range!", $time);
                -> error;
            end
            
            #delay begin 
            N25Qxxx.busy=0;
                -> noError;
                disable dynamicCheck;
                disable errorCheck_ops;
            end
        join

        
    join




    always @(error) begin

        N25Qxxx.busy = 0;
        disable errorCheck_ops;
        disable FSR_clear_ops;

    end






endmodule   









/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   NON VOLATILE CONFIGURATION REGISTER MODULE          --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module NonVolatileConfigurationRegister;

    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"

    parameter [15:0] NVConfigReg_default = 'b1111111111111111;
   
    // non volatile configuration register

    reg [15:0] NVCR;

     
    //--------------
    // Init
    //--------------


    initial begin
        
        NVCR[15:0] = NVConfigReg_default;
                                            // NVCR[15:12] = 'b1111; //dummy clock cycles number (default)
                                            // NVCR[11:9] = 'b111; // XIP disabled (default)
                                            // NVCR[8:6] = 'b111; //Output driver strength (default)
                                            // NVCR[5] = 'b1; //fast POR Read disabled(default) 
                                            // NVCR[4] = 'b1; // Reset/Hold enabled(default)
                                            // NVCR[3] = 'b1; //Quad Input Command disabled (default)
                                            // NVCR[2] = 'b1; //Dual Input Command disabled (default)
                                            //NVCR[1:0] = dontCare; // default value "11"
        
    end


    //------------------------------------------
    // write Non Volatile Configuration Register
    //------------------------------------------

    // see "Program" module



    //-----------------------------------------
    // Read Non Volatile Configuration register
    //-----------------------------------------
    // NB : "Read Non Volatile Configuration register" operation is also modelled in N25Qxxx.module

    reg enable_NVCR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read NV Configuration Reg") fork 
        
        enable_NVCR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_NVCR_read=0;
        
    join    

    


    



endmodule   














/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   NON VOLATILE CONFIGURATION REGISTER MODULE          --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module VolatileConfigurationRegister;

    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"

    parameter [7:0] VConfigReg_default = 'b11111000;
   
    // volatile configuration register

    reg [7:0] VCR;

     
    //--------------
    // Init
    //--------------


    initial begin
        
        VCR[7:0] = VConfigReg_default;
                                            // VCR[7:4] = 'b1111; //dummy clock cycles number (default)
                                            // VCR[3] = 'b1; // XIP disabled (default)
                                            // VCR[2:0] = 'b000; //reserved
        
    end


    //------------------------------------------
    // write Volatile Configuration Register
    //------------------------------------------

    // see "Program" module



    //-----------------------------------------
    // Read Volatile Configuration register
    //-----------------------------------------
    // NB : "Read Volatile Configuration register" operation is also modelled in N25Qxxx.module

    reg enable_VCR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Volatile Configuration Reg") fork 
        
        enable_VCR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_VCR_read=0;
        
    join    

    


    



endmodule   














/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--   NON VOLATILE CONFIGURATION REGISTER MODULE          --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module VolatileEnhancedConfigurationRegister;

    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"

    parameter [7:0] VEConfigReg_default = 'b11011111;
   
    // non volatile configuration register

    reg [7:0] VECR;

     
    //--------------
    // Init
    //--------------


    initial begin
        
        VECR[7:0] = VEConfigReg_default;
                                            // VECR[7] = 'b1; //quad input command disable (default)
                                            // VECR[6] = 'b1; // dual input command disable (default)
                                            // VECR[5] = 'b0; //reserved fixed value =0b
                                            // VECR[4] = 'b1; // Reset/Hold disable(default)
                                            // VECR[3] = 'b1; //Accelerator pin enable in Quad SPI protocol(default) //not implemented
                                            //VECR[2:0] ='b111; // Output driver strength
        
    end

always @VECR if (N25Qxxx.Vcc_L2) begin

if (VECR[7]==0) N25Qxxx.protocol="quad";
else if (VECR[6]==0)N25Qxxx.protocol="dual";
else if (VECR[7]==1 && VECR[6]==1) N25Qxxx.protocol="extended";
 $display("[%0t ns] ==INFO== Protocol selected is %0s",$time,N25Qxxx.protocol);


end


    //------------------------------------------
    // write Volatile Enhanced Configuration Register
    //------------------------------------------

    // see "Program" module



    //-----------------------------------------
    // Read Volatile Enhanced Configuration register
    //-----------------------------------------
    // NB : "Read Volatile Enhanced Configuration register" operation is also modelled in N25Qxxx.module

    reg enable_VECR_read;
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read VE Configuration Reg") fork 
        
        enable_VECR_read=1;

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_VECR_read=0;
        
    join    

    


    



endmodule   














/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           READ MODULE                                 --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module Read;


    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"
    
   
   
    reg enable, enable_fast = 0;




    //--------------
    //  Read
    //--------------
    // NB : "Read" operation is also modelled in N25Qxxx.module
    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read") fork 
        
        begin
           
            if(prog.prog_susp && prog.page_susp==f.pag(N25Qxxx.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
            else begin    
                enable = 1;
                mem.setAddr(N25Qxxx.addr);
            end    
        end
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault) 
            enable=0;
        
    join




    //--------------
    //  Read Fast
    //--------------

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Fast") fork

        begin
             if(prog.prog_susp && prog.page_susp==f.pag(N25Qxxx.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
            else begin 
            
            mem.setAddr(N25Qxxx.addr);
            $display("  [%0t ns] Dummy byte expected ...",$time);
            N25Qxxx.latchingMode="Y"; //Y=dummy
            @N25Qxxx.dummyLatched;
            enable_fast = 1;
            N25Qxxx.latchingMode="N";

            end
        end

        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_fast=0;
    
    join





    //-----------------
    //  Read ID
    //-----------------

    reg enable_ID;
    reg [4:0] ID_index;

    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read ID") fork 
        
        begin
            enable_ID = 1;
            ID_index=0;
        end
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_ID=0;
        
    join


    //--------------------------
    // Multiple I/O Read ID
    //--------------------------


    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Multiple I/O Read ID") fork 
        
        begin
            enable_ID = 1;
            ID_index=0;
        end
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_ID=0;
        
    join


    //-------------
    //  Dual Read  
    //-------------

    reg enable_dual=0;
    
    
      always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Dual Output Fast Read" ||
                                          N25Qxxx.cmdRecName=="Dual I/O Fast Read" ||
                                          N25Qxxx.cmdRecName=="Dual Command Fast Read") fork

          begin

           if(prog.prog_susp && prog.page_susp==f.pag(N25Qxxx.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
            else begin
            
              mem.setAddr(N25Qxxx.addr);
              $display("  [%0t ns] Dummy byte expected ...",$time);
              
              N25Qxxx.latchingMode="Y"; //Y=dummy
              @N25Qxxx.dummyLatched;
              enable_dual = 1;
              N25Qxxx.latchingMode="N";

             end 
          end 

          @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
              enable_dual=0;
    
      join



  //-------------------------
  //  Quad Read  
  //-------------------------

    reg enable_quad=0;
    
    
      always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Quad Output Read" ||
                                          N25Qxxx.cmdRecName=="Quad I/O Fast Read" ||
                                          N25Qxxx.cmdRecName=="Quad Command Fast Read" ) fork

          begin

           if(prog.prog_susp && prog.page_susp==f.pag(N25Qxxx.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
                
            else if(prog.sec_erase_susp && prog.sec_susp==f.sec(N25Qxxx.addr)) 
                 $display("  [%0t ns] **WARNING** It's not allowed to read the sector whose erase cycle is suspended",$time);

            else if (prog.subsec_erase_susp && prog.sec_susp==f.sec(N25Qxxx.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the sector cointaining the subsector whose erase cycle is suspended",$time);


            else begin
            
              mem.setAddr(N25Qxxx.addr);
              $display("  [%0t ns] Dummy clock cycles expected ...",$time);
              N25Qxxx.latchingMode="Y"; //Y=dummy
              @N25Qxxx.dummyLatched;
              enable_quad = 1;
              N25Qxxx.latchingMode="N";

            end
            
          end 

          @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
              enable_quad=0;
    
      join




    //-------------
    //  Read OTP 
    //-------------
    // NB : "Read OTP" operation is also modelled in N25Qxxx.module

    reg enable_OTP=0;
    
    
      always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read OTP") fork 
        
          begin
              $display("  [%0t ns] Dummy byte expected ...",$time);
              N25Qxxx.latchingMode="Y"; //Y=dummy
              @N25Qxxx.dummyLatched;

              enable_OTP = 1;
              N25Qxxx.latchingMode="N";
              OTP.setAddr(N25Qxxx.addr);
          end
        
          @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
              enable_OTP=0;
        
      join
    
    


    


endmodule


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           LOCK MANAGER MODULE                         --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns 

module LockManager;


`include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"


 event errorCheck, error, noError; 

//---------------------------------------------------
// Data structures for protection status modelling
//---------------------------------------------------


// array of sectors lock status (status determinated by Block Protect Status Register bits)
reg [nSector-1:0] lock_by_SR; //(1=locked)

  // Lock Registers (there is a pair of Lock Registers for each sector)
  reg [nSector-1:0] LockReg_WL ;   // Lock Register Write Lock bit (1=lock enabled)
  reg [nSector-1:0] LockReg_LD ;   // Lock Register Lock Down bit (1=lock down enabled)

integer i;






//----------------------------
// Initial protection status
//----------------------------

initial
    for (i=0; i<=nSector-1; i=i+1)
        lock_by_SR[i] = 0;
        //LockReg_WL & LockReg_LD are initialized by powerUp  
    


//------------------------
// Reset signal effects
//------------------------

  
  always @N25Qxxx.resetEvent 
      for (i=0; i<=nSector-1; i=i+1) begin
          LockReg_WL[i] = 0;
          LockReg_LD[i] = 0;
      end    





//----------------------------------
// Power up : reset lock registers
//----------------------------------


  always @(N25Qxxx.ReadAccessOn) if(N25Qxxx.ReadAccessOn) 
      for (i=0; i<=nSector-1; i=i+1) begin
          LockReg_WL[i] = 0;
          LockReg_LD[i] = 0;
      end







//------------------------------------------------
// Protection managed by BP status register bits
//------------------------------------------------

integer nLockedSector;
integer temp;


  
  always @(`TB or `BP3 or `BP2 or `BP1 or `BP0) 
  begin

      for (i=0; i<=nSector-1; i=i+1) //reset lock status of all sectors
          lock_by_SR[i] = 0;
    
      temp = {`BP3, `BP2, `BP1, `BP0};
      nLockedSector = 2**(temp-1); 

      if (nLockedSector>0 && `TB==0) // upper sectors protected
          for ( i=nSector-1 ; i>=nSector-nLockedSector ; i=i-1 )
          begin
              lock_by_SR[i] = 1;
              $display("  [%0t ns] ==INFO== Sector %0d locked", $time, i);
          end
    
      else if (nLockedSector>0 && `TB==1) // lower sectors protected 
          for ( i = 0 ; i <= nLockedSector-1 ; i = i+1 ) 
          begin
              lock_by_SR[i] = 1;
              $display("  [%0t ns] ==INFO== Sector %0d locked", $time, i);
          end

  end


//--------------------------------------
// Protection managed by Lock Register
//--------------------------------------

reg enable_lockReg_read=0;




    reg [sectorAddrDim-1:0] sect;
    reg [dataDim-1:0] sectLockReg;



    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Write Lock Reg") fork : WRLR

        begin : exe1
            sect = f.sec(N25Qxxx.addr);
            N25Qxxx.latchingMode = "D";
            @(N25Qxxx.dataLatched) sectLockReg = N25Qxxx.data;
        end

        begin : exe2
            @(posedge N25Qxxx.S);
            disable exe1;
            disable reset;
             -> errorCheck;
            @ (noError) begin
               -> stat.WEL_reset;
               if(`WEL==0)
                   N25Qxxx.f.WEL_error;
               else if (LockReg_LD[sect]==1)
                   $display("  [%0t ns] **WARNING** Lock Down bit is set. Write lock register is not allowed!", $time);
               else begin
                LockReg_LD[sect]=sectLockReg[1];
                LockReg_WL[sect]=sectLockReg[0];
                $display("  [%0t ns] Command execution: lock register of sector %0d set to (%b,%b)", 
                          $time, sect, LockReg_LD[sect], LockReg_WL[sect] );
              end  
           end   
        end

        begin : reset
            @N25Qxxx.resetEvent;
            disable exe1;
            disable exe2;
        end
        
    join




    // Read lock register

    
    always @(N25Qxxx.seqRecognized) if (N25Qxxx.cmdRecName=="Read Lock Reg") fork

        begin
          sect = f.sec(N25Qxxx.addr); 
          N25Qxxx.dataOut = {4'b0, LockReg_LD[sect], LockReg_WL[sect]};
          enable_lockReg_read=1;
        end   
        
        @(posedge(N25Qxxx.S) or N25Qxxx.resetEvent or N25Qxxx.voltageFault)
            enable_lockReg_read=0;
        
    join



 always @(errorCheck) begin : errorCheck_ops

  begin : static_check


            if(N25Qxxx.protocol=="dual" && N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=0) begin
                N25Qxxx.f.clock_error;
                -> error;
            end else if (N25Qxxx.protocol=="quad" && N25Qxxx.ck_count!=0 && N25Qxxx.ck_count!=2 && 
                         N25Qxxx.ck_count!=4 && N25Qxxx.ck_count!=6) begin 
                        N25Qxxx.f.clock_error;
                        -> error;
            end else if(N25Qxxx.protocol=="extended" && N25Qxxx.ck_count!=0) begin 

                N25Qxxx.f.clock_error;
                -> error;
            end else -> noError;  
  end
  
  fork : dynamicCheck

            @(N25Qxxx.voltageFault) begin
                $display("  [%0t ns] **WARNING** Operation Fault because of Vcc Out of Range!", $time);
                -> error;
            end
            
            #0 begin 
            N25Qxxx.busy=0;
                -> noError;
                disable dynamicCheck;
                disable errorCheck_ops;
            end
  join

            
end

    always @(error) begin

        N25Qxxx.busy = 0;
        ->stat.WEL_reset;
        disable errorCheck_ops;
        disable WRLR; 

    end




//-------------------------------------------
// Function to test sector protection status
//-------------------------------------------

function isProtected_by_SR;
input [addrDim-1:0] byteAddr;
reg [sectorAddrDim-1:0] sectAddr;
begin

    sectAddr = f.sec(byteAddr);
    isProtected_by_SR = lock_by_SR[sectAddr]; 

end
endfunction





function isProtected_by_lockReg;
input [addrDim-1:0] byteAddr;
reg [sectorAddrDim-1:0] sectAddr;
begin

      sectAddr = f.sec(byteAddr);
      isProtected_by_lockReg = LockReg_WL[sectAddr];

end
endfunction





function isAnySectorProtected;
input required;
begin

    i=0;   
    isAnySectorProtected=0;
    while(isAnySectorProtected==0 && i<=nSector-1) begin 
          isAnySectorProtected=lock_by_SR[i] || LockReg_WL[i];
        i=i+1;
    end    

end
endfunction







endmodule













/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           DUAL OPS MODULE                             --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
// In this module are modeled 
// "Dual Input Fast Program"
// and "Dual Output Fast program"
// commands

`timescale 1ns / 1ns

module DualQuadOps (S, C, ck_count, DQ0, DQ1, Vpp_W_DQ2, HOLD_DQ3);

    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"

    input S;
    input C;
    input [2:0] ck_count;

    output DQ0, DQ1, Vpp_W_DQ2;
    
  `ifdef HOLD_pin
    output HOLD_DQ3;
   `endif

   `ifdef RESET_pin
    output RESET_DQ3; 
   `endif



    

    //----------------------------
    // Latching data (dual input)
    //----------------------------

    always @(posedge C) if (N25Qxxx.logicOn && N25Qxxx.latchingMode=="F") begin : CP_latchData_fast //fast=dual

        N25Qxxx.data[N25Qxxx.iData] = DQ1;
        N25Qxxx.data[N25Qxxx.iData-1] = DQ0;

        if (N25Qxxx.iData>=3)
            N25Qxxx.iData = N25Qxxx.iData-2;
        else begin
        if (N25Qxxx.cmdRecName=="Write NV Configuration Reg" && prog.LSByte) begin
            N25Qxxx.LSdata=N25Qxxx.data;
             prog.LSByte=0;
        end 
            -> N25Qxxx.dataLatched;
            $display("  [%0t ns] Data latched: %h", $time,N25Qxxx.data);
            N25Qxxx.iData=N25Qxxx.dataDim-1;
        end    

    end


    //----------------------------
    // Latching data (quad input)
    //----------------------------

    always @(posedge C) if (N25Qxxx.logicOn && N25Qxxx.latchingMode=="Q") begin : CP_latchData_quad //quad

        `ifdef HOLD_pin
        N25Qxxx.data[N25Qxxx.iData] = HOLD_DQ3;
        `endif

       `ifdef RESET_pin
        N25Qxxx.data[N25Qxxx.iData] = RESET_DQ3;
       `endif
       
        N25Qxxx.data[N25Qxxx.iData-1] = Vpp_W_DQ2;
        N25Qxxx.data[N25Qxxx.iData-2] = DQ1;
        N25Qxxx.data[N25Qxxx.iData-3] = DQ0;
        if (N25Qxxx.iData==7)
            N25Qxxx.iData = N25Qxxx.iData-4;
        else begin
            if (N25Qxxx.cmdRecName=="Write NV Configuration Reg" && prog.LSByte) begin
            N25Qxxx.LSdata=N25Qxxx.data;
             prog.LSByte=0;
        end
            -> N25Qxxx.dataLatched;
            $display("  [%0t ns] Data latched: %h", $time,N25Qxxx.data);
            N25Qxxx.iData=N25Qxxx.dataDim-1;
        end    

    end





    //----------------------------------
    // dual read (DQ1 and DQ0 out bit)
    //----------------------------------


    reg bitOut='hZ, bitOut_extra='hZ;
    
    reg [addrDim-1:0] readAddr;
    reg [dataDim-1:0] dataOut;

    event sendToBus_dual; 
    
    

    always @(negedge(C)) if(N25Qxxx.logicOn && N25Qxxx.read.enable_dual==1) begin

            if(ck_count==0 || ck_count==4)
            begin
                readAddr = mem.memAddr;
                mem.readData(dataOut); //read data and increments address
                f.out_info(readAddr, dataOut);
                N25Qxxx.dataOut=dataOut; //N25Qxxx.dataOut is accessed by Transactions  
            end
            
            #tCLQX
            bitOut = dataOut[ dataDim-1 - (2*(ck_count%4)) ]; //%=modulo operator
            bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4)) ]; 
            
            -> sendToBus_dual;
            
    end  



// read with DQ1 and DQ0 out bit

always @(negedge(C)) if(N25Qxxx.logicOn && N25Qxxx.protocol=="dual") begin : CP_read_dual

     if (stat.enable_SR_read==1) begin
        
        if(ck_count==0 || ck_count==4) begin 
            dataOut = stat.SR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut = dataOut[dataDim-1- (2*(ck_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4)) ]; 
        -> sendToBus_dual;

     end else if (flag.enable_FSR_read==1) begin
        
        if(ck_count==0 || ck_count==4) begin

            dataOut = flag.FSR;
            f.out_info(readAddr, dataOut);
        end    
       
       #tCLQX

         bitOut = dataOut[dataDim-1- (2*(ck_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4)) ]; 
        -> sendToBus_dual;

     end else if (VolatileReg.enable_VCR_read==1) begin
        
       if(ck_count==0 || ck_count==4) begin
 
            dataOut = VolatileReg.VCR;
            f.out_info(readAddr, dataOut);
       end    
        
        #tCLQX

         bitOut = dataOut[dataDim-1- (2*(ck_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4)) ]; 
        -> sendToBus_dual;
    
     end else if (VolatileEnhReg.enable_VECR_read==1) begin
        
        if(ck_count==0 || ck_count==4) begin

            dataOut = VolatileEnhReg.VECR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX

         bitOut = dataOut[dataDim-1- (2*(ck_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4)) ]; 
        -> sendToBus_dual;
    

     end else if (NonVolatileReg.enable_NVCR_read==1) begin
     
        if((ck_count==0 || ck_count==4) && N25Qxxx.firstNVCR == 1) begin
 
            dataOut = NonVolatileReg.NVCR[7:0];
            f.out_info(readAddr, dataOut);
            N25Qxxx.firstNVCR=0;
          
        end else if((ck_count==0 || ck_count==4) && N25Qxxx.firstNVCR == 0) begin
           dataOut = NonVolatileReg.NVCR[15:8];
           f.out_info(readAddr, dataOut);
           N25Qxxx.firstNVCR=1;
                                   
        end
        

        #tCLQX

         bitOut = dataOut[dataDim-1- (2*(ck_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4))]; 
        -> sendToBus_dual;

      
      end else if (lock.enable_lockReg_read==1) begin

          if(ck_count==0 || ck_count==4)  begin

              readAddr = f.sec(N25Qxxx.addr);
              f.out_info(readAddr, dataOut);
          end
          // dataOut is set in LockManager module
        
        #tCLQX

         bitOut = dataOut[dataDim-1- (2*(ck_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4)) ]; 
        -> sendToBus_dual;


    
      end else if (read.enable_OTP==1) begin 

          if(ck_count==0 || ck_count==4)  begin

              readAddr = 'h0;
              readAddr = OTP.addr;
              OTP.readData(dataOut); //read data and increments address
              f.out_info(readAddr, dataOut);
          end



          #tCLQX

          bitOut = dataOut[dataDim-1- (2*(ck_count%4))];
          bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4)) ]; 
          -> sendToBus_dual;

   
   
    end else if (read.enable_ID==1) begin 

        if(ck_count==0 || ck_count==4)  begin

            readAddr = 'h0;
            readAddr = read.ID_index;
            
            if (read.ID_index==0)      dataOut=Manufacturer_ID;
            else if (read.ID_index==1) dataOut=MemoryType_ID;
            else if (read.ID_index==2) dataOut=MemoryCapacity_ID;
            
            if (read.ID_index<=1) read.ID_index=read.ID_index+1;
            else read.ID_index=0;


            f.out_info(readAddr, dataOut);
        
        end
         
         #tCLQX

         bitOut = dataOut[dataDim-1- (2*(ck_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4)) ]; 
         -> sendToBus_dual;
    end

    
   
end



    always @sendToBus_dual fork


        begin
            force DQ1 = 1'bX;
            force DQ0 = 1'bX; 
        end
        
        #(tCLQV - tCLQX) begin
            force DQ1 = bitOut;
            force DQ0 = bitOut_extra;
        end        

    join



    always @(negedge(C)) if(N25Qxxx.logicOn && (read.enable_dual==1 || N25Qxxx.protocol=="dual")) 
        @(posedge S) begin 
           #tSHQZ 
            release DQ0;
            release DQ1;
        end    
   
    //---------------------------------------------------
    // Quad read (HOLD_DQ3 Vpp_W_DQ2 DQ1 and DQ0 out bit)
    //---------------------------------------------------


    reg bitOut0='hZ, bitOut1='hZ, bitOut2='hZ, bitOut3='hZ;
    

    event sendToBus_quad; 
    
    

    always @(negedge(C)) if(N25Qxxx.logicOn && N25Qxxx.read.enable_quad==1) begin


            if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)//verificare
            begin
                readAddr = mem.memAddr;
                mem.readData(dataOut); //read data and increments address
                f.out_info(readAddr, dataOut);
                N25Qxxx.dataOut=dataOut; //N25Qxxx.dataOut is accessed by Transactions  
            end
           
            #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;
            
    end  

// read with RESET_DQ3/HOLD_DQ3 Vpp_W_DQ2 DQ1 and DQ0 out bit

always @(negedge(C)) if(N25Qxxx.logicOn && N25Qxxx.protocol=="quad") begin : CP_read_quad

         if (stat.enable_SR_read==1) begin
        
        if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
        begin
            dataOut = stat.SR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
         -> sendToBus_quad;

     end else if (flag.enable_FSR_read==1) begin
        
        if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
        begin
                
            dataOut = flag.FSR;
            f.out_info(readAddr, dataOut);
        end    
        
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
         -> sendToBus_quad;

     end else if (VolatileReg.enable_VCR_read==1) begin
        
       if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
       begin
                               
            dataOut = VolatileReg.VCR;
            f.out_info(readAddr, dataOut);
       end    
        
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
        -> sendToBus_quad;
    
     end else if (VolatileEnhReg.enable_VECR_read==1) begin
        
        if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
        begin
            dataOut = VolatileEnhReg.VECR;
            f.out_info(readAddr, dataOut);
        end    
        
         #tCLQX
         bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
         -> sendToBus_quad;
                                              

     end else if (NonVolatileReg.enable_NVCR_read==1) begin
     
      if((ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) && N25Qxxx.firstNVCR == 1) begin
 
            dataOut = NonVolatileReg.NVCR[7:0];
            f.out_info(readAddr, dataOut);
            N25Qxxx.firstNVCR=0;
          
      end else if((ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) && N25Qxxx.firstNVCR == 0) begin
           dataOut = NonVolatileReg.NVCR[15:8];
           f.out_info(readAddr, dataOut);
           N25Qxxx.firstNVCR=1;
                                   
       end

        
        #tCLQX
         bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
         -> sendToBus_quad;

      
      end else if (lock.enable_lockReg_read==1) begin

          if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)  begin

              readAddr = f.sec(N25Qxxx.addr);
              f.out_info(readAddr, dataOut);
          end
          // dataOut is set in LockManager module
        
         #tCLQX
         bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
         -> sendToBus_quad;

    
      end else if (read.enable_OTP==1) begin 

          if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)  begin

              readAddr = 'h0;
              readAddr = OTP.addr;
              OTP.readData(dataOut); //read data and increments address
              f.out_info(readAddr, dataOut);
          end
         
         #tCLQX
         bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
         -> sendToBus_quad;

   
   
    end else if (read.enable_ID==1) begin 

        if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)  begin

            readAddr = 'h0;
            readAddr = read.ID_index;
            
            if (read.ID_index==0)      dataOut=Manufacturer_ID;
            else if (read.ID_index==1) dataOut=MemoryType_ID;
            else if (read.ID_index==2) dataOut=MemoryCapacity_ID;
            
            if (read.ID_index<=1) read.ID_index=read.ID_index+1;
            else read.ID_index=0;


            f.out_info(readAddr, dataOut);
        
        end

         #tCLQX
         bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
         bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
         bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
         bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
         -> sendToBus_quad;
    end

    
   
end



    always @sendToBus_quad fork


        begin

            `ifdef HOLD_pin
            force HOLD_DQ3 = 1'bX;
           `endif 

            `ifdef RESET_pin
            force RESET_DQ3 = 1'bX;
           `endif 

            force Vpp_W_DQ2 = 1'bX;
            force DQ1 = 1'bX;
            force DQ0 = 1'bX; 
        end
        
        #(tCLQV-tCLQX) begin
           `ifdef HOLD_pin
            force HOLD_DQ3 = bitOut3;
           `endif
          
           `ifdef RESET_pin
            force RESET_DQ3 = bitOut3;
           `endif 
            
            force Vpp_W_DQ2 = bitOut2;
            force DQ1 = bitOut1;
            force DQ0 = bitOut0;
        end        

    join



    always @(negedge(C)) if(N25Qxxx.logicOn && read.enable_quad==1 || N25Qxxx.protocol=="quad") 
    
        @(posedge S) 
        
         #tSHQZ begin
         
            release DQ0;
            release DQ1;
            release Vpp_W_DQ2;
            `ifdef HOLD_pin
            release HOLD_DQ3;
            `endif
            
            `ifdef RESET_pin
            release RESET_DQ3;
            `endif 
            
         end   

    `ifdef RESET_pin 
       
       always @N25Qxxx.resetEvent begin
       
            release DQ0; 
            release Vpp_W_DQ2;
            release RESET_DQ3;
       
       end
       
    `endif





endmodule







/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           OTP MEMORY MODULE                           --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module OTP_memory;

    
    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"


    reg [dataDim-1:0] mem [0:OTP_dim-1];
    reg [dataDim-1:0] buffer [0:OTP_dim-1];
      `define OTP_lockBit mem[OTP_dim-1][0]

    reg [OTP_addrDim-1:0] addr;
    reg overflow = 0;

    integer i;



    //-----------
    //  Init
    //-----------

    initial begin
        for (i=0; i<=OTP_dim-2; i=i+1) 
            mem[i] = data_NP;
        mem[OTP_dim-1] = 'bxxxxxxxx;
             `OTP_lockBit = 1;

    end



    //---------------------------
    // Program & Read OTP tasks
    //---------------------------


    // set start address
    // (for program and read operations)
    
    task setAddr;
    input [addrDim-1:0] A;
    begin
        overflow = 0;
        addr = A[OTP_addrDim-1:0];
        if (addr > (OTP_dim-1)) 
        begin
            addr = OTP_dim-1;
            $display(  "  [%0t ns] **WARNING** Address out of OTP memory area. Column %0d will be considered!", $time, addr);
        end    
    end
    endtask


    task resetBuffer;
    for (i=0; i<=OTP_dim-1; i=i+1)
        buffer[i] = data_NP;
    endtask


    task writeDataToBuffer;
    input [dataDim-1:0] data;
    begin
        
        if (!overflow)
            buffer[addr] = data;
        
        if (addr < OTP_dim-1)
            addr = addr + 1;
        else if (overflow==0) 
            overflow = 1;
        else if (overflow==1)
            $display("  [%0t ns] **WARNING** OTP limit reached: data latched will be discarded!", $time);

    end
    endtask



    task writeBufferToMemory;
    begin

        for (i=0; i<=OTP_dim-2; i=i+1)
            mem[i] = mem[i] & buffer[i];
          mem[OTP_dim-1][0] = mem[OTP_dim-1][0] & buffer[OTP_dim-1][0]; 
    end
    endtask  



    task readData;
    output [dataDim-1:0] data;
    begin

        data = mem[addr];
        if (addr < OTP_dim-1)
            addr = addr + 1;

    end
    endtask








endmodule   













/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           TIMING CHECK                                --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module TimingCheck (S, C, D, Q, W, H);

    `include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/N25Q128A13B_v17/include/DevParam.h"

    input S, C, D, Q;
    `ifdef HOLD_pin
      input H; 
    `endif
     input W;
    
    `ifdef RESET_pin
      input R; 
    `endif
    `define W_feature
    
    time delta; //used for interval measuring
    
   

    //--------------------------
    //  Task for timing check
    //--------------------------

    task check;
        
        input [8*8:1] name;  //constraint check
        input time interval;
        input time constr;
        
        begin
        
            if (interval<constr)
                $display("[%0t ns] --TIMING ERROR-- %0s constraint violation. Measured time: %0t ns - Constraint: %0t ns",
                          $time, name, interval, constr);
            
        
        end
    
    endtask



    //----------------------------
    // Istants to be measured
    //----------------------------

    parameter initialTime = -1000;

    time C_high=initialTime, C_low=initialTime;
    time S_low=initialTime, S_high=initialTime;
    time D_valid=initialTime;
     
    `ifdef HOLD_pin
        time H_low=initialTime, H_high=initialTime; 
    `endif

    `ifdef RESET_pin
        time R_low=initialTime, R_high=initialTime; 
    `endif

    `ifdef W_feature
        time W_low=initialTime, W_high=initialTime; 
    `endif


    //------------------------
    //  C signal checks
    //------------------------


    always 
    @C if(C===0) //posedge(C)
    @C if(C===1)
    begin
        
        delta = $time - C_low; 
        check("tCL", delta, tCL);

        delta = $time - S_low; 
        check("tSLCH", delta, tSLCH);

        delta = $time - D_valid; 
        check("tDVCH", delta, tDVCH);

        delta = $time - S_high; 
        check("tSHCH", delta, tSHCH);

        // clock frequency checks
        delta = $time - C_high;
        if (read.enable && delta<TR)
           $display("[%0t ns] --TIMING ERROR-- Violation of Max clock frequency (%0d MHz) during READ operation. T_ck_measured=%0d ns, T_clock_min=%0d ns.",
                      $time, fR, delta, TR);
        else if ( (read.enable_fast || read.enable_ID || read.enable_dual || read.enable_OTP || 
                   stat.enable_SR_read || lock.enable_lockReg_read )   
                          && 
                        delta<TC  )
           $display("[%0t ns] --TIMING ERROR-- Violation of Max clock frequency (%0d MHz). T_ck_measured=%0d ns, T_clock_min=%0d ns.",
                      $time, fC, delta, TC);
        
        `ifdef HOLD_pin
        
            delta = $time - H_low; 
            check("tHLCH", delta, tHLCH);

            delta = $time - H_high; 
            check("tHHCH", delta, tHHCH);
        
        `endif
        
        C_high = $time;
        
    end



    always 
    @C if(C===1) //negedge(C)
    @C if(C===0)
    begin
        
        delta = $time - C_high; 
        check("tCH", delta, tCH);
        
        C_low = $time;
        
    end




    //------------------------
    //  S signal checks
    //------------------------


    always 
    @S if(S===1) //negedge(S)
    @S if(S===0)
    begin
        
        delta = $time - C_high; 
        check("tCHSL", delta, tCHSL);

        delta = $time - S_high; 
        check("tSHSL", delta, tSHSL);

        `ifdef W_feature
          delta = $time - W_high; 
          check("tWHSL", delta, tWHSL);
        `endif


        `ifdef RESET_pin
            //check during decoding
            if (N25Qxxx.resetDuringDecoding) begin 
                delta = $time - R_high; 
                check("tRHSL", delta, tRHSL_1);
                N25Qxxx.resetDuringDecoding = 0;
            end 
            //check during program-erase operation
            else if ( N25Qxxx.resetDuringBusy && (prog.operation=="Page Program" || prog.operation=="Page Write" ||  
                      prog.operation=="Sector Erase" || prog.operation=="Bulk Erase"  || prog.operation=="Page Erase") )   
            begin 
                delta = $time - R_high; 
                check("tRHSL", delta, tRHSL_2);
                N25Qxxx.resetDuringBusy = 0;
            end
            //check during subsector erase
            else if ( N25Qxxx.resetDuringBusy && prog.operation=="Subsector Erase" ) begin 
                delta = $time - R_high; 
                check("tRHSL", delta, tRHSL_3);
                N25Qxxx.resetDuringBusy = 0;
            end
            //check during WRSR
            else if ( N25Qxxx.resetDuringBusy && prog.operation=="Write SR" ) begin 
                delta = $time - R_high; 
                check("tRHSL", delta, tRHSL_4);
                N25Qxxx.resetDuringBusy = 0;
            end
        `endif


        S_low = $time;


    end




    always 
    @S if(S===0) //posedge(S)
    @S if(S===1)
    begin
        
        delta = $time - C_high; 
        check("tCHSH", delta, tCHSH);
        
        S_high = $time;
        
    end



    //----------------------------
    //  D signal (data in) checks
    //----------------------------

    always @D 
    begin

        delta = $time - C_high;
        check("tCHDX", delta, tCHDX);

        if (isValid(D)) D_valid = $time;

    end



    //------------------------
    //  Hold signal checks
    //------------------------


    `ifdef HOLD_pin    
    

        always 
        @H if(H===1) //negedge(H)
        @H if(H===0)
        begin
            
            delta = $time - C_high; 
            check("tCHHL", delta, tCHHL);

            H_low = $time;
            
        end



        always 
        @H if(H===0) //posedge(H)
        @H if(H===1)
        begin
            
            delta = $time - C_high; 
            check("tCHHH", delta, tCHHH);
            
            H_high = $time;
            
        end


    `endif




    //------------------------
    //  W signal checks
    //------------------------


    `ifdef W_feature

        always 
        @W if(W===1) //negedge(W)
        @W if(W===0)
        begin
            
            delta = $time - S_high; 
            if (N25Qxxx.protocol != "quad")
              check("tSHWL", delta, tSHWL);

            W_low = $time;
            
        end

        always 
        @W if(W===0) //posedge(W)
        @W if(W===1)
            W_high = $time;
            
    `endif




    //------------------------
    //  RESET signal checks
    //------------------------


    `ifdef RESET_pin

        always 
        @R if(R===1) //negedge(R)
        @R if(R===0)
            R_low = $time;
            
        always 
        @R if(R===0) //posedge(R)
        @R if(R===1)
        begin
            
            delta = $time - S_high; 
            check("tSHRH", delta, tSHRH);
            
            delta = $time - R_low; 
            check("tRLRH", delta, tRLRH);
            
            R_high = $time;
            
        end

    `endif




    //----------------
    // Others tasks
    //----------------

function isValid;
input bita;
  if (bita!==0 && bita!==1)
	isValid=0;
  else isValid=1;
endfunction




    

endmodule
