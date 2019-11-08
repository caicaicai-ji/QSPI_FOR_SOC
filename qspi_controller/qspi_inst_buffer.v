# See LICENSE for license details.
module qspi_inst_buffer
(
	clock,
	rst_n,
	//to control level
	io_tran_inst_label,
	//signal from module cmd_gen 
	io_buf_req_valid,
	io_buf_req_ready,
        io_buf_req_inst,
	io_buf_req_inst_label,
	io_buf_req_wr_en,
	io_buf_req_rd_en,
	io_buf_req_addr_en,
	io_buf_req_erase_en,
        io_buf_req_addr,
        io_buf_req_data_size,
        io_buf_req_data_burstlen,
        io_buf_req_dummy_en,
	io_buf_req_dummy_size,
        io_buf_req_dummy_burstlen,
        io_buf_req_addr_mode_en,
        io_buf_req_addr_spi_mode,
        io_buf_req_addr_dpi_mode,
        io_buf_req_data_mode_en,
        io_buf_req_data_spi_mode,
        io_buf_req_data_dpi_mode,

	//signal to module fsm  or tran_rec
	io_start_signal, //to start tran flash req
	io_next_req,  // from fsm for next req
	io_dummy_valid,
        io_addr_valid,
        io_wr_valid,
        io_rd_valid,
	io_erase_valid,
        io_inst,
        io_addr,
        io_inst_size,
        io_inst_burstlen,
        io_dummy_size,
        io_dummy_burstlen,
        io_addr_size,
        io_addr_burstlen,
        io_data_size,
        io_data_burstlen,
	io_addr_mode_en,
	io_addr_spi_mode,
	io_addr_dpi_mode,
	io_data_mode_en,
	io_data_spi_mode,
	io_data_dpi_mode

);
input clock;
input rst_n;
	//to control level 
output io_tran_inst_label;
        //signal from module cmd_gen
input io_buf_req_valid;
output io_buf_req_ready;
input [7:0] io_buf_req_inst;
input io_buf_req_inst_label ;
input io_buf_req_wr_en;
input io_buf_req_rd_en;
input io_buf_req_addr_en;
input io_buf_req_erase_en;
input [23:0] io_buf_req_addr;
input [7:0] io_buf_req_data_size;
input [7:0] io_buf_req_data_burstlen;
input io_buf_req_dummy_en;
input [7:0] io_buf_req_dummy_size;
input [7:0] io_buf_req_dummy_burstlen;
input io_buf_req_addr_mode_en;
input io_buf_req_addr_spi_mode;
input io_buf_req_addr_dpi_mode;
input io_buf_req_data_mode_en;
input io_buf_req_data_spi_mode;
input io_buf_req_data_dpi_mode;

//signal to module fsm  or tran_rec
output io_start_signal; //to start tran flash req
input  io_next_req;  //from fsm, for next flash req
output io_dummy_valid;
output io_addr_valid;
output io_wr_valid;
output io_rd_valid;
output io_erase_valid ;
output [7:0] io_inst;
output [23:0] io_addr;
output [7:0] io_inst_size;
output [7:0] io_inst_burstlen;
output [7:0] io_dummy_size;
output [7:0] io_dummy_burstlen;
output [7:0] io_addr_size;
output [7:0] io_addr_burstlen;
output [7:0] io_data_size;
output [7:0] io_data_burstlen;
output io_addr_mode_en;
output io_addr_spi_mode;
output io_addr_dpi_mode;
output io_data_mode_en;
output io_data_spi_mode;
output io_data_dpi_mode;

wire fifo_wen ;
assign fifo_wen = io_buf_req_valid & io_buf_req_ready ;

//inst fifo:
//	{erase_en,inst_label,inst,wr_en,rd_en,addr_en,dummy_en}
//dw:	1+1+8+4
//aw:   4 
wire [15: 0 ]  inst_fifo_rdata;
wire inst_fifo_full;
wire inst_fifo_empty;
wire [1:0] inst_fifo_level;
qspi_info_fifo #(.dw(16),.aw(5)) U_inst_fifo
(	
        .clk(clock),
        .rst(rst_n),
        .clr(~rst_n),
        .din({2'b0,io_buf_req_erase_en,io_buf_req_inst_label,io_buf_req_inst,io_buf_req_wr_en,io_buf_req_rd_en,io_buf_req_addr_en,io_buf_req_dummy_en}),
        .we(fifo_wen),
        .dout(inst_fifo_rdata),
        .re(io_next_req),
        .full(inst_fifo_full),
        .empty(inst_fifo_empty),
        .level(inst_fifo_level)
);

assign io_start_signal = ~inst_fifo_empty;
assign io_wr_valid = ~inst_fifo_empty & inst_fifo_rdata[3];
assign io_rd_valid = ~inst_fifo_empty & inst_fifo_rdata[2];
assign io_addr_valid = ~inst_fifo_empty & inst_fifo_rdata [1];
assign io_dummy_valid = ~inst_fifo_empty & inst_fifo_rdata[0];
assign io_inst = inst_fifo_rdata[11 : 4];
assign io_tran_inst_label = inst_fifo_rdata[12] ;
assign io_erase_valid = inst_fifo_rdata[13];
assign io_inst_size = 8'b00010 ;
assign io_inst_burstlen = 8'b1 ;

//addr fifo
//	{io_buf_req_addr,addr_mode_en,addr_spi_mode,addr_dpi_mode}
//dw:	24 + 3
//aw:	3
wire [31: 0 ]  addr_fifo_rdata;
wire addr_fifo_full;
wire addr_fifo_empty;
wire [1:0] addr_fifo_level;
qspi_addr_fifo  #(.dw( 32  ),.aw(5)) U_addr_fifo
(
        .clk(clock),
        .rst(rst_n),
        .clr(~rst_n),
        .din({5'b0,io_buf_req_addr,io_buf_req_addr_mode_en,io_buf_req_addr_spi_mode,io_buf_req_addr_dpi_mode}),
        .we(fifo_wen),
        .dout(addr_fifo_rdata),
        .re(io_next_req),
        .full(addr_fifo_full),
        .empty(addr_fifo_empty),
        .level(addr_fifo_level)
);
assign io_addr = addr_fifo_rdata[26:3] ;
assign io_addr_mode_en = addr_fifo_rdata[2];
assign io_addr_spi_mode = addr_fifo_rdata[1] ;
assign io_addr_dpi_mode = addr_fifo_rdata[0];

//addr size & burstlen
assign io_addr_size = 8'b00110; 
assign io_addr_burstlen = 8'b1; 



//data info fifo
//	{data_size,data_burstlen,data_mode_en,data_spi_mode,data_dpi_mode}
//dw:	8+8+3
//aw:	5

wire [31 : 0 ]  data_info_fifo_rdata;
wire data_info_fifo_full;
wire data_info_fifo_empty;
wire [1:0] data_info_fifo_level;


qspi_addr_fifo  #(.dw( 32  ),.aw(5)) U_data_info_fifo
(
        .clk(clock),
        .rst(rst_n),
        .clr(~rst_n),
        .din({13'b0,io_buf_req_data_size,io_buf_req_data_burstlen,io_buf_req_data_mode_en,io_buf_req_data_spi_mode,io_buf_req_data_dpi_mode}),
        .we(fifo_wen),
        .dout(data_info_fifo_rdata),
        .re(io_next_req),
        .full(data_info_fifo_full),
        .empty(data_info_fifo_empty),
        .level(data_info_fifo_level)
);

assign io_data_size =  data_info_fifo_rdata[18:11];
assign io_data_burstlen = data_info_fifo_rdata[10:3];
assign io_data_mode_en = data_info_fifo_rdata[2];
assign io_data_spi_mode =  data_info_fifo_rdata[1];
assign io_data_dpi_mode = data_info_fifo_rdata[0];


//dummy info fifo
//	{dummy_size,dummy_burstlen}
//dw	8+8
//aw	3
wire [15: 0 ]  dummy_info_fifo_rdata;
wire dummy_info_fifo_full;
wire dummy_info_fifo_empty;
wire [1:0] dummy_info_fifo_level;

qspi_info_fifo   #(.dw( 16 ),.aw(5)) U_dummy_info_fifo
(
        .clk(clock),
        .rst(rst_n),
        .clr(~rst_n),
        .din({io_buf_req_dummy_size,io_buf_req_dummy_burstlen}),
        .we(fifo_wen),
        .dout(dummy_info_fifo_rdata),
        .re(io_next_req),
        .full(dummy_info_fifo_full),
        .empty(dummy_info_fifo_empty),
        .level(dummy_info_fifo_level)
);


assign io_dummy_size = dummy_info_fifo_rdata[15:8];
assign io_dummy_burstlen = dummy_info_fifo_rdata[7:0] ;


//add fence
//	when then inst is eqpi/edpi/qpidi/dpidi 
//		the spi/dpi/mode will change 
//			it will change the dummy clock 
//	so need to add fence when meet this instrcution
reg inst_fence_r;
wire inst_fence_pre;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		inst_fence_r <= 1'b0;
	else
		inst_fence_r <= inst_fence_pre;
`ifdef N25Q128
assign inst_fence_pre = io_next_req & (io_inst == `WRVECR)? 1'b0 :
			(io_buf_req_inst == `WRVECR) ? 1'b1 :
			 inst_fence_r;
`endif
`ifdef IS25LP128
assign inst_fence_pre = io_next_req & ((io_inst == `QPIEN) | (io_inst == `QPIDI) | (io_inst == `WRSR) ) ? 1'b0 :
			(io_buf_req_inst == `QPIEN) | (io_buf_req_inst == `QPIDI) | (io_buf_req_inst == `WRSR) ? 1'b1 :
			 inst_fence_r;
`endif
//ready signal 

assign io_buf_req_ready = ~(inst_fifo_full | addr_fifo_full | data_info_fifo_full | dummy_info_fifo_full | inst_fence_r) ;


//simulation model
`ifdef QSPI_SIM 

integer inst_seq_log;
integer inst_clock_log;
reg	inst_report_flag;

wire qspi_ctrl_spi_mode = top.dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_tran_level.U_tran_qspi_mode_ctrl.io_tran_spi_mode;
wire qspi_ctrl_dpi_mode = top.dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_tran_level.U_tran_qspi_mode_ctrl.io_tran_dpi_mode;

wire[7:0] inst_hb_clk = qspi_ctrl_spi_mode ? 8'h4 :
			qspi_ctrl_dpi_mode ? 8'h2 :
			8'h1; 

wire[7:0] addr_hb_clk = io_addr_mode_en ? (io_addr_spi_mode ? 8'h4 : io_addr_dpi_mode ? 8'h2 : 8'h1) :
			inst_hb_clk;
wire[7:0] data_hb_clk = io_data_mode_en ? (io_data_spi_mode ? 8'h4 : io_data_dpi_mode ? 8'h2 : 8'h1) :
			inst_hb_clk;
initial begin
	inst_seq_log = $fopen("../sim_log/qspi_inst_buffer->inst_seq.log");
	inst_clock_log = $fopen("../sim_log/qspi_inst_buffer->inst_clock.log");
end

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		;
	else begin
		if(io_next_req)
		begin
			//print sequence of inst 
			$fwrite(inst_seq_log,"Inst[%h] Addr[%h]\n",io_inst,io_addr);
			$fwrite(inst_seq_log,"\tINST");
			if(io_addr_valid)
				$fwrite(inst_seq_log,"==>ADDR");
			if(io_wr_valid)
				$fwrite(inst_seq_log,"==>WR_DATA");
			if(io_dummy_valid)
				$fwrite(inst_seq_log,"==>RD_DUMMY");
			if(io_rd_valid)
				$fwrite(inst_seq_log,"==>RD_DATA");
			$fwrite(inst_seq_log,"\n");
			//print clock of per section
			$fwrite(inst_clock_log,"Inst[%h],Addr[%h]\n",io_inst,io_addr);
			$fwrite(inst_clock_log,"\tSckInst[%0d],",io_inst_size*io_inst_burstlen*inst_hb_clk);
			if(io_addr_valid)
				$fwrite(inst_clock_log,"\tSckAddr[%0d],",io_addr_size*io_addr_burstlen*addr_hb_clk);
			if(io_dummy_valid)
				$fwrite(inst_clock_log,"SckDummy[%0d],",io_dummy_size*io_dummy_burstlen*inst_hb_clk);
			if(io_wr_valid | io_rd_valid)
				$fwrite(inst_clock_log,"SckData[%0d],",io_data_size*io_data_burstlen*data_hb_clk);
			$fwrite(inst_clock_log,"\n");

		end
	end

always@(posedge clock or negedge rst_n)
	if(!rst_n) 
		inst_report_flag <= 1'b0;
	else if(io_next_req)
		inst_report_flag <= 1'b0 ;
	else if(io_start_signal)
		inst_report_flag <= 1'b1 ;
reg start_signal;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		start_signal <= 1'b0;
	else
		start_signal <= ~inst_report_flag & io_start_signal	;
always@(posedge clock)
	if(start_signal)
		$display("QSPI_REQ: Inst=[%h] Addr_valid=[%b] Rd_valid=[%d] Wr_valid = [%b]",io_inst,io_addr_valid,io_rd_valid,io_wr_valid);

`endif

endmodule
