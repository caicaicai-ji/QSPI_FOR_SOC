/*
    Copyright (c) 2018 SMIC
    Filename:      qspi_data_info_32_mem.v
    IP code :      S55NLLG2PH
    Version:       1.1.0
    CreateDate:    Oct 28, 2018

    Verilog Model for General 2-PORT SRAM
    SMIC 55nm LL Logic Process

    Configuration: -instname qspi_data_info_32_mem -rows 64 -bits 32 -mux 1 
    Redundancy: Off
    Bit-Write: Off
*/

/* DISCLAIMER                                                                      */
/*                                                                                 */  
/*   SMIC hereby provides the quality information to you but makes no claims,      */
/* promises or guarantees about the accuracy, completeness, or adequacy of the     */
/* information herein. The information contained herein is provided on an "AS IS"  */
/* basis without any warranty, and SMIC assumes no obligation to provide support   */
/* of any kind or otherwise maintain the information.                              */  
/*   SMIC disclaims any representation that the information does not infringe any  */
/* intellectual property rights or proprietary rights of any third parties. SMIC   */
/* makes no other warranty, whether express, implied or statutory as to any        */
/* matter whatsoever, including but not limited to the accuracy or sufficiency of  */
/* any information or the merchantability and fitness for a particular purpose.    */
/* Neither SMIC nor any of its representatives shall be liable for any cause of    */
/* action incurred to connect to this service.                                     */  
/*                                                                                 */
/* STATEMENT OF USE AND CONFIDENTIALITY                                            */  
/*                                                                                 */  
/*   The following/attached material contains confidential and proprietary         */  
/* information of SMIC. This material is based upon information which SMIC         */  
/* considers reliable, but SMIC neither represents nor warrants that such          */
/* information is accurate or complete, and it must not be relied upon as such.    */
/* This information was prepared for informational purposes and is for the use     */
/* by SMIC's customer only. SMIC reserves the right to make changes in the         */  
/* information at any time without notice.                                         */  
/*   No part of this information may be reproduced, transmitted, transcribed,      */  
/* stored in a retrieval system, or translated into any human or computer          */ 
/* language, in any form or by any means, electronic, mechanical, magnetic,        */  
/* optical, chemical, manual, or otherwise, without the prior written consent of   */
/* SMIC. Any unauthorized use or disclosure of this material is strictly           */  
/* prohibited and may be unlawful. By accepting this material, the receiving       */  
/* party shall be deemed to have acknowledged, accepted, and agreed to be bound    */
/* by the foregoing limitations and restrictions. Thank you.                       */  
/*                                                                                 */  

`timescale 1ns/1ps
`celldefine

module qspi_data_info_32_mem (
                          QA,
			  CLKA,
			  CLKB,
			  CENA,
			  CENB,
			  AA,
			  AB,
			  DB);

  parameter	Bits = 32;
  parameter	Word_Depth = 64;
  parameter	Add_Width = 6;

  output [Bits-1:0]     QA;
  input                 CLKA;
  input                 CLKB;
  input                 CENA;
  input                 CENB;
  input	[Add_Width-1:0] AA;
  input	[Add_Width-1:0] AB;
  input	[Bits-1:0]      DB;


  wire [Bits-1:0]      QA_int;
  wire [Add_Width-1:0] AA_int;
  wire [Add_Width-1:0] AB_int;
  wire                 CLKA_int;
  wire                 CLKB_int;
  wire                 CENA_int;
  wire                 CENB_int;
  wire [Bits-1:0]      DB_int;

  reg  [Bits-1:0]       QA_latched;
  reg  [Add_Width-1:0]  AA_latched;
  reg  [Add_Width-1:0]  AB_latched;
  reg  [Bits-1:0]       DB_latched;
  reg                   CENA_latched;
  reg                   CENB_latched;
  reg                   LAST_CLKA;
  reg                   LAST_CLKB;
  reg 			AA0_flag;
  reg 			AA1_flag;
  reg 			AA2_flag;
  reg 			AA3_flag;
  reg 			AA4_flag;
  reg 			AA5_flag;
  reg 			AB0_flag;
  reg 			AB1_flag;
  reg 			AB2_flag;
  reg 			AB3_flag;
  reg 			AB4_flag;
  reg 			AB5_flag;
  reg                     CENA_flag;
  reg                     CENB_flag;
  reg                     CLKA_CYC_flag;
  reg                     CLKB_CYC_flag;
  reg                     CLKA_H_flag;
  reg                     CLKB_H_flag;
  reg                     CLKA_L_flag;
  reg                     CLKB_L_flag;
  reg                     DB0_flag;
  reg                     DB1_flag;
  reg                     DB2_flag;
  reg                     DB3_flag;
  reg                     DB4_flag;
  reg                     DB5_flag;
  reg                     DB6_flag;
  reg                     DB7_flag;
  reg                     DB8_flag;
  reg                     DB9_flag;
  reg                     DB10_flag;
  reg                     DB11_flag;
  reg                     DB12_flag;
  reg                     DB13_flag;
  reg                     DB14_flag;
  reg                     DB15_flag;
  reg                     DB16_flag;
  reg                     DB17_flag;
  reg                     DB18_flag;
  reg                     DB19_flag;
  reg                     DB20_flag;
  reg                     DB21_flag;
  reg                     DB22_flag;
  reg                     DB23_flag;
  reg                     DB24_flag;
  reg                     DB25_flag;
  reg                     DB26_flag;
  reg                     DB27_flag;
  reg                     DB28_flag;
  reg                     DB29_flag;
  reg                     DB30_flag;
  reg                     DB31_flag;

  reg			  A_flag;
  reg			  B_flag;
  reg                     VIOA_flag;
  reg                     VIOB_flag;
  reg                     LAST_VIOA_flag;
  reg                     LAST_VIOB_flag;


  reg [Add_Width-1:0]     AA_flag;
  reg [Add_Width-1:0]     AB_flag;
  reg [Bits-1:0]          DB_flag;
  reg                     LAST_CENA_flag;
  reg                     LAST_CENB_flag;
  reg [Add_Width-1:0]     LAST_AA_flag;
  reg [Add_Width-1:0]     LAST_AB_flag;
  reg [Bits-1:0]          LAST_DB_flag;

  reg                      LAST_CLKA_CYC_flag;
  reg                      LAST_CLKB_CYC_flag;
  reg                      LAST_CLKA_H_flag;
  reg                      LAST_CLKB_H_flag;
  reg                      LAST_CLKA_L_flag;
  reg                      LAST_CLKB_L_flag;

  wire                    CEA_flag;
  wire                    CEB_flag;
  wire	 		  clkconfA_flag;
  wire			  clkconfB_flag;
  wire			  clkconf_flag;

  reg    [Bits-1:0] mem_array[Word_Depth-1:0];

  integer      i;
  integer      n;

  buf dout_buf[Bits-1:0] (QA, QA_int);
  buf (CLKA_int, CLKA);
  buf (CLKB_int, CLKB);
  buf (CENA_int, CENA);
  buf (CENB_int, CENB);
  buf aa_buf[Add_Width-1:0] (AA_int, AA);
  buf ab_buf[Add_Width-1:0] (AB_int, AB);
  buf din_buf[Bits-1:0] (DB_int, DB);   

  assign QA_int=QA_latched;
  assign CEA_flag=!CENA_int;
  assign CEB_flag=!CENB_int;
  assign clkconfA_flag=(AA_int===AB_latched) && (CENA_int!==1'b1) && 
(CENB_latched!==1'b1);
  assign clkconfB_flag=(AB_int===AA_latched) && (CENB_int!==1'b1) && 
(CENA_latched!==1'b1);
  assign clkconf_flag=(AA_int===AB_int) && (CENA_int!==1'b1) && (CENB_int!==1'b1);

  always @(CLKA_int)
    begin
      casez({LAST_CLKA, CLKA_int})
        2'b01: begin
          CENA_latched = CENA_int;
          AA_latched = AA_int;
          rw_memA;
        end
        2'b10,
        2'bx?,
        2'b00,
        2'b11: ;
        2'b?x: begin
	  for(i=0;i<Word_Depth;i=i+1)
    	    mem_array[i]={Bits{1'bx}};
    	  QA_latched={Bits{1'bx}};
          rw_memA;
          end
      endcase
    LAST_CLKA=CLKA_int;
   end

  always @(CLKB_int)
    begin
      casez({LAST_CLKB, CLKB_int})
        2'b01: begin
          CENB_latched = CENB_int;
          AB_latched = AB_int;
          DB_latched = DB_int;
          rw_memB;
        end
        2'b10,
        2'bx?,
        2'b00,
        2'b11: ;
        2'b?x: begin
          for(i=0;i<Word_Depth;i=i+1)
            mem_array[i]={Bits{1'bx}};
          rw_memA;
          end
      endcase
    LAST_CLKB=CLKB_int;
   end


  always @(CENA_flag
           or AA0_flag
           or AA1_flag
           or AA2_flag
           or AA3_flag
           or AA4_flag
           or AA5_flag
           or CLKA_CYC_flag
           or CLKA_H_flag
           or CLKA_L_flag
           or VIOA_flag)
    begin
      update_flag_busA;
      CENA_latched = (CENA_flag!==LAST_CENA_flag) ? 1'bx : CENA_latched ;
      for (n=0; n<Add_Width; n=n+1)
      AA_latched[n] = (AA_flag[n]!==LAST_AA_flag[n]) ? 1'bx : AA_latched[n] ;
      LAST_CENA_flag = CENA_flag;
      LAST_AA_flag = AA_flag;
      LAST_CLKA_CYC_flag = CLKA_CYC_flag;
      LAST_CLKA_H_flag = CLKA_H_flag;
      LAST_CLKA_L_flag = CLKA_L_flag;
      if(VIOA_flag!==LAST_VIOA_flag)
        begin
          if(B_flag===1'b0)
            QA_latched={Bits{1'bx}};
          LAST_VIOA_flag=VIOA_flag;
        end
      else
        rw_memA;
   end
      
  always @(CENB_flag
           or AB0_flag
           or AB1_flag
           or AB2_flag
           or AB3_flag
           or AB4_flag
           or AB5_flag
           or DB0_flag
           or DB1_flag
           or DB2_flag
           or DB3_flag
           or DB4_flag
           or DB5_flag
           or DB6_flag
           or DB7_flag
           or DB8_flag
           or DB9_flag
           or DB10_flag
           or DB11_flag
           or DB12_flag
           or DB13_flag
           or DB14_flag
           or DB15_flag
           or DB16_flag
           or DB17_flag
           or DB18_flag
           or DB19_flag
           or DB20_flag
           or DB21_flag
           or DB22_flag
           or DB23_flag
           or DB24_flag
           or DB25_flag
           or DB26_flag
           or DB27_flag
           or DB28_flag
           or DB29_flag
           or DB30_flag
           or DB31_flag
           or CLKB_CYC_flag
           or CLKB_H_flag
           or CLKB_L_flag
           or VIOB_flag)
    begin
      update_flag_busB;
      CENB_latched = (CENB_flag!==LAST_CENB_flag) ? 1'bx : CENB_latched ;
      for (n=0; n<Add_Width; n=n+1)
      AB_latched[n] = (AB_flag[n]!==LAST_AB_flag[n]) ? 1'bx : AB_latched[n] ;
      for (n=0; n<Bits; n=n+1)
      DB_latched[n] = (DB_flag[n]!==LAST_DB_flag[n]) ? 1'bx : DB_latched[n] ;
      LAST_CENB_flag = CENB_flag;
      LAST_AB_flag = AB_flag;
      LAST_DB_flag = DB_flag;
      LAST_CLKB_CYC_flag = CLKB_CYC_flag;
      LAST_CLKB_H_flag = CLKB_H_flag;
      LAST_CLKB_L_flag = CLKB_L_flag;
      if(VIOB_flag!==LAST_VIOB_flag)
        begin
          if(A_flag===1'b1)
            QA_latched={Bits{1'bx}};
          LAST_VIOB_flag=VIOB_flag;
        end
      else
        rw_memB;
   end

  task rw_memA;
    begin
      A_flag=1'bx;
      if(CENA_latched==1'b0)
        begin
          A_flag=1;
          if(^(AA_latched)==1'bx)
            QA_latched={Bits{1'bx}};
          else
	    QA_latched=mem_array[AA_latched];
        end
      else if(CENA_latched===1'bx)
        begin
          A_flag=1;
   	  QA_latched={Bits{1'bx}};
        end
    end
  endtask
      
  task rw_memB;
    begin
      B_flag=1'bx;
      if(CENB_latched==1'b0)
        begin
          B_flag=0;
   	  if(^(AB_latched)==1'bx)
            x_mem;
   	  else
   	    mem_array[AB_latched]=DB_latched;
        end
      else if(CENB_latched===1'bx)
        begin
          B_flag=0;
          if(^(AB_latched)===1'bx)
            x_mem;
          else
	   mem_array[AB_latched]={Bits{1'bx}};
        end
    end
  endtask

   task x_mem;
   begin
     for(i=0;i<Word_Depth;i=i+1)
     mem_array[i]={Bits{1'bx}};
   end
   endtask

  task update_flag_busA;
  begin
    AA_flag = {
             AA5_flag,
             AA4_flag,
             AA3_flag,
             AA2_flag,
             AA1_flag,
             AA0_flag};
   end
   endtask

  task update_flag_busB;
  begin
    AB_flag = {
             AB5_flag,
             AB4_flag,
             AB3_flag,
             AB2_flag,
             AB1_flag,
             AB0_flag};
    DB_flag = {
             DB31_flag,
             DB30_flag,
             DB29_flag,
             DB28_flag,
             DB27_flag,
             DB26_flag,
             DB25_flag,
             DB24_flag,
             DB23_flag,
             DB22_flag,
             DB21_flag,
             DB20_flag,
             DB19_flag,
             DB18_flag,
             DB17_flag,
             DB16_flag,
             DB15_flag,
             DB14_flag,
             DB13_flag,
             DB12_flag,
             DB11_flag,
             DB10_flag,
             DB9_flag,
             DB8_flag,
             DB7_flag,
             DB6_flag,
             DB5_flag,
             DB4_flag,
             DB3_flag,
             DB2_flag,
             DB1_flag,
             DB0_flag};
   end
   endtask


  specify
    (posedge CLKA => (QA[0] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[1] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[2] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[3] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[4] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[5] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[6] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[7] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[8] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[9] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[10] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[11] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[12] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[13] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[14] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[15] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[16] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[17] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[18] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[19] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[20] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[21] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[22] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[23] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[24] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[25] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[26] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[27] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[28] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[29] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[30] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[31] : 1'bx))=(1.000,1.000);

    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[0],0.500,0.250,AA0_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[0],0.500,0.250,AA0_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[1],0.500,0.250,AA1_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[1],0.500,0.250,AA1_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[2],0.500,0.250,AA2_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[2],0.500,0.250,AA2_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[3],0.500,0.250,AA3_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[3],0.500,0.250,AA3_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[4],0.500,0.250,AA4_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[4],0.500,0.250,AA4_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[5],0.500,0.250,AA5_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[5],0.500,0.250,AA5_flag);

    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[0],0.500,0.250,AB0_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[0],0.500,0.250,AB0_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[1],0.500,0.250,AB1_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[1],0.500,0.250,AB1_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[2],0.500,0.250,AB2_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[2],0.500,0.250,AB2_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[3],0.500,0.250,AB3_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[3],0.500,0.250,AB3_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[4],0.500,0.250,AB4_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[4],0.500,0.250,AB4_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[5],0.500,0.250,AB5_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[5],0.500,0.250,AB5_flag);

    $setuphold(posedge CLKA,posedge CENA,0.500,0.250,CENA_flag);
    $setuphold(posedge CLKA,negedge CENA,0.500,0.250,CENA_flag);
    $period(posedge CLKA,0.993,CLKA_CYC_flag);
    $width(posedge CLKA,0.298,0,CLKA_H_flag);
    $width(negedge CLKA,0.298,0,CLKA_L_flag);

    $setuphold(posedge CLKB,posedge CENB,0.500,0.250,CENB_flag);
    $setuphold(posedge CLKB,negedge CENB,0.500,0.250,CENB_flag);
    $period(posedge CLKB,0.993,CLKB_CYC_flag);
    $width(posedge CLKB,0.298,0,CLKB_H_flag);
    $width(negedge CLKB,0.298,0,CLKB_L_flag);

    $setup(posedge CLKA,posedge CLKB &&& clkconfB_flag,1.000,VIOB_flag);
    $hold(posedge CLKA,posedge CLKB &&& clkconf_flag,0.010,VIOB_flag);
    $setup(posedge CLKB,posedge CLKA &&& clkconfA_flag,1.000,VIOA_flag);
    $hold(posedge CLKB,posedge CLKA &&& clkconf_flag,0.010,VIOA_flag);

    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[0],0.500,0.250,DB0_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[0],0.500,0.250,DB0_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[1],0.500,0.250,DB1_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[1],0.500,0.250,DB1_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[2],0.500,0.250,DB2_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[2],0.500,0.250,DB2_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[3],0.500,0.250,DB3_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[3],0.500,0.250,DB3_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[4],0.500,0.250,DB4_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[4],0.500,0.250,DB4_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[5],0.500,0.250,DB5_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[5],0.500,0.250,DB5_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[6],0.500,0.250,DB6_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[6],0.500,0.250,DB6_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[7],0.500,0.250,DB7_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[7],0.500,0.250,DB7_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[8],0.500,0.250,DB8_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[8],0.500,0.250,DB8_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[9],0.500,0.250,DB9_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[9],0.500,0.250,DB9_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[10],0.500,0.250,DB10_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[10],0.500,0.250,DB10_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[11],0.500,0.250,DB11_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[11],0.500,0.250,DB11_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[12],0.500,0.250,DB12_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[12],0.500,0.250,DB12_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[13],0.500,0.250,DB13_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[13],0.500,0.250,DB13_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[14],0.500,0.250,DB14_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[14],0.500,0.250,DB14_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[15],0.500,0.250,DB15_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[15],0.500,0.250,DB15_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[16],0.500,0.250,DB16_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[16],0.500,0.250,DB16_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[17],0.500,0.250,DB17_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[17],0.500,0.250,DB17_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[18],0.500,0.250,DB18_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[18],0.500,0.250,DB18_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[19],0.500,0.250,DB19_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[19],0.500,0.250,DB19_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[20],0.500,0.250,DB20_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[20],0.500,0.250,DB20_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[21],0.500,0.250,DB21_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[21],0.500,0.250,DB21_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[22],0.500,0.250,DB22_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[22],0.500,0.250,DB22_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[23],0.500,0.250,DB23_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[23],0.500,0.250,DB23_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[24],0.500,0.250,DB24_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[24],0.500,0.250,DB24_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[25],0.500,0.250,DB25_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[25],0.500,0.250,DB25_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[26],0.500,0.250,DB26_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[26],0.500,0.250,DB26_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[27],0.500,0.250,DB27_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[27],0.500,0.250,DB27_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[28],0.500,0.250,DB28_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[28],0.500,0.250,DB28_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[29],0.500,0.250,DB29_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[29],0.500,0.250,DB29_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[30],0.500,0.250,DB30_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[30],0.500,0.250,DB30_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge DB[31],0.500,0.250,DB31_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge DB[31],0.500,0.250,DB31_flag);
  endspecify

endmodule

`endcelldefine