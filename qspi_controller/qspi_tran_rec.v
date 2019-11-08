# See LICENSE for license details.
module qspi_tran_rec(
	clock,
	rst_n,
	io_qspi_data_en,
//fsm state
	io_state_free,
	io_state_ready,
	io_state_wren,
	io_state_req,
	io_state_addr,
	io_state_rd_dummy,
	io_state_rd,
	io_state_wr_data,
	io_state_wr_csr,
	io_state_wait_check,
	io_state_check,
	io_state_check_fail,	
	io_state_check_way,
	io_state_wren_way,
	io_state_finish,
//tran signal 
	io_inst,
	io_addr,
	io_inst_size,
	io_inst_burstlen,
	io_addr_size,
	io_addr_burstlen,
	io_data_size,
	io_data_burstlen,
	io_dummy_size,
	io_dummy_burstlen,
	io_dummy_valid,
	io_addr_valid,
	io_wr_valid,
	io_rd_valid,
	io_erase_valid,
	
	io_dpi_mode,
	io_spi_mode,	
	io_tran_finish,	
	io_check_pass,
//tran data fifo interface 
	io_tdata_fifo_wen,
	io_tdata_fifo_wdata,
	io_tdata_fifo_full,
//rec data fifo interface
	io_rdata_fifo_ren,
	io_rdata_fifo_rdata,
	io_rdata_fifo_empty,
	io_csr_data,
	io_qspi_ce,
	io_qspi_oe0,
	io_qspi_so0,
	io_qspi_si0,
	io_qspi_oe1,
	io_qspi_so1,
	io_qspi_si1,
	io_qspi_oe2,
	io_qspi_so2,
	io_qspi_si2,
	io_qspi_oe3,
	io_qspi_so3,
	io_qspi_si3,
	io_qspi_sck
);

input clock;
input rst_n;
input io_qspi_data_en;
input io_state_free;
input io_state_ready;
input io_state_wren;
input io_state_wren_way;
input io_state_req;
input io_state_addr;
input io_state_rd_dummy;
input io_state_rd;
input io_state_wr_data;
input io_state_wr_csr;
input io_state_wait_check;
input io_state_check;
input io_state_check_fail;
input io_state_check_way;
input io_state_finish;
input io_dpi_mode;
input io_spi_mode;

input [7:0]  io_inst;
input [23:0] io_addr;
input [7:0]  io_inst_size;
input [7:0]  io_inst_burstlen;
input [7:0]  io_addr_size;
input [7:0]  io_addr_burstlen;
input [7:0]  io_data_size;
input [7:0]  io_data_burstlen;
input [7:0]  io_dummy_size;
input [7:0]  io_dummy_burstlen;

input io_dummy_valid;
input io_addr_valid;
input io_wr_valid;
input io_rd_valid;
input io_erase_valid;


output io_tran_finish ;
output io_check_pass;
//tran data fifo interface
input  io_tdata_fifo_wen;
input  [31 : 0 ] io_tdata_fifo_wdata;
output io_tdata_fifo_full;
output [7:0] io_csr_data;

input  io_rdata_fifo_ren;
output [31 : 0 ] io_rdata_fifo_rdata;
output io_rdata_fifo_empty; 

output io_qspi_ce;
output io_qspi_oe0;
output io_qspi_so0;
input io_qspi_si0;
output io_qspi_oe1;
output io_qspi_so1;
input io_qspi_si1;
output io_qspi_oe2;
output io_qspi_so2;
input io_qspi_si2;
output io_qspi_oe3;
output io_qspi_so3;
input io_qspi_si3;
output io_qspi_sck;

reg qspi_sck_r ;
wire sck_pedge,sck_nedge;
wire qspi_sck_pre;
always@(posedge clock or negedge rst_n)
        if(!rst_n)
                qspi_sck_r <= 1'b0;
        else
                qspi_sck_r <= qspi_sck_pre;
assign qspi_sck_pre = io_qspi_data_en ? ~qspi_sck_r :
                      qspi_sck_r;
assign io_qspi_sck = qspi_sck_r & ~io_qspi_ce ;

assign sck_pedge = ~qspi_sck_r & io_qspi_data_en ;
assign sck_nedge = qspi_sck_r & io_qspi_data_en ;
////////////////////////////////////////////////////////
// control environment variable
//	this is set for write data check 
wire[7:0]   env_dummy_size;
wire [7:0]  env_instruction;
wire [7:0] env_data_size;
wire [7:0] env_data_burstlen;
assign env_instruction = io_state_check_way ? `RDSR :
			 io_state_wren_way ? io_inst :
			 (io_wr_valid|io_erase_valid) & io_state_ready ? `WREN :
			 io_inst ;
assign env_dummy_size = io_dummy_size;

//when in check way 
//	data_size = 2   //1Byte
//	data_burstlen = 1
assign env_data_size = io_state_check_way ? 8'b00010 :
		       io_data_size ;
assign env_data_burstlen = io_state_check_way ? 8'b1 :
			   io_data_burstlen;
// tran shift register

reg  dpi_cnt_r;
wire dpi_cnt_pre;
reg [1:0] spi_cnt_r;
wire [1:0] spi_cnt_pre;
wire qpi_cnt_flag,dpi_cnt_flag,spi_cnt_flag,qspi_cnt_flag;
reg [7:0] qspi_tshift_reg_r;
wire [7:0] qspi_tshift_reg_pre;
wire qspi_shift_set;
wire [7:0] qspi_shift_set_value;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		#1 qspi_tshift_reg_r <= 8'b0;
	else
		#1 qspi_tshift_reg_r <= qspi_tshift_reg_pre;
//tran at negedge of sck
assign qspi_tshift_reg_pre = ~(sck_nedge)  ? qspi_tshift_reg_r :
			     io_state_free ? 12'b0 :
			     qspi_shift_set ? qspi_shift_set_value :
			     io_spi_mode ? {qspi_tshift_reg_r[6:0],1'b1} :
			     io_dpi_mode ? {qspi_tshift_reg_r[5:0],2'b11} :
			  		   {qspi_tshift_reg_r[3:0],4'b1111} ;

wire qspi_oe;
assign qspi_oe = ~(io_state_rd | io_state_rd_dummy | io_state_finish );
assign io_qspi_oe0 = ~io_spi_mode ? qspi_oe : 1'b1;  //if spi mode: output
assign io_qspi_oe1 = ~io_spi_mode ? qspi_oe : 1'b0;  //if spi mode: input
assign io_qspi_oe2 = ~(io_spi_mode|io_dpi_mode) ? qspi_oe : 1'b1;  //if spi mode: output 
assign io_qspi_oe3 = io_qspi_oe2 ;  //if spi mode: output   

assign io_qspi_so0 = io_qspi_ce ? 1'b0 :
		     io_spi_mode ? qspi_tshift_reg_r[7] :
		     io_dpi_mode ? qspi_tshift_reg_r[6] :
		     qspi_tshift_reg_r[4] ;
assign io_qspi_so1 = io_qspi_ce ? 1'b0 :
		     io_spi_mode ? 1'b0 :
		     io_dpi_mode ? qspi_tshift_reg_r [7] :
		     qspi_tshift_reg_r [5];
assign io_qspi_so2 = io_qspi_ce ? 1'b0 :
		     ~io_spi_mode ? qspi_tshift_reg_r [6] : rst_n;
assign io_qspi_so3 = io_qspi_ce ? 1'b0 :
		     ~io_spi_mode ? qspi_tshift_reg_r [7] : rst_n;

assign qspi_cnt_flag = io_spi_mode ? spi_cnt_flag :
		       io_dpi_mode ? dpi_cnt_flag : 
				     qpi_cnt_flag ;

wire counter_di ;
assign counter_di = io_state_free | io_state_ready | io_state_check | io_state_check_fail
 | io_state_finish;

//////////////////////////////////////////////////////////////////////////
//
//the qpi,dpi,spi counter: qpi_cnt_r,dpi_cnt_r,spi_cnt_r 
//	is use to cal the clocks of traning a half byte(4 bit) of data 
//		at qpi,dpi,spi mode
//////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge rst_n)
	if(!rst_n)
	begin
		dpi_cnt_r <= 1'b0;
		spi_cnt_r <= 2'b0;
	end
	else
	begin
		dpi_cnt_r <= dpi_cnt_pre;
		spi_cnt_r <= spi_cnt_pre;
	end

assign dpi_cnt_pre = ~(sck_nedge) ? dpi_cnt_r :
		     counter_di ? 1'b0 :
		     ~dpi_cnt_r ;
assign spi_cnt_pre = ~(sck_nedge) ? spi_cnt_r :
		     counter_di ? 2'b0 :
		     spi_cnt_r + 2'b1 ;



assign qpi_cnt_flag = ~counter_di;
assign dpi_cnt_flag = dpi_cnt_r ;
assign spi_cnt_flag = spi_cnt_r == 2'b11 ? 1'b1 : 1'b0;


///////////////////////////////////////////////////////////////
//the size counter if cal the clock of traning a beet
//	it depend on size_buard & q/d/spi_cnt_r
///////////////////////////////////////////////////////////////
reg  [7:0] size_cnt_r;
wire [7:0] size_cnt_pre;
wire [7:0] size_buard;
wire size_cnt_flag ;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		size_cnt_r <= 8'b1;
	else
		size_cnt_r <= size_cnt_pre;
assign size_cnt_pre = ~(sck_nedge) ? size_cnt_r :
		      counter_di ? 8'b1 :
		      ~qspi_cnt_flag ? size_cnt_r :
		      size_cnt_flag ? 8'b1 :
		      size_cnt_r + 8'b1 ;

assign size_cnt_flag = size_cnt_r == size_buard ? 1'b1 : 1'b0 ;

assign size_buard = io_state_req | io_state_wren ? io_inst_size :
		    io_state_addr ? io_addr_size :
		    io_state_rd_dummy ? env_dummy_size :
		    io_state_rd | io_state_wr_data | io_state_wr_csr ? env_data_size :
		    8'b1;
////////////////////////////////////////////////////////////
//burst counter is use ro cal the clocking of traning 
//	all beets of data, it depends on 
//		burstlen_cnt_buard & size_cnt_r
reg [7:0] burstlen_cnt_r ;
wire [7:0] burstlen_cnt_pre ;
wire [7:0] burstlen_cnt_buard;
wire burstlen_cnt_flag ;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		burstlen_cnt_r  <= 8'b1;
	else
		burstlen_cnt_r  <= burstlen_cnt_pre;

assign burstlen_cnt_pre = ~(sck_nedge)? burstlen_cnt_r : 
			  counter_di ? 8'b1 :
			  size_cnt_flag & qspi_cnt_flag ? 
					(burstlen_cnt_flag ? 8'b1 : 
					burstlen_cnt_r + 8'b1) :
			  burstlen_cnt_r ;

assign burstlen_cnt_flag = burstlen_cnt_r == burstlen_cnt_buard ? 1'b1 : 1'b0;

assign burstlen_cnt_buard = io_state_req | io_state_wren   ? io_inst_burstlen :
			    io_state_addr ? io_addr_burstlen :
			    io_state_rd_dummy ? io_dummy_burstlen : 
			    io_state_rd | io_state_wr_data | io_state_wr_csr ? env_data_burstlen :
			    8'b1;
assign io_tran_finish = io_state_ready ? sck_nedge:
			burstlen_cnt_flag & size_cnt_flag & qspi_cnt_flag & sck_nedge ;
////////////////////////////////////////////////////////////////////////// 
//set value for tshift reg , just set one byte per time 
// 1.set instruction: Instrcution Tran ar state: wren or req 
//	may be 
//		ready --> wren --> req
//		ready --> req
//	Timing:				
//	clock:		1	2	3	4	5	
//	state:	      ready    req     req     ...
//	size_cnt:       1       1       2  
//	set or not:     1       0       1
//	set value      inst           other
//	clock:		1	2	3	4	5		
//	state:	      ready    wren   wren     req     req
//	size_cnt:	1	1	2	1	2	
//	set or not:     1	0	1	0	1
//	set value     inst  	      inst            other
//
// 2.set addr: Address Tran at state: addr
//	Address[23:16] set at state req
//	Address[15:8]  set at state addr
//	Address[7:0]   set at state addr
//	Timing:			
//	clock:		1	2	3	4	5	6 	7		
//	state:	       req     addr    addr    addr    addr    addr    addr
//	size_cnt(4bit): 2	1	2	3	4	5       6
//	set or not:	1	0	1	0	1	0 	1
//	set value:   addr[23:16]     addr[15:8]      addr[7:0]	      wdata[7:0]
//
// 3.set data: Data Tran at state: wr_csr or wr_data
//	wdata[7:0]  set at state addr or state req
//	wdata[15:8] set at state wr_data or wr_csr(always not)
//	wdata[23:16] set at state wr_data or wr_csr(always not)
//	wdata[31:24] set at state wr_data or wr_csr(always not)
//	Timing:
//	first situation
//	clock:		1	2	3	4	5	6	7	8	9...
//	state:	       addr   wr_data wr_data wr_data wr_data wr_data wr_data wr-data wr_data
//	size_cnt(4bit): 6	1	2	3	4	5	6	7	8	
//	set or not:	1	0	1	0	1	0	1	0	1
//	set_value:    data[7:0]	    data[15:8]       data[23:16]     data[31:24]     data[39:32]
//	second situation
//	clock:		1	2	3	4	5	6	7	8	9...
//	state:	      req     wr_csr  wr_csr  wr_csr  wr_csr  wr_csr  wr-csr  wr_csr  wr_csr
//	size_cnt:	2	1	2	3	4	5	6	7	8	
//	set or not: 	1	0	1	0	1	0	1	0	1	
//	set_value:   data[7:0]     data[15:8]       data[23:16]     data[31:24]     data[39:32]
 

wire [7 : 0] set_value_shift;
wire [7 : 0] value;
wire [7 : 0] set_addr,set_wdata;
wire [31 : 0] wdata;
assign qspi_shift_set = (~size_cnt_r[0] & qspi_cnt_flag | io_state_ready) & sck_nedge  ;
assign set_value_shift = value ; 
assign value =  io_state_ready | io_state_wren  ? env_instruction :
	        io_state_req  & io_tran_finish ? (
			io_addr_valid  ?	io_addr[23:16]	:    //addr 
			io_wr_valid    ?	wdata[7:0]  	:    //write csr
			8'hff
		)  : 
		io_state_addr  ? set_addr :
		io_state_wr_data  ? set_wdata :
	        8'hff;

assign set_addr = size_cnt_r == 8'b0010 ? io_addr[15:8] :
		  size_cnt_r == 8'b0100 ? io_addr[7:0] :
		  size_cnt_r == 8'b0110 ? wdata[7:0] :
		  8'hff;



assign set_wdata = size_cnt_r == 8'b0010 ? wdata[15:8] :
                   size_cnt_r == 8'b0100 ? wdata[23:16] :
                   size_cnt_r == 8'b0110 ? wdata[31:24] :
                   (size_cnt_r == 8'b1000) & ~burstlen_cnt_flag ? wdata[7:0] :
		   8'hff;			

assign qspi_shift_set_value = set_value_shift;
	       
//tran fifo
wire  [31 :0] tran_fifo_wdata,tran_fifo_rdata ;
wire tran_fifo_wen,tran_fifo_ren;
wire tran_fifo_full;
wire [1:0] tran_fifo_level ;
wire tran_fifo_empty;
qspi_data_fifo_32  #(.dw(32),.aw(6)) U_tran_fifo
(
	.clk(clock),
	.rst(rst_n),
	.clr(~rst_n),
	.din(tran_fifo_wdata),
	.we(tran_fifo_wen),
	.dout(tran_fifo_rdata),
	.re(tran_fifo_ren),
	.full(tran_fifo_full),
	.empty(tran_fifo_empty),
	.level(tran_fifo_level)
	);
assign tran_fifo_wdata = io_tdata_fifo_wdata; 
assign tran_fifo_wen = io_tdata_fifo_wen;
assign io_tdata_fifo_full = tran_fifo_full;

assign io_csr_data = tran_fifo_rdata [7:0] ;

assign tran_fifo_ren = 	(io_state_wr_data | io_state_wr_csr) & size_cnt_flag & qspi_cnt_flag & sck_pedge ;
assign wdata = tran_fifo_rdata;			


//rec shift reg 

reg [31:0]  qspi_rshift_reg_r;
wire [31:0] qspi_rshift_reg_pre;



always@(posedge clock or negedge rst_n)
	if(!rst_n)
		qspi_rshift_reg_r <= 32'hff;
	else
		qspi_rshift_reg_r <= qspi_rshift_reg_pre;

assign qspi_rshift_reg_pre = ~sck_pedge ? qspi_rshift_reg_r :
			     ~io_state_rd  ? 32'hff :
			     io_spi_mode ? {qspi_rshift_reg_r[30:0],io_qspi_si1} :
			     io_dpi_mode ? {qspi_rshift_reg_r[29:0],io_qspi_si1,io_qspi_si0} :
			     {qspi_rshift_reg_r[27:0],io_qspi_si3,io_qspi_si2,io_qspi_si1,io_qspi_si0};


			     

//rec fifo 
wire  [31 :0] rec_fifo_wdata,rec_fifo_rdata ;
wire rec_fifo_wen,rec_fifo_ren;
wire rec_fifo_full;
wire [1:0] rec_fifo_level ;
wire rec_fifo_empty;
//use to check the process in flash chip finish or not 
reg csr_data_wip;
wire csr_data_wip_pre;

qspi_data_fifo_32  #(.dw(32),.aw(6)) U_rec_fifo
(
        .clk(clock),
        .rst(rst_n),
        .clr(~rst_n),
        .din(rec_fifo_wdata),
        .we(rec_fifo_wen),
        .dout(rec_fifo_rdata),
        .re(rec_fifo_ren),
        .full(rec_fifo_full),
        .empty(rec_fifo_empty),
        .level(rec_fifo_level)
        );

assign rec_fifo_ren = io_rdata_fifo_ren;
assign io_rdata_fifo_rdata = rec_fifo_rdata;

assign io_rdata_fifo_empty = rec_fifo_empty;

wire wen_cond;
assign wen_cond  = io_state_rd & size_cnt_flag & qspi_cnt_flag & sck_nedge ;
assign rec_fifo_wen = wen_cond & ~io_state_check_way ;
assign rec_fifo_wdata = {qspi_rshift_reg_r[7:0],
			 qspi_rshift_reg_r[15:8],
			 qspi_rshift_reg_r[23:16],
			 qspi_rshift_reg_r[31:24]};
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		csr_data_wip <= 1'b1;
	else
		csr_data_wip <= csr_data_wip_pre;
wire csr_data_wip_en;
assign csr_data_wip_en = wen_cond & io_state_check_way;
assign csr_data_wip_pre = csr_data_wip_en ? rec_fifo_wdata[24] : 
			  csr_data_wip ;
assign io_check_pass = ~csr_data_wip;




assign io_qspi_ce = io_state_free | io_state_ready | io_state_finish |io_state_wait_check| io_state_check | io_state_check_fail;

`ifdef QSPI_SIM


`endif
endmodule




















