# See LICENSE for license details.

`timescale 1ps/1ps

`define AXI4
`define BUS_WIDTH 128
`define MEM_AWIDTH 32
`define X128


`define QSPI_INST_WIDTH 8
`define QSPI_ADDR_WIDTH 24

//IS25LP128 Flash Chip Instruction Set
`ifdef IS25LP128 
`define  PP		8'h02		//Page Program
`define  FRQIO		8'h0B		//Fast Read Quad IO
`define  SER		8'h20		//Sector Erase
`define  BER32		8'h52		//Block Erase(32KByte)	
`define  BER64		8'hd8		//block Erase(64KByte)
`define  CER		8'h60		//Chip Erase
`define  WREN		8'h06		//Write Enable
`define  WRDI		8'h04		//Write Disable
`define  RDSR		8'h05		//Read Status Register 
`define  WRSR		8'h01		//Write Status Register
`define  RDFR		8'h48		//Read Function Register
`define  WRFR		8'h42		//Write Function Register
`define  QPIEN		8'h35		//Enter QPI Mode 
`define  QPIDI		8'hF5		//Exit  QPI Mode
`define  DPIEN		8'h35		//Enter DPI Mode
`define  DPIDI		8'hF5		//Exit  DPI Mode
`endif
//QSPI Controlor FSM STATE
//parameter START		=	4'b0000;  //0
//parameter EQPI		=	4'b0001;  //1
//parameter WEN		=	4'b0010;  //2
`ifdef N25Q128
`define  PP             8'h02           //Page Program
`define  FRQIO          8'hEB           //Fast Read Quad IO
`define  SER            8'h20           //Sector Erase
`define  BER32          8'hd8           //Block Erase(32KByte)
`define  BER64          8'hd8         //block Erase(64KByte)
`define  CER            8'hc7           //Chip Erase
`define  WREN           8'h06           //Write Enable
`define  WRDI           8'h04           //Write Disable

`define  RDSR           8'h05           //Read Status Register
`define  WRSR           8'h01           //Write Status Register
`define  RDLR           8'h48           //Read L Register
`define  WRLR           8'h42           //Write L Register
`define  RDFSR		8'h70
`define  WRFSR		8'h50		//Clear the fsr
`define  WRVECR		8'h61
`define  RDVECR		8'h65		

`define  QPIEN          8'h61           //Enter QPI Mode
`define  QPIDI          8'h61           //Exit  QPI Mode
`define  DPIEN		8'h61		//Enter DPI Mode 
`define  DPIDI		8'h61		//Exit  DPI Mode		
`endif


