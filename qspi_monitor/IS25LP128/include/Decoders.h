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





/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           CUI DECODERS ISTANTIATIONS                  --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


//
// Here are istantiated CUIdecoders
// for commands recognition
//  (this file must be included in "Core.v"
//   file)
//


CUIdecoder   

    #(.cmdName("Write Enable"), .cmdCode('h06), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_writeEnable (!busy && !deep_power_down && WriteAccessOn);

CUIdecoder   

    #(.cmdName("Write Enable"), .cmdCode('h06), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_writeEnableFastPOR (!busy && !deep_power_down && FastPOR_enable && ReadAccessOn);

CUIdecoder   

    #(.cmdName("Write Disable"), .cmdCode('h04), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_writeDisable (!busy  && !deep_power_down  && WriteAccessOn);


CUIdecoder   

    #(.cmdName("Read ID"), .cmdCode('h9F), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_read_ID_1 (!busy && !deep_power_down  && ReadAccessOn && protocol=="extended");


CUIdecoder   

    #(.cmdName("Multiple I/O Read ID"), .cmdCode('hAF), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_multipleIO_read_ID (!busy && !deep_power_down   && ReadAccessOn && protocol!="extended");




  CUIdecoder   

      #(.cmdName("Read ID"), .cmdCode('h9E), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_read_ID_2 (!busy && !deep_power_down  && ReadAccessOn && protocol=="extended");



CUIdecoder   

    #(.cmdName("Read SR"), .cmdCode('h05), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_read_SR (PollingAccessOn && !deep_power_down);


CUIdecoder   

    #(.cmdName("Write SR"), .cmdCode('h01), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_write_SR (!busy && WriteAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Read Flag SR"), .cmdCode('h70), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_read_FSR (PollingAccessOn && !deep_power_down);


CUIdecoder   

    #(.cmdName("Clear Flag SR"), .cmdCode('h50), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_clear_FSR (!busy && WriteAccessOn && !deep_power_down);

//extended protocol

  CUIdecoder   

      #(.cmdName("Write Lock Reg"), .cmdCode('hE5), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_writeLockReg (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

  CUIdecoder   

      #(.cmdName("Read Lock Reg"), .cmdCode('hE8), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_readLockReg (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


//dual protocol

CUIdecoder   

      #(.cmdName("Write Lock Reg"), .cmdCode('hE5), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
      CUIDEC_writeLockRegDual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);

  CUIdecoder   

      #(.cmdName("Read Lock Reg"), .cmdCode('hE8), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
      CUIDEC_readLockRegDual (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);

//quad protocol

CUIdecoder   

      #(.cmdName("Write Lock Reg"), .cmdCode('hE5), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
      CUIDEC_writeLockRegQuad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);

  CUIdecoder   

      #(.cmdName("Read Lock Reg"), .cmdCode('hE8), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
      CUIDEC_readLockRegQuad (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);


 CUIdecoder   

      #(.cmdName("Write NV Configuration Reg"), .cmdCode('hB1), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_writeNVReg (!busy && WriteAccessOn && !deep_power_down);

  CUIdecoder   

      #(.cmdName("Read NV Configuration Reg"), .cmdCode('hB5), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_readNVReg (!busy && ReadAccessOn && !deep_power_down);

 CUIdecoder   

      #(.cmdName("Write Volatile Configuration Reg"), .cmdCode('h81), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_writeVCReg (!busy && WriteAccessOn && !deep_power_down);

CUIdecoder   

      #(.cmdName("Write Volatile Configuration Reg"), .cmdCode('h81), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_writeVCRegFastPOR (!busy && ReadAccessOn && FastPOR_enable && !deep_power_down);

  CUIdecoder   

      #(.cmdName("Read Volatile Configuration Reg"), .cmdCode('h85), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_readVCReg (!busy && ReadAccessOn && !deep_power_down);


 CUIdecoder   

      #(.cmdName("Write VE Configuration Reg"), .cmdCode('h61), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_writeVEReg (!busy && WriteAccessOn && !deep_power_down);


  CUIdecoder   

      #(.cmdName("Write Volatile Configuration Reg"), .cmdCode('h81), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_writeVERegFastPOR (!busy && ReadAccessOn && FastPOR_enable && !deep_power_down);
    

  CUIdecoder   

      #(.cmdName("Read VE Configuration Reg"), .cmdCode('h65), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_readVEReg (!busy && ReadAccessOn && !deep_power_down);



CUIdecoder   

    #(.cmdName("Read"), .cmdCode('h03), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_read (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Read Fast"), .cmdCode('h0B), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_readFast (!busy && ReadAccessOn && protocol=="extended" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Dual Command Fast Read"), .cmdCode('h0B), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_readFastdual (!busy && ReadAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Quad Command Fast Read"), .cmdCode('h0B), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_readFastquad (!busy && ReadAccessOn && protocol=="quad" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Page Program"), .cmdCode('h02), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_pageProgram (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Dual Command Page Program"), .cmdCode('h02), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_pageProgramdual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Quad Command Page Program"), .cmdCode('h02), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_pageProgramquad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);



`ifdef SubSect

  CUIdecoder   

      #(.cmdName("Subsector Erase"), .cmdCode('h20), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_subsectorErase (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down );  

  CUIdecoder   

      #(.cmdName("Subsector Erase"), .cmdCode('h20), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
      CUIDEC_subsectorEraseDual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down );    

CUIdecoder   

      #(.cmdName("Subsector Erase"), .cmdCode('h20), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
      CUIDEC_subsectorEraseQuad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down );    

    

`endif



CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('hD8), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_sectorErase (!busy && WriteAccessOn && protocol=="extended" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('hD8), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_sectorEraseDual (!busy && WriteAccessOn && protocol=="dual" && !deep_power_down);

CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('hD8), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_sectorEraseQuad (!busy && WriteAccessOn && protocol=="quad" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Bulk Erase"), .cmdCode('hC7), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_bulkErase (!busy && WriteAccessOn && !deep_power_down);


`ifdef PowDown

  CUIdecoder   

      #(.cmdName("Deep Power Down"), .cmdCode('hB9), .withAddr(0))
    
      CUIDEC_deepPowerDown (!busy && !deep_power_down && ReadAccessOn);  

  CUIdecoder   

      #(.cmdName("Release Deep Power Down"), .cmdCode('hAB), .withAddr(0))
    
      CUIDEC_releaseDeepPowerDown (!busy && ReadAccessOn);    

`endif




  CUIdecoder   

    #(.cmdName("Read OTP"), .cmdCode('h4B), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_read_OTP (!busy && ReadAccessOn && protocol=="extended" );

  CUIdecoder   

    #(.cmdName("Program OTP"), .cmdCode('h42), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_prog_OTP (!busy && WriteAccessOn && protocol=="extended");   

 CUIdecoder   

    #(.cmdName("Read OTP"), .cmdCode('h4B), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_read_OTPDual (!busy && ReadAccessOn && protocol=="dual" );

  CUIdecoder   

    #(.cmdName("Program OTP"), .cmdCode('h42), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_prog_OTPDual (!busy && WriteAccessOn && protocol=="dual");   

 CUIdecoder   

    #(.cmdName("Read OTP"), .cmdCode('h4B), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_read_OTPQuad (!busy && ReadAccessOn && protocol=="quad" );

  CUIdecoder   

    #(.cmdName("Program OTP"), .cmdCode('h42), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_prog_OTPQuad (!busy && WriteAccessOn && protocol=="quad");   




  CUIdecoder   

    #(.cmdName("Dual Output Fast Read"), .cmdCode('h3B), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_readDual (!busy && ReadAccessOn && protocol=="extended");

 CUIdecoder   

    #(.cmdName("Dual Command Fast Read"), .cmdCode('h3B), .withAddr(0), .with2Addr(2), .with4Addr(0))
    
    CUIDEC_readDualDual (!busy && ReadAccessOn && protocol=="dual");


  CUIdecoder   

    #(.cmdName("Dual Program"), .cmdCode('hA2), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_programDual (!busy && WriteAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Dual Command Page Program"), .cmdCode('hA2), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_programDualDual (!busy && WriteAccessOn && protocol=="dual");


    


  CUIdecoder   

    #(.cmdName("Dual I/O Fast Read"), .cmdCode('hBB), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_readDualIo (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder   

    #(.cmdName("Dual Command Fast Read"), .cmdCode('hBB), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_readDualIoDual (!busy && ReadAccessOn && protocol=="dual");


  CUIdecoder   

    #(.cmdName("Dual Extended Program"), .cmdCode('hD2), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_programDualExtended (!busy && WriteAccessOn  && protocol=="extended");

    CUIdecoder   

    #(.cmdName("Dual Command Page Program"), .cmdCode('hD2), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_programDualExtendedDual (!busy && WriteAccessOn  && protocol=="dual");

 


  CUIdecoder   

      #(.cmdName("Quad Output Read"), .cmdCode('h6B), .withAddr(1), .with2Addr(0), .with4Addr(0))
          
              CUIDEC_readQuad (!busy && ReadAccessOn && protocol=="extended");

CUIdecoder   

      #(.cmdName("Quad Command Fast Read"), .cmdCode('h6B), .withAddr(0), .with2Addr(0), .with4Addr(1))
          
              CUIDEC_readQuadQuad (!busy && ReadAccessOn && protocol=="quad");


  CUIdecoder   

        #(.cmdName("Quad I/O Fast Read"), .cmdCode('hEB), .withAddr(0), .with2Addr(0), .with4Addr(1))
                  
           CUIDEC_readQuadIo (!busy && ReadAccessOn && protocol=="extended");
                                

CUIdecoder   

      #(.cmdName("Quad Command Fast Read"), .cmdCode('hEB), .withAddr(0), .with2Addr(0), .with4Addr(1))
          
              CUIDEC_readQuadIoQuad (!busy && ReadAccessOn && protocol=="quad");



  CUIdecoder   

      #(.cmdName("Quad Program"), .cmdCode('h32), .withAddr(1), .with2Addr(0), .with4Addr(0))
                        
        CUIDEC_programQuad (!busy && WriteAccessOn && protocol=="extended");

  CUIdecoder   

      #(.cmdName("Quad Command Page Program"), .cmdCode('h32), .withAddr(0), .with2Addr(0), .with4Addr(1))
                        
        CUIDEC_programQuadQuad (!busy && WriteAccessOn && protocol=="quad");


  CUIdecoder   

      #(.cmdName("Quad Extended Program"), .cmdCode('h12), .withAddr(0), .with2Addr(0), .with4Addr(1))
                        
        CUIDEC_programQuadExtended (!busy && WriteAccessOn && protocol=="extended");

 CUIdecoder   

      #(.cmdName("Quad Command Page Program"), .cmdCode('h12), .withAddr(0), .with2Addr(0), .with4Addr(1))
                        
        CUIDEC_programQuadExtendedQuad (!busy && WriteAccessOn && protocol=="quad");


  CUIdecoder   

        #(.cmdName("Program Erase Resume"), .cmdCode('h7A), .withAddr(0), .with2Addr(0), .with4Addr(0))
                                
        CUIDEC_programEraseResume (WriteAccessOn);
                                        


 CUIdecoder   

         #(.cmdName("Program Erase Suspend"), .cmdCode('h75), .withAddr(0), .with2Addr(0), .with4Addr(0))
                                         
         CUIDEC_programEraseSuspend (WriteAccessOn);
                                                                                         
                                                                                         
                                                  



