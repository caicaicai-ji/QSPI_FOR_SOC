# See LICENSE for license details.

module qspi_cmd_gen(
	clock,
	rst_n,
	io_state_free,
	io_dchan_req_valid,
	io_dchan_req_w_valid,
	io_dchan_req_r_valid,
	io_dchan_req_dummy_valid,
	io_dchan_req_addr_valid,
	io_dchan_req_size,
	io_dchan_req_burstlen,
	io_dchan_req_ready,
	io_dchan_req_inst,
	io_dchan_req_addr,
	io_cchan_req_valid,
	io_cchan_req_w_valid,
	io_cchan_req_r_valid,
	io_cchan_req_dummy_valid,
	io_cchan_req_addr_valid,
	io_cchan_req_size,
	io_cchan_req_burstlen,
	io_cchan_req_inst,
	io_cchan_req_addr,
	io_dummy_valid,
	io_addr_valid,
	io_wr_valid,
	io_rd_valid,
	io_inst,
	io_addr,
	io_inst_size,
	io_inst_burstlen,
	io_dummy_size,
	io_dummy_burstlen,
	io_addr_size,
	io_addr_burstlen,
	io_data_size,
	io_data_burstlen
	
);
input 	clock;
input 	rst_n;
input 	io_state_free;
input 	io_dchan_req_valid;
input 	io_dchan_req_w_valid;
input 	io_dchan_req_r_valid;
input 	io_dchan_req_dummy_valid;
input 	io_dchan_req_addr_valid;
input 	[3:0] io_dchan_req_size;
input 	[7:0] io_dchan_req_burstlen;
output 	io_dchan_req_ready;
input 	[7:0] io_dchan_req_inst;
input 	[23:0]io_dchan_req_addr;
input 	io_cchan_req_valid;
input 	io_cchan_req_w_valid;
input 	io_cchan_req_r_valid;
input 	io_cchan_req_dummy_valid;
input 	io_cchan_req_addr_valid;
input 	[3:0]  io_cchan_req_size;
input 	[7:0]  io_cchan_req_burstlen;
input 	[7:0]  io_cchan_req_inst;
input 	[23:0] io_cchan_req_addr;
output 	io_dummy_valid;
output 	io_addr_valid;
output 	io_wr_valid;
output 	io_rd_valid;
output  [7:0]  io_inst;
output  [23:0] io_addr;
output 	[3:0]  io_inst_size;
output 	[7:0]  io_inst_burstlen;
output 	[3:0]  io_dummy_size;
output  [7:0]  io_dummy_burstlen;
output  [3:0]  io_addr_size;
output  [7:0]  io_addr_burstlen;
output  [3:0]  io_data_size;
output  [7:0]  io_data_burstlen;


reg 		dummy_valid_r;
wire		dummy_valid_pre;
reg		addr_valid_r ;
wire		addr_valid_pre;
reg		wr_valid_r ;
wire		wr_valid_pre;
reg		rd_valid_r;
wire		rd_valid_pre;
reg [7:0]	inst_r;
wire [7:0]	inst_pre;
reg [23:0]	addr_r;	
wire [23:0] 	addr_pre;
reg [3:0]	data_size_r;
wire [3:0]	data_size_pre;
reg [7:0]	data_burstlen_r;
wire [7:0]      data_burstlen_pre;


always@(posedge clock or negedge rst_n)
	if(!rst_n)
	begin
		inst_r		<=	8'b0;
		addr_r		<=	24'b0;
		data_size_r	<=	4'b0;
		data_burstlen_r	<=	4'b0;
		dummy_valid_r 	<=	1'b0;
		addr_valid_r	<=	1'b0;
		wr_valid_r	<=	1'b0;
		rd_valid_r	<=	1'b0;
	end
	else
	begin
                inst_r          <=      inst_pre;
                addr_r          <=      addr_pre;
                data_size_r     <=      data_size_pre;
                data_burstlen_r <=      data_burstlen_pre;
		dummy_valid_r	<=	dummy_valid_pre;
		addr_valid_r	<=	addr_valid_pre;
		wr_valid_r	<=	wr_valid_pre;
		rd_valid_r	<=	rd_valid_pre;
        end

wire dchan_valid;
assign dchan_valid 		= 	io_dchan_req_valid & io_dchan_req_ready ;

assign inst_pre 		= 	~io_state_free ? inst_r :
					io_cchan_req_valid ? io_cchan_req_inst :
		  			dchan_valid ? io_dchan_req_inst :
		  			8'b0 ;
	
assign addr_pre 		= 	~io_state_free ? addr_r :
					io_cchan_req_valid ? io_cchan_req_addr :
					dchan_valid ? io_dchan_req_addr :
		  			24'h0 ;

assign data_size_pre 		=  	~io_state_free ? data_size_r :
					io_cchan_req_valid ? io_cchan_req_size :
		        		dchan_valid ? io_dchan_req_size :
					5'b0;

assign data_burstlen_pre	= 	~io_state_free ? data_burstlen_r :
					io_cchan_req_valid ? io_cchan_req_burstlen  :
			   		dchan_valid ? io_dchan_req_burstlen :
			   		8'b0;

assign dummy_valid_pre 		= 	io_state_free ? dummy_valid_r :
					io_cchan_req_valid ? io_cchan_req_dummy_valid :
			 		dchan_valid ? io_dchan_req_dummy_valid :
			 		1'b0 ;
assign addr_valid_pre 		= 	~io_state_free ? addr_valid_r :
					io_cchan_req_valid ? io_cchan_req_addr_valid :
					dchan_valid ? io_dchan_req_addr_valid :
					1'b0 ;

assign wr_valid_pre		=	~io_state_free ? wr_valid_r :
					io_cchan_req_valid ? io_cchan_req_w_valid :
					dchan_valid ? io_dchan_req_w_valid :
					1'b0 ;

assign rd_valid_pre		=	~io_state_free ? rd_valid_r :
					io_cchan_req_valid ? io_cchan_req_r_valid :
					dchan_valid ? io_dchan_req_r_valid :
					1'b0 ;

assign  io_dummy_valid		=	dummy_valid_r;
assign  io_addr_valid		=	addr_valid_r;
assign  io_wr_valid		=	wr_valid_r;
assign  io_rd_valid		=	rd_valid_r;
assign  io_inst			=	inst_r;
assign  io_addr			=	addr_r;
assign  io_inst_size		=	4'b0001;
assign  io_inst_burstlen	=	8'b1;
assign  io_dummy_size		=	4'b0011;
assign  io_dummy_burstlen	=	8'b1;
assign  io_addr_size		=	4'b0011;
assign  io_addr_burstlen	=	8'b1;
assign  io_data_size		=	data_size_r;
assign  io_data_burstlen	=	data_burstlen_r;

assign  io_dchan_req_ready 	=	io_state_free & (~ io_cchan_req_valid ) ;








endmodule 


	
