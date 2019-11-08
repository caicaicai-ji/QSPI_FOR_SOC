# See LICENSE for license details.

module qspi_cchan_inst_gen(
	clock,
	rst_n,

	
// from ahb if
	io_flash_state_csr ,
//cchan ctrl signal 
//qspi ctrl mode
//	0:normal mode
//	1:program mode
	io_qspi_ctrl_mode,
	io_pmode_start,
	io_pmode_start_clr,
	io_pmode_inst,
	io_pmode_addr,
	io_pmode_size,

 
	io_cchan_edpi,
	io_cchan_dpidi,
	io_cchan_eqpi,
	io_cchan_qpidi,
	io_cchan_cer,
	io_cchan_ber32,
	io_cchan_ber64,
	io_cchan_ser,
	io_cchan_wrcsr,
	io_cchan_rdcsr,
	io_cchan_edpi_clr,
	io_cchan_dpidi_clr,
	io_cchan_eqpi_clr,
	io_cchan_qpidi_clr,
	io_cchan_cer_clr,
	io_cchan_ber32_clr,
	io_cchan_ber64_clr,
	io_cchan_ser_clr,
	io_cchan_wrcsr_clr,
	io_cchan_rdcsr_clr,
// to control level 
        io_cchan_req_valid,
        io_cchan_req_ready,
        io_cchan_req_data_size,
        io_cchan_req_data_burstlen,
        io_cchan_req_inst,
        io_cchan_req_addr

	);
input clock;
input rst_n;
input [1:0] io_flash_state_csr ;

//cchan ctrl signal
//qspi ctrl mode
//      0:normal mode
//      1:program mode
input        io_qspi_ctrl_mode;
input        io_pmode_start;
output        io_pmode_start_clr;
input  [7:0] io_pmode_inst;
input  [23:0] io_pmode_addr;
input  [7:0]  io_pmode_size;





input io_cchan_edpi;
input io_cchan_dpidi;
input io_cchan_eqpi;
input io_cchan_qpidi;
input io_cchan_cer;
input io_cchan_ber32;
input io_cchan_ber64;
input io_cchan_ser;
input io_cchan_wrcsr;
input io_cchan_rdcsr;
output io_cchan_edpi_clr;
output io_cchan_dpidi_clr;
output io_cchan_eqpi_clr;
output io_cchan_qpidi_clr;
output io_cchan_cer_clr;
output io_cchan_ber32_clr;
output io_cchan_ber64_clr;
output io_cchan_ser_clr;
output io_cchan_wrcsr_clr;
output io_cchan_rdcsr_clr;

output  io_cchan_req_valid;
input   io_cchan_req_ready;
output [7:0] io_cchan_req_data_size;
output [7:0] io_cchan_req_data_burstlen;
output [7:0] io_cchan_req_inst;
output [23:0] io_cchan_req_addr;



reg  cchan_nop_reg;
wire cchan_nop_pre;


assign io_cchan_req_valid = ~cchan_nop_reg & ~io_qspi_ctrl_mode & ( io_cchan_eqpi | 
						   io_cchan_qpidi | io_cchan_cer | 
						   io_cchan_ber32 | io_cchan_ber64 | 
						   io_cchan_ser | io_cchan_edpi | 
						   io_cchan_dpidi | io_cchan_wrcsr | 
						   io_cchan_rdcsr ) |  
			    io_qspi_ctrl_mode & io_pmode_start  ;
wire [7:0] inst_wrcsr ;
wire [7:0] inst_rdcsr ;

`ifdef N25Q128 
	assign inst_wrcsr = io_flash_state_csr == 2'b00 ? `WRSR :
			    io_flash_state_csr == 2'b01 ? `WRLR :
			    io_flash_state_csr == 2'b10 ? `WRFSR:
				`WRVECR ;
	assign inst_rdcsr = io_flash_state_csr == 2'b00 ? `RDSR :
			    io_flash_state_csr == 2'b01 ? `RDLR :
			    io_flash_state_csr == 2'b10 ? `RDFSR:
			       	`RDVECR ; 
`endif
`ifdef IS25LP128
	assign inst_wrcsr = io_flash_state_csr == 2'b00 ? `WRSR : 
			    io_flash_state_csr == 2'b01 ? `WRFR :
			    8'b00;
	assign inst_rdcsr = io_flash_state_csr == 2'b00 ? `RDSR :
			    io_flash_state_csr == 2'b01 ? `RDFR :
			    8'b00;
`endif
assign io_cchan_req_inst =  io_qspi_ctrl_mode ? io_pmode_inst : 
			    io_cchan_edpi   	?       `DPIEN   :
			    io_cchan_dpidi   	?       `DPIDI   :
			    io_cchan_eqpi   	?       `QPIEN  :
			    io_cchan_qpidi  	?       `QPIDI  :
			    io_cchan_cer  	? 	`CER	:
			    io_cchan_ber32	?	`BER32	:
			    io_cchan_ber64	?	`BER64	:
			    io_cchan_ser	?	`SER	:
			    io_cchan_rdcsr	?	inst_rdcsr	:
			    io_cchan_wrcsr      ?       inst_wrcsr      :
			    8'b0;

assign io_cchan_req_addr = io_pmode_addr ;

// cchan data sizes 
//	edpi/dpidi/wrcsr/rdcsr : 1Byte
//	default: 4 Byte
assign io_cchan_req_data_size =  8'h2 ;
assign io_cchan_req_data_burstlen = io_pmode_size;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		cchan_nop_reg <= 1'b1 ;
	else
		cchan_nop_reg <= cchan_nop_pre;
assign cchan_nop_pre = cchan_nop_reg ? 1'b0 :
		       cchan_nop_reg ;

wire clr_en;

wire  cchan_edpi_clr;
wire  cchan_dpidi_clr;
wire  cchan_eqpi_clr ;
wire  cchan_qpidi_clr;
wire  cchan_cer_clr;
wire  cchan_ber32_clr;
wire  cchan_ber64_clr;
wire  cchan_ser_clr;
wire  cchan_wrcsr_clr;
wire  cchan_rdcsr_clr;

wire  cchan_edpi_clr_n;
wire  cchan_dpidi_clr_n;
wire  cchan_eqpi_clr_n ;
wire  cchan_qpidi_clr_n;
wire  cchan_cer_clr_n;
wire  cchan_ber32_clr_n;
wire  cchan_ber64_clr_n;
wire  cchan_ser_clr_n;
wire  cchan_wrcsr_clr_n;
wire  cchan_rdcsr_clr_n;
assign  clr_en = io_cchan_req_ready & ~io_qspi_ctrl_mode & ~cchan_nop_reg;



assign  cchan_edpi_clr          =       io_cchan_edpi;
assign  cchan_edpi_clr_n        =       ~cchan_edpi_clr;

assign  cchan_dpidi_clr          =       io_cchan_dpidi;
assign  cchan_dpidi_clr_n        =       ~cchan_dpidi_clr;

assign  cchan_eqpi_clr          =       io_cchan_eqpi;
assign  cchan_eqpi_clr_n        =       ~cchan_eqpi_clr;

assign  cchan_qpidi_clr          =       io_cchan_qpidi;
assign  cchan_qpidi_clr_n        =       ~cchan_qpidi_clr;

assign  cchan_cer_clr		=	io_cchan_cer;
assign  cchan_cer_clr_n		=	~cchan_cer_clr;

assign  cchan_ber32_clr		=	io_cchan_ber32;	
assign  cchan_ber32_clr_n	=	~cchan_ber32_clr;

assign  cchan_ber64_clr		=	io_cchan_ber64;
assign  cchan_ber64_clr_n	= 	~cchan_ber64_clr;

assign  cchan_ser_clr		=	io_cchan_ser;
assign  cchan_ser_clr_n		=	~cchan_ser_clr;

assign  cchan_rdcsr_clr         =       io_cchan_rdcsr;
assign  cchan_rdcsr_clr_n       =       ~cchan_rdcsr_clr;

assign  cchan_wrcsr_clr		=	io_cchan_wrcsr;
assign  cchan_wrcsr_clr_n	=	~io_cchan_wrcsr_clr;


wire 	level_1_clr;
wire    level_2_clr;
wire    level_3_clr;
wire    level_4_clr;
wire    level_5_clr;
wire    level_6_clr;
wire    level_7_clr;
wire 	level_8_clr;
wire	level_9_clr;

assign    level_1_clr           =       cchan_edpi_clr_n;
assign    level_2_clr           =       level_1_clr & cchan_dpidi_clr_n;
assign    level_3_clr           =       level_2_clr & cchan_eqpi_clr_n;
assign    level_4_clr           =       level_3_clr & cchan_qpidi_clr_n;
assign    level_5_clr		=	level_4_clr & cchan_cer_clr_n;	
assign    level_6_clr		=	level_5_clr & cchan_ber32_clr_n;	
assign    level_7_clr		=	level_6_clr & cchan_ber64_clr_n;
assign    level_8_clr		=	level_7_clr & cchan_ser_clr_n;
assign    level_9_clr		=	level_8_clr & cchan_rdcsr_clr_n;	

assign  io_cchan_edpi_clr       =       cchan_edpi_clr  & clr_en;
assign  io_cchan_dpidi_clr      =       cchan_dpidi_clr &       level_1_clr   & clr_en; 
assign  io_cchan_eqpi_clr	=	cchan_eqpi_clr 	& 	level_2_clr	& clr_en;	
assign  io_cchan_qpidi_clr      =       cchan_qpidi_clr &       level_3_clr     & clr_en;
assign  io_cchan_cer_clr	=	cchan_cer_clr  	& 	level_4_clr	& clr_en; 	
assign  io_cchan_ber32_clr	=	cchan_ber32_clr	&	level_5_clr	& clr_en;
assign  io_cchan_ber64_clr	=	cchan_ber64_clr	&	level_6_clr	& clr_en;
assign  io_cchan_ser_clr	=	cchan_ser_clr	&	level_7_clr	& clr_en;
assign  io_cchan_rdcsr_clr	=	cchan_rdcsr_clr	&	level_8_clr	& clr_en;
assign  io_cchan_wrcsr_clr	=	cchan_wrcsr_clr  &	level_9_clr	& clr_en;	

assign  io_pmode_start_clr = io_pmode_start & io_qspi_ctrl_mode & io_cchan_req_ready ;
	
`ifdef QSPI_SIM
////////////////////////////////////////
//Verification Plan
//	1.Assertion the unique op in normal mode 
//		focus on signal:io_cchan_*_clr
//	2.Trace the Inst Stream in Cchan 
//		store at file qspi_cchan_inst_steam.log

integer steam_log;
initial begin 
	steam_log = $fopen("../sim_log/qspi_cchan_inst_steam.log");
end
//1.Assertion the unique op in normal mode
property cchan_req ;
	@(posedge clock )
	(rst_n == 1) && (io_cchan_edpi_clr|| io_cchan_dpidi_clr || io_cchan_eqpi_clr || io_cchan_qpidi_clr || io_cchan_cer_clr || io_cchan_ber32_clr || io_cchan_ber64_clr || io_cchan_ser_clr || io_cchan_rdcsr_clr || io_cchan_wrcsr_clr || io_pmode_start_clr) |->
	(io_cchan_edpi_clr==1) && 
            (io_cchan_dpidi_clr == 0) && (io_cchan_eqpi_clr == 0) && 
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_cer_clr == 0) && 
            (io_cchan_ber32_clr == 0 ) && (io_cchan_ber64_clr == 0 ) && 
            (io_cchan_ser_clr==0) && (io_cchan_rdcsr_clr == 0) && 
            (io_cchan_wrcsr_clr == 0 ) && (io_pmode_start_clr == 0) || 
        (io_cchan_dpidi_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_eqpi_clr == 0) &&
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_cer_clr == 0) &&
            (io_cchan_ber32_clr == 0 ) && (io_cchan_ber64_clr == 0 ) &&
            (io_cchan_ser_clr==0) && (io_cchan_rdcsr_clr == 0) &&
            (io_cchan_wrcsr_clr == 0 ) && (io_pmode_start_clr == 0) ||        
        (io_cchan_eqpi_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_dpidi_clr == 0) &&
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_cer_clr == 0) &&
            (io_cchan_ber32_clr == 0 ) && (io_cchan_ber64_clr == 0 ) &&
            (io_cchan_ser_clr==0) && (io_cchan_rdcsr_clr == 0) &&
            (io_cchan_wrcsr_clr == 0 ) && (io_pmode_start_clr == 0) ||
        (io_cchan_qpidi_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_eqpi_clr == 0) &&
            (io_cchan_dpidi_clr== 0 ) && (io_cchan_cer_clr == 0) &&
            (io_cchan_ber32_clr == 0 ) && (io_cchan_ber64_clr == 0 ) &&
            (io_cchan_ser_clr==0) && (io_cchan_rdcsr_clr == 0) &&
            (io_cchan_wrcsr_clr == 0 ) && (io_pmode_start_clr == 0) ||
        (io_cchan_cer_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_eqpi_clr == 0) &&
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_dpidi_clr == 0) &&
            (io_cchan_ber32_clr == 0 ) && (io_cchan_ber64_clr == 0 ) &&
            (io_cchan_ser_clr==0) && (io_cchan_rdcsr_clr == 0) &&
            (io_cchan_wrcsr_clr == 0 ) && (io_pmode_start_clr == 0) ||
        (io_cchan_ber32_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_eqpi_clr == 0) &&
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_cer_clr == 0) &&
            (io_cchan_dpidi_clr == 0 ) && (io_cchan_ber64_clr == 0 ) &&
            (io_cchan_ser_clr==0) && (io_cchan_rdcsr_clr == 0) &&
            (io_cchan_wrcsr_clr == 0 ) && (io_pmode_start_clr == 0) ||
        (io_cchan_ber64_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_eqpi_clr == 0) &&
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_cer_clr == 0) &&
            (io_cchan_ber32_clr == 0 ) && (io_cchan_dpidi_clr == 0 ) &&
            (io_cchan_ser_clr==0) && (io_cchan_rdcsr_clr == 0) &&
            (io_cchan_wrcsr_clr == 0 ) && (io_pmode_start_clr == 0) ||
        (io_cchan_ser_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_eqpi_clr == 0) &&
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_cer_clr == 0) &&
            (io_cchan_ber32_clr == 0 ) && (io_cchan_ber64_clr == 0 ) &&
            (io_cchan_dpidi_clr==0) && (io_cchan_rdcsr_clr == 0) &&
            (io_cchan_wrcsr_clr == 0 ) && (io_pmode_start_clr == 0) ||
        (io_cchan_rdcsr_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_eqpi_clr == 0) &&
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_cer_clr == 0) &&
            (io_cchan_ber32_clr == 0 ) && (io_cchan_ber64_clr == 0 ) &&
            (io_cchan_ser_clr==0) && (io_cchan_dpidi_clr == 0) &&
            (io_cchan_wrcsr_clr == 0 ) && (io_pmode_start_clr == 0) ||
        (io_cchan_wrcsr_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_eqpi_clr == 0) &&
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_cer_clr == 0) &&
            (io_cchan_ber32_clr == 0 ) && (io_cchan_ber64_clr == 0 ) &&
            (io_cchan_ser_clr==0) && (io_cchan_rdcsr_clr == 0) &&
            (io_cchan_dpidi_clr == 0 ) && (io_pmode_start_clr == 0) ||
        (io_pmode_start_clr == 1) &&
            (io_cchan_edpi_clr == 0) && (io_cchan_eqpi_clr == 0) &&
            (io_cchan_qpidi_clr== 0 ) && (io_cchan_cer_clr == 0) &&
            (io_cchan_ber32_clr == 0 ) && (io_cchan_ber64_clr == 0 ) &&
            (io_cchan_ser_clr==0) && (io_cchan_rdcsr_clr == 0) &&
            (io_cchan_wrcsr_clr == 0 ) && (io_cchan_dpidi_clr == 0) ;
endproperty

assert_cchan_req:assert property(cchan_req)  else 
begin
	$display("at qspi_cchan_inst_gen.v:line 337,false for assert unique cchan req");
	$stop;
end

cover_cchan_req:cover property(cchan_req) ;

//2.Trace the Inst Stream in Cchan
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		;
	else begin
	if( io_cchan_req_ready & io_cchan_req_valid) 
		$fwrite(steam_log,"==TIME:%0dns==\t",$time);
	if(io_cchan_edpi_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==EDPI==");
	else if(io_cchan_dpidi_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==DPIDI==");
	else if(io_cchan_eqpi_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==EQPI==");
	else if(io_cchan_qpidi_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==QPIDI==");
	else if(io_cchan_cer_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==CER==");
	else if(io_cchan_ber32_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==BER32==");
	else if(io_cchan_ber64_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==BER64==");	
	else if(io_cchan_ser_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==SER==");
	else if(io_cchan_rdcsr_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==RDCSR==");
	else if(io_cchan_wrcsr_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==WRCSR==");
	else if(io_pmode_start_clr & io_cchan_req_ready)
		$fwrite(steam_log,"==PMODE==");	
	if ( io_cchan_req_ready & io_cchan_req_valid)
        	$fwrite(steam_log,"Inst:[%h],Addr[%h],DataSize[%d],DataBurstlen[%d]\n",io_cchan_req_inst,io_cchan_req_addr,io_cchan_req_data_size,io_cchan_req_data_burstlen);

	end


	
	





`endif

endmodule
