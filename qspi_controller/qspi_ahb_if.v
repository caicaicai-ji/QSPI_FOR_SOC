# See LICENSE for license details.

module qspi_ahb_if(
	clock,
	rst_n,
//to module  qspi cchan inst gen
	io_flash_state_csr,
//interrupt 
	io_qspi_interrupt,

        hsel_s,
        haddr_s,
        hsize_s,
        htrans_s,
        hwrite_s,
        hrdata_s,
        hwdata_s,
        hready_s,
        hresp_s,
//from ctrl level 
	io_ctrl_lev_inst_label,
	io_ctrl_lev_inst_valid,
	io_ctrl_lev_wr_en,
//from tran_level
	io_tran_spi_mode,
	io_tran_dpi_mode,
	io_tran_inst_label,
//to tran level 
	io_clk_divide_param,
	io_interface_lev_wren,
//program mode
	io_qspi_ctrl_mode,
	io_pmode_inst,
	io_pmode_addr,
	io_pmode_size,
	io_pmode_start,
	io_pmode_start_clr,
//normal mode signal 
// 
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
//data
	io_cchan_tdata_fifo_wen,
	io_cchan_tdata_fifo_wdata,
	io_cchan_tdata_fifo_full,

	io_cchan_rdata_fifo_ren,
	io_cchan_rdata_fifo_rdata,
	io_cchan_rdata_fifo_empty,
//data lock
	io_tdata_lock,
//exception
	io_cchan_resp_valid,
	io_cchan_resp_error,
	io_cchan_resp_cause

	


);
input clock;
input rst_n;

output [1:0] io_flash_state_csr;


output io_qspi_interrupt;

input hsel_s;
input [4:0] haddr_s;
input [2:0] hsize_s;
input [1:0] htrans_s;
input hwrite_s;
output [31: 0 ] hrdata_s;
input [31 : 0 ] hwdata_s;
output  hready_s;
output hresp_s;
output  [31:0] io_clk_divide_param;
output io_interface_lev_wren;
//from ctrl level
input   io_ctrl_lev_inst_label;
input   io_ctrl_lev_inst_valid;
input   io_ctrl_lev_wr_en;
//from tran_level
input   io_tran_spi_mode;
input   io_tran_dpi_mode;
input   io_tran_inst_label;


//program mode
output  io_qspi_ctrl_mode;
output [7:0] io_pmode_inst;
output [23:0] io_pmode_addr;
output io_pmode_start;
input  io_pmode_start_clr;
output  [7:0] io_pmode_size;

output  io_cchan_eqpi;
output  io_cchan_qpidi;
output  io_cchan_edpi;
output  io_cchan_dpidi;
output  io_cchan_cer;
output  io_cchan_ber32;
output  io_cchan_ber64;
output  io_cchan_ser;
output  io_cchan_wrcsr;
output  io_cchan_rdcsr;
input  io_cchan_eqpi_clr;
input  io_cchan_qpidi_clr;
input  io_cchan_edpi_clr;
input  io_cchan_dpidi_clr;
input  io_cchan_cer_clr;
input  io_cchan_ber32_clr;
input  io_cchan_ber64_clr;
input  io_cchan_ser_clr;
input  io_cchan_wrcsr_clr;
input  io_cchan_rdcsr_clr;

//data
output io_cchan_tdata_fifo_wen;
output [31 : 0 ] io_cchan_tdata_fifo_wdata;
input  io_cchan_tdata_fifo_full;

output io_cchan_rdata_fifo_ren;
input  [31 : 0 ] io_cchan_rdata_fifo_rdata;
input  io_cchan_rdata_fifo_empty;
//data lock
input  io_tdata_lock;
//exception
input  io_cchan_resp_valid;
input  io_cchan_resp_error;
input [1:0] io_cchan_resp_cause;



reg [4:0] d_haddr_s;
reg [3:0] d_hsize_s;
always@(posedge clock or negedge rst_n)
if(!rst_n)
begin 
        d_haddr_s       <=      5'h0;
        d_hsize_s       <=      4'h0;
end
else
begin 
        d_haddr_s       <=      haddr_s;
        d_hsize_s       <=      hsize_s;
end

reg wr_valid,rd_valid;
always@(posedge clock or negedge rst_n)
if(!rst_n)
begin : W_R_INIT
        wr_valid   <=      1'b0;
        rd_valid   <=      1'b0;
end
else
begin : W_R
        wr_valid   <=      (hwrite_s&hsel_s&htrans_s[1]);
        rd_valid   <=      (~hwrite_s&hsel_s&htrans_s[1]);
end

//////////////////////////////////////////////////////////////
// Qspi  controler register 
//	FlashDivide	0x00 ~ 0x04
//	FlashCtrl 	0x04 ~ 0x05
//	FlashCSR	0x06 
//	FlashState      0x07
//	FlashAddr	0x08 ~ 0x0b
//	FlashData	0x0c ~ 0x0f
//	FlashSize	0x10 


wire flash_divide_vld ;
wire flash_ctrl_vld;
wire flash_csr_vld;
wire flash_state_vld;
wire flash_addr_vld ;
wire flash_data_vld;
wire flash_size_vld;

assign flash_divide_vld = (d_haddr_s == 5'h0 );
assign flash_ctrl_vld =   (d_haddr_s == 5'h4 ) &&(d_hsize_s == 3'b001) ||   // word access 
			  (d_haddr_s == 5'h4) && (d_hsize_s == 3'b010) ;    // half access

assign flash_csr_vld  =    (d_haddr_s == 5'h6)  && (d_hsize_s == 3'b000)   //byte access 
			|| (d_haddr_s == 5'h6) && (d_hsize_s == 3'b001)    //half access
			|| (d_haddr_s == 5'h4) && (d_hsize_s == 3'b010);   //word_access
assign flash_state_vld =   (d_haddr_s == 5'h7)  && (d_hsize_s == 3'b000) || 
			   (d_haddr_s == 5'h6) && (d_hsize_s == 3'b001)  || 
			   (d_haddr_s == 5'h4) && (d_hsize_s == 3'b010);

assign flash_addr_vld  =   (d_haddr_s == 5'h8) && (d_hsize_s == 3'b010) ;

assign flash_data_vld =    (d_haddr_s == 5'hc) && (d_hsize_s == 3'b010) ? 1'b1 : 1'b0;

assign flash_size_vld =    (d_haddr_s == 5'b10) ? 1'b1 : 1'b0;
/////////////////////////////////////////////////////////
// FlashDivide register  0x00

reg [31:0] flash_divide_reg ;
wire [31:0] flash_divide_reg_pre;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		flash_divide_reg <= 32'b11;
	else
		flash_divide_reg <= flash_divide_reg_pre ;

assign flash_divide_reg_pre = flash_divide_vld & wr_valid ? hwdata_s[31:0] :
			      flash_divide_reg;
assign io_clk_divide_param = flash_divide_reg ; 
////////////////////////////////////////////////////////////
// FlashCtrl register 0x04

//Flash operator 
reg  flash_ctrl_wren;
reg  flash_ctrl_edpi,flash_ctrl_dpidi;
reg  flash_ctrl_eqpi,flash_ctrl_qpidi;
reg  flash_ctrl_cer,flash_ctrl_ber32,flash_ctrl_ber64,flash_ctrl_ser ;
reg  flash_ctrl_wrcsr,flash_ctrl_rdcsr;

//control signal
reg flash_ctrl_flush;
reg flash_ctrl_ie;
reg flash_ctrl_st;
reg flash_ctrl_mode;


wire [15:0] flash_ctrl_reg;

wire flash_ctrl_wren_pre,flash_ctrl_wrdi_pre;
wire flash_ctrl_edpi_pre,flash_ctrl_dpidi_pre;
wire flash_ctrl_eqpi_pre,flash_ctrl_qpidi_pre;
wire flash_ctrl_cer_pre,flash_ctrl_ber32_pre,flash_ctrl_ber64_pre,flash_ctrl_ser_pre ;
wire flash_ctrl_wrcsr_pre,flash_ctrl_rdcsr_pre; 

wire flash_ctrl_flush_pre;
wire flash_ctrl_ie_pre;
wire flash_ctrl_st_pre;
wire flash_ctrl_mode_pre;

always@(posedge clock or negedge rst_n)
        if(!rst_n)
	begin
		flash_ctrl_wren  <= 1'b1;
		flash_ctrl_edpi  <= 1'b0;
		flash_ctrl_dpidi <= 1'b0;
		flash_ctrl_eqpi  <= 1'b1;
		flash_ctrl_qpidi <= 1'b0;
                flash_ctrl_cer 	 <= 1'b0;
		flash_ctrl_ber32 <= 1'b0;
		flash_ctrl_ber64 <= 1'b0;
		flash_ctrl_ser 	 <= 1'b0;
		flash_ctrl_wrcsr <= 1'b0;
		flash_ctrl_rdcsr <= 1'b0;
		flash_ctrl_flush <= 1'b0;
		flash_ctrl_ie	 <= 1'b0;
		flash_ctrl_st	 <= 1'b0;
		flash_ctrl_mode	 <= 1'b0;
	end
        else
	begin
		flash_ctrl_wren  <= flash_ctrl_wren_pre ;
		flash_ctrl_edpi  <= flash_ctrl_edpi_pre;
		flash_ctrl_dpidi  <= flash_ctrl_dpidi_pre;
		flash_ctrl_eqpi	 <= flash_ctrl_eqpi_pre;
		flash_ctrl_qpidi <= flash_ctrl_qpidi_pre;
                flash_ctrl_cer 	 <= flash_ctrl_cer_pre;
		flash_ctrl_ber32 <= flash_ctrl_ber32_pre;
		flash_ctrl_ber64 <= flash_ctrl_ber64_pre;
		flash_ctrl_ser   <= flash_ctrl_ser_pre ;
		flash_ctrl_wrcsr  <= flash_ctrl_wrcsr_pre;
		flash_ctrl_rdcsr  <= flash_ctrl_rdcsr_pre;
		flash_ctrl_flush <= flash_ctrl_flush_pre;
		flash_ctrl_ie	 <= flash_ctrl_ie_pre ;
		flash_ctrl_st	 <= flash_ctrl_st_pre ;
		flash_ctrl_mode  <= flash_ctrl_mode_pre ;
	end

assign flash_ctrl_edpi_pre 	= 	io_cchan_edpi_clr ? 1'b0 :
                         		wr_valid & flash_ctrl_vld ? hwdata_s[0] : 
			 		flash_ctrl_edpi;
assign flash_ctrl_dpidi_pre 	=	io_cchan_dpidi_clr ? 1'b0 :
                           		wr_valid & flash_ctrl_vld ? hwdata_s[1] : 
					flash_ctrl_dpidi;
assign flash_ctrl_eqpi_pre 	=	io_cchan_eqpi_clr ? 1'b0 : 
		            		wr_valid & flash_ctrl_vld ? hwdata_s[2] :
			    		flash_ctrl_eqpi ;
assign flash_ctrl_qpidi_pre 	=	io_cchan_qpidi_clr ? 1'b0 :
                            		wr_valid & flash_ctrl_vld ? hwdata_s[3] :
                            		flash_ctrl_qpidi ;
assign flash_ctrl_cer_pre 	=	io_cchan_cer_clr ? 1'b0 :
			   		wr_valid & flash_ctrl_vld ? hwdata_s[4] : 
					flash_ctrl_cer;		 
assign flash_ctrl_ber32_pre 	=	io_cchan_ber32_clr ? 1'b0 :
                           		wr_valid & flash_ctrl_vld ? hwdata_s[5] : 
					flash_ctrl_ber32;
assign flash_ctrl_ber64_pre 	= 	io_cchan_ber64_clr ? 1'b0 :
                           		wr_valid & flash_ctrl_vld ? hwdata_s[6] : 
					flash_ctrl_ber64;
assign flash_ctrl_ser_pre 	= 	io_cchan_ser_clr ? 1'b0 :
                           		wr_valid & flash_ctrl_vld ? hwdata_s[7] : 
					flash_ctrl_ser;
assign flash_ctrl_rdcsr_pre     =       io_cchan_rdcsr_clr ? 1'b0 :
                                        wr_valid & flash_ctrl_vld ? hwdata_s[8] :
                                        flash_ctrl_rdcsr;
assign flash_ctrl_wrcsr_pre 	= 	io_cchan_wrcsr_clr ? 1'b0 :
                           		wr_valid & flash_ctrl_vld ? hwdata_s[9] : 
					flash_ctrl_wrcsr;

assign flash_ctrl_wren_pre      =       wr_valid & flash_ctrl_vld ? hwdata_s[11] :
                                        flash_ctrl_wren;

wire flush_clr;
assign flash_ctrl_flush_pre	=	flush_clr ? 1'b0 :
					wr_valid & flash_ctrl_vld ? hwdata_s[12] :
					flash_ctrl_flush ;

assign flash_ctrl_ie_pre	=	wr_valid & flash_ctrl_vld ? hwdata_s[13] :
					flash_ctrl_ie ;

assign flash_ctrl_st_pre	=	io_pmode_start_clr ? 1'b0 :
					wr_valid & flash_ctrl_vld ? hwdata_s[14] :
					flash_ctrl_st ;
assign flash_ctrl_mode_pre	=	wr_valid & flash_ctrl_vld ? hwdata_s[15] :
					flash_ctrl_mode ;



assign flash_ctrl_reg 		=      {flash_ctrl_mode,
					flash_ctrl_st,
					flash_ctrl_ie,
					flash_ctrl_flush,
					flash_ctrl_wren,
					1'b0,		
			     		flash_ctrl_wrcsr,
					flash_ctrl_rdcsr,
					flash_ctrl_ser,
					flash_ctrl_ber64,
					flash_ctrl_ber32,
					flash_ctrl_cer,
					flash_ctrl_qpidi,
					flash_ctrl_eqpi,
					flash_ctrl_dpidi,
					flash_ctrl_edpi
					};

assign io_qspi_ctrl_mode = flash_ctrl_mode ;

assign io_pmode_start = flash_ctrl_st;

assign io_interface_lev_wren = flash_ctrl_wren;

assign io_qspi_interrupt = flash_ctrl_ie & io_cchan_resp_valid & io_cchan_resp_error ;

assign io_cchan_eqpi 	=	flash_ctrl_eqpi;
assign io_cchan_qpidi	=	flash_ctrl_qpidi;
assign io_cchan_cer	=	flash_ctrl_cer;
assign io_cchan_edpi	=	flash_ctrl_edpi;
assign io_cchan_dpidi	=	flash_ctrl_dpidi;
assign io_cchan_ber32	=	flash_ctrl_ber32 ;
assign io_cchan_ber64 	= 	flash_ctrl_ber64 ;
assign io_cchan_ser 	= 	flash_ctrl_ser ;
assign io_cchan_wrcsr 	= 	flash_ctrl_wrcsr ;
assign io_cchan_rdcsr 	= 	flash_ctrl_rdcsr ;

///////////////////////////////////////////////////////////////
//FlashCSR register 0x06
wire[7:0]  flash_csr_reg ;
reg [7:0] flash_csr;
wire [7:0] flash_csr_pre;
wire flash_csr_we ;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		flash_csr <= 8'b0;
	else
		flash_csr <= flash_csr_pre ;

assign flash_csr_pre = flash_csr_vld & wr_valid ? hwdata_s[23:16] :
		       flash_csr_we ? io_cchan_rdata_fifo_rdata[31:24] :
			flash_csr;

assign flash_csr_reg = flash_csr;

//////////////////////////////////////////////////////////////
//FlashState register 0x07
wire [7:0] flash_state_reg;

wire [1:0] flash_state_mode;

reg [1:0] flash_state_csr;
wire [1:0] flash_state_csr_pre;

wire flash_state_ctrl_mode ;
reg flash_state_rd_finish;

reg tran_inst_label_d;


reg [1:0] flash_state_cause;

wire flash_state_rd_finish_pre;

wire [1:0] flash_state_cause_pre ;


assign flash_state_mode = {io_tran_dpi_mode,io_tran_spi_mode};
assign flash_state_ctrl_mode = flash_ctrl_mode;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
	begin
		flash_state_rd_finish <= 1'b0;
		flash_state_csr <= 2'b00;
		flash_state_cause <= 2'b00;
	end
	else
	begin
		flash_state_rd_finish <= flash_state_rd_finish_pre ;
		flash_state_csr <= flash_state_csr_pre;
		flash_state_cause <= flash_state_cause_pre ;
 	end

assign flash_state_csr_pre = flash_state_vld & wr_valid ? hwdata_s[29:28] :
			     flash_state_csr ;
assign io_flash_state_csr = flash_state_csr;

assign flash_state_rd_finish_pre = ~(io_cchan_rdata_fifo_empty | tran_inst_label_d) ? 1'b1 :
				    flash_state_vld & rd_valid  ? 1'b0 :
				    flash_state_rd_finish ; 

assign flash_state_cause_pre = io_cchan_resp_valid & io_cchan_resp_error ? io_cchan_resp_cause :
			       flash_state_cause ;
assign flash_state_reg = {flash_state_mode,flash_state_csr,
			  flash_state_ctrl_mode,
			  flash_state_rd_finish,
			  flash_state_cause};

////////////////////////////////////////////////////////////////////////////
// FlashAddr register
reg [31:0]flash_addr_reg ;
wire [31:0] flash_addr_reg_pre;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		flash_addr_reg <= 32'b0;
	else
		flash_addr_reg <= flash_addr_reg_pre ;

assign flash_addr_reg_pre = flash_addr_vld & wr_valid ? hwdata_s[31:0] :
			    flash_addr_reg;

assign io_pmode_addr = flash_addr_reg[23:0] ;
assign io_pmode_inst = flash_addr_reg[31:24] ;

/////////////////////////////////////////////////////////////////////////////
//FlashData register 
reg [31:0] flash_tdata_reg ;
wire [31:0] flash_rdata_reg ;


//tran data
wire [31:0] flash_tdata_pre ;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		flash_tdata_reg <= 32'b0;
	else
		flash_tdata_reg <= flash_tdata_pre ;
assign flash_tdata_pre = flash_data_vld & wr_valid ? hwdata_s[31:0] :
			 flash_tdata_reg ;
//rec data fifo 
wire flash_rdata_fifo_we ;
wire flash_rdata_fifo_re ;
wire flash_rdata_fifo_full ;
wire flash_rdata_fifo_empty ;
wire [1:0] flash_rdata_fifo_level;

qspi_data_fifo_32  #(.dw( 32 ),.aw(6)) U_flash_rdata_fifo
(
        .clk(clock),
        .rst(rst_n),
        .clr( ~rst_n | flash_ctrl_flush ),
        .din(io_cchan_rdata_fifo_rdata[31:0] ),
        .we(flash_rdata_fifo_we),
        .dout(flash_rdata_reg),
        .re(flash_rdata_fifo_re),
        .full(flash_rdata_fifo_full),
        .empty(flash_rdata_fifo_empty),
        .level(flash_rdata_fifo_level)
);

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		tran_inst_label_d <= 1'b1;	
	else
		tran_inst_label_d <= io_tran_inst_label ;

reg rdata_we;
wire rdata_we_p;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
	
		rdata_we <= 1'b0;
	else
		rdata_we <= rdata_we_p;

assign flush_clr = flash_rdata_fifo_empty ;

assign rdata_we_p = io_cchan_rdata_fifo_ren & ~flash_rdata_fifo_full ;


assign flash_rdata_fifo_we = rdata_we & flash_ctrl_mode ;
assign flash_csr_we    = rdata_we & ~ flash_ctrl_mode ;

assign flash_rdata_fifo_re = ~flash_rdata_fifo_empty & flash_data_vld & rd_valid ;


assign io_cchan_rdata_fifo_ren = ~(tran_inst_label_d | io_cchan_rdata_fifo_empty) ; 


wire eqpi_vld,edpi_vld;
wire qpidi_vld,dpidi_vld;
assign eqpi_vld = io_cchan_eqpi_clr;
assign qpidi_vld = io_cchan_qpidi_clr;

assign edpi_vld = io_cchan_edpi_clr;
assign dpidi_vld = io_cchan_dpidi_clr;


assign io_cchan_tdata_fifo_wdata[31:0]  = flash_ctrl_mode ? flash_tdata_reg : 
				   eqpi_vld ? {24'b0,8'b0110_1111} :
				   edpi_vld ? {24'b0,8'b1010_1111} :
				   dpidi_vld | dpidi_vld ? {24'b0,8'b1110_1111} :
				   {24'b0,flash_csr_reg} ;
 
//////////////////////////////////////////////////
//timing 
//clk				0	1	2	3	4	5	6		
//tdata_fifo_valid		0	1	0	0	0	0	0	
//io_tdata_lock			1	1	1	1	0	0	0
//tdata_fifo_hold		0	0	1	1	1	0	0
//io_cchan_tdata_fifo_wen	0	0	0	0	1	0	0		
reg tdata_fifo_hold ;
wire tdata_fifo_hold_pre;
wire tdata_fifo_valid;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
	begin
		tdata_fifo_hold <=  1'b0;
	end
	else
	begin
		tdata_fifo_hold <= tdata_fifo_hold_pre ;
	end
		
assign tdata_fifo_hold_pre = tdata_fifo_valid & io_tdata_lock  ? 1'b1 :
			     ~io_tdata_lock ? 1'b0 :
			     tdata_fifo_hold;
assign tdata_fifo_valid = ~io_ctrl_lev_inst_label & io_ctrl_lev_inst_valid & io_ctrl_lev_wr_en ; 
assign io_cchan_tdata_fifo_wen =  (tdata_fifo_valid | tdata_fifo_hold)& ~io_tdata_lock ;
			       
///////////////////////////////////
// flash size register 0x10
//

reg [7:0] flash_size_reg ;
wire [7:0] flash_size_pre;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		flash_size_reg <= 8'b0;
	else
		flash_size_reg <= flash_size_pre;
assign flash_size_pre =  flash_size_vld & wr_valid ? hwdata_s[7:0] :
                         flash_size_reg ;


assign io_pmode_size = io_pmode_start ? flash_size_reg : 8'b1; 


assign hrdata_s[7:0] = ~rd_valid ? 8'b0 :
			flash_divide_vld ? flash_divide_reg[7:0] :
			flash_ctrl_vld ? flash_ctrl_reg[7:0] :		
			flash_addr_vld ? flash_addr_reg[7:0] : 
			flash_data_vld ? flash_rdata_reg[7:0] :
			flash_size_vld ? flash_size_reg[7:0] :
			8'b0;
assign hrdata_s[15:8] = ~rd_valid ? 8'b0 :
                        flash_divide_vld ? flash_divide_reg[15:8] :
			flash_ctrl_vld ? flash_ctrl_reg[15:8] :
			flash_addr_vld ? flash_addr_reg[15:8] :
			flash_data_vld ? flash_rdata_reg[15:8] :
                        8'b0;
assign hrdata_s[23:16] = ~rd_valid ? 8'b0 :
                         flash_divide_vld ? flash_divide_reg[23:16] :
			 flash_csr_vld ? flash_csr_reg :
			 flash_addr_vld ? flash_addr_reg[23:16] :
			 flash_data_vld ? flash_rdata_reg[23:16] :
			 8'b0;
assign hrdata_s[31:24] = ~rd_valid ? 8'b0 :
                        flash_divide_vld ? flash_divide_reg[31:24] :
			flash_state_vld ? flash_state_reg :
			flash_addr_vld ? flash_addr_reg[31:24] :
			flash_data_vld ? flash_rdata_reg[31:24] :
                        8'b0;
`ifdef X64 
assign hrdata_s[63:32] = 32'b0;
`endif

assign hready_s = flash_data_vld ? ~io_cchan_rdata_fifo_empty : 
		  1'b1;
assign hresp_s = 1'b0;

`ifdef QSPI_SIM
////////////////////////////////////
// Verification Plan
//	1.check the reg read_write info 
//	2.monitor the controller env change 
//	3.check the read data to ...
integer reg_state_log;

initial begin
	reg_state_log = $fopen("../sim_log/qspi_ahb_if_reg_info.log");
end
/////////////////////////////////////
//Register op 
//	flash divide reg : 
//		write: AHB-Lite  read: AHB_Lite
//	flash ctrl reg:
//		write AHB-Lite clear auto read:AHB_Lite
/*
property ahb_req; 
	@(posedge clock)
	(rst_n == 1) && (flash_divide_vld || flash_ctrl_vld || flash_csr_vld || flash_state_vld || flash_addr_vld || flash_data_vld) |->	
	((flash_divide_vld==1) &&  (flash_ctrl_vld==0)   && (flash_csr_vld==0)  && (flash_state_vld==0 ) && (flash_addr_vld==0)  && (flash_data_vld==0) ||
	 (flash_ctrl_vld==1)   &&  (flash_divide_vld==0) && (flash_csr_vld==0)  && (flash_state_vld==0 ) && (flash_addr_vld==0)  && (flash_data_vld==0) ||
	 (flash_csr_vld==1)    &&  (flash_divide_vld==0) && (flash_ctrl_vld==0) && (flash_state_vld==0)  && (flash_addr_vld==0)  && (flash_data_vld==0) ||
	 (flash_state_vld==1)  &&  (flash_divide_vld==0) && (flash_ctrl_vld==0) && (flash_csr_vld==0)    && (flash_addr_vld==0)  && (flash_data_vld==0) ||
	 (flash_addr_vld==1)   &&  (flash_divide_vld==0) && (flash_ctrl_vld==0) && (flash_csr_vld==0)    && (flash_state_vld==0) && (flash_data_vld==0) ||
	 (flash_data_vld==1)   &&  (flash_divide_vld==0) && (flash_ctrl_vld==0) && (flash_csr_vld==0)    && (flash_state_vld==0) && (flash_addr_vld==0));

endproperty 

a_ahb_req:assert property(ahb_req) ; else begin
	$display("at qspi_ahb_if: line 608,false for ahb-lite req");
	$stop;
end
c_ahb_req:cover property(ahb_req);
*/
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		;
	else if(wr_valid || rd_valid)
	begin
		$fwrite(reg_state_log,"===============%d ns:===================\n",$time/1000);
		if(flash_divide_vld)
			$fwrite(reg_state_log,"op flash divide reg,w:%b,r:%b,wdata:%d\n",wr_valid,rd_valid,hwdata_s);
		if(flash_ctrl_vld)
			$fwrite(reg_state_log,"op flash ctrl reg,w:%b,r:%b,wdata:0x%h\n",wr_valid,rd_valid,hwdata_s[15:0]);
		if(flash_csr_vld)
			$fwrite(reg_state_log,"op flash csr reg,w:%b,r:%b,wdata:0x%h\n",wr_valid,rd_valid,hwdata_s[23:16]);
		if(flash_state_vld)
			$fwrite(reg_state_log,"op flash state reg,w:%b,r:%b,wdata:0x%h\n",wr_valid,rd_valid,hwdata_s[31:24]);
		if(flash_addr_vld)
			$fwrite(reg_state_log,"op flash addr reg,w:%b,r:%b,wdata:0x%h\n",wr_valid,rd_valid,hwdata_s[31:0]);
		if(flash_data_vld)
			$fwrite(reg_state_log,"op flash data reg,w:%b,r:%b,wdata:%d\n",wr_valid,rd_valid,hwdata_s[31:0]);
		
		$fwrite(reg_state_log,"info:\n");
		$fwrite(reg_state_log," flash_divide:\n"); 
		$fwrite(reg_state_log," -------------------------\n");
		$fwrite(reg_state_log,"| %d                 |\n",flash_divide_reg);
		$fwrite(reg_state_log," -------------------------\n\n");
		$fwrite(reg_state_log," flash_ctrl:\n");
		$fwrite(reg_state_log," -------------------------------------\n");
		$fwrite(reg_state_log,"|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1|0|\n");
		$fwrite(reg_state_log,"|-------------------------------------|\n");
		$fwrite(reg_state_log,"|%b |%b |%b |%b |%b |%b |%b|%b|%b|%b|%b|%b|%b|%b|%b|%b|\n",flash_ctrl_reg[15],flash_ctrl_reg[14],flash_ctrl_reg[13],flash_ctrl_reg[12],flash_ctrl_reg[11],flash_ctrl_reg[10],flash_ctrl_reg[9],flash_ctrl_reg[8],flash_ctrl_reg[7],flash_ctrl_reg[6],flash_ctrl_reg[5],flash_ctrl_reg[4],flash_ctrl_reg[3],flash_ctrl_reg[2],flash_ctrl_reg[1],flash_ctrl_reg[0]);
		$fwrite(reg_state_log," -------------------------------------|\n\n");
		$fwrite(reg_state_log,"flash_csr:\n");
		
		$fwrite(reg_state_log," -------------------------------\n");
		$fwrite(reg_state_log,"|        0x%h                   |\n",flash_csr_reg[7:0]);
                $fwrite(reg_state_log," -------------------------------\n\n");
		$fwrite(reg_state_log,"flash_state:\n");
		$fwrite(reg_state_log," ------------------------------- \n");
		$fwrite(reg_state_log,"| 7-6 | 5-4 | 3 | 2 | 1-0 |\n");
		$fwrite(reg_state_log," ------------------------------- \n");
		$fwrite(reg_state_log,"|  %d  |  %d  | %d | %d |  %d  |\n",flash_state_reg[7:6],flash_state_reg[5:4],flash_state_reg[3],flash_state_reg[2],flash_state_reg[1:0]);
		$fwrite(reg_state_log," ------------------------------- \n\n");
		$fwrite(reg_state_log,"flash_addr:\n");
		$fwrite(reg_state_log," ------------------------------- \n");
		$fwrite(reg_state_log,"|  inst   |     addr            |\n");
		$fwrite(reg_state_log," ------------------------------- \n");
		$fwrite(reg_state_log,"| 0x%h    |    0x%h          |\n",flash_addr_reg[31:24],flash_addr_reg[23:0]);
		$fwrite(reg_state_log," ------------------------------- \n\n");
		$fwrite(reg_state_log,"flash_data:\n");	
		$fwrite(reg_state_log," ------------------------------- \n");
                $fwrite(reg_state_log,"|           %d                  |\n",flash_rdata_reg);
                $fwrite(reg_state_log," ------------------------------- \n");
		$fwrite(reg_state_log,"========================end===========================\n\n\n");
	end

reg[7:0] flash_state_reg_delay;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		flash_state_reg_delay <= 8'b0;
	else 
		flash_state_reg_delay <= flash_state_reg;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		;
	else if(flash_state_reg != flash_state_reg_delay)
	begin
		if(flash_state_reg[7:6]==2'b00)
			$display("==flash state:qspi now in qpi mode==\n");
		else if(flash_state_reg[7:6]==2'b01)
		        $display("==flash state:qspi now in spi mode==\n");
		else if(flash_state_reg[7:6]==2'b10)
			$display("==flash state:qspi now in dpi mode==\n");

		if(flash_state_reg[3] == 1'b0)
			$display("==flash state:qspi now in normal mode==\n");
		else 
			$display("==flash state:qspi now in program mode==\n");
	end
`endif
endmodule




