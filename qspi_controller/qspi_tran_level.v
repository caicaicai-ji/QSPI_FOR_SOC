# See LICENSE for license details.
module qspi_tran_level 
(
	clock,
	rst_n,
//to control level signal
	io_tran_inst_label,
        io_tran_spi_mode,
        io_tran_dpi_mode,
//from interface level 
	io_clk_divide_param,
	io_interface_lev_wren,
//from control level to tran level
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



//tran data fifo interface
        io_tdata_fifo_wen,
        io_tdata_fifo_wdata,
        io_tdata_fifo_full,
//rec data fifo interface
        io_rdata_fifo_ren,
        io_rdata_fifo_rdata,
        io_rdata_fifo_empty,

//qspi io
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

output io_tran_inst_label;

input [31:0] io_clk_divide_param ;
input io_interface_lev_wren;
//tran data fifo interface
input  io_tdata_fifo_wen;
input  [31 : 0 ] io_tdata_fifo_wdata;
output io_tdata_fifo_full;

input  io_rdata_fifo_ren;
output [31 : 0 ] io_rdata_fifo_rdata;
output io_rdata_fifo_empty;

input io_buf_req_valid;
output io_buf_req_ready;
input [7:0] io_buf_req_inst;
input io_buf_req_inst_label;
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

output io_tran_spi_mode ;
output io_tran_dpi_mode ;

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

wire spi_mode ;
wire dpi_mode ;

wire start_signal; //to start tran flash req
wire  next_req;  //from fsm, for next flash req
wire dummy_valid;
wire addr_valid;
wire wr_valid;
wire rd_valid;
wire erase_valid;
wire [7:0] inst;
wire [23:0] addr;
wire [7:0] inst_size;
wire [7:0] inst_burstlen;
wire [7:0] dummy_size;
wire [7:0] dummy_burstlen;
wire [7:0] addr_size;
wire [7:0] addr_burstlen;
wire [7:0] data_size;
wire [7:0] data_burstlen;
wire addr_mode_en;
wire addr_spi_mode;
wire addr_dpi_mode;
wire data_mode_en;
wire data_spi_mode;
wire data_dpi_mode;



wire tran_finish;
//state of fsm
wire state_free;
wire state_ready;
wire state_wren;
wire state_wren_way;
wire state_req;
wire state_addr;
wire state_rd_dummy;
wire state_wr_data;
wire state_wr_csr;
wire state_rd;
wire state_wait_check;
wire state_check;
wire state_check_fail;
wire state_finish;

wire state_check_way;
wire check_pass;


wire qspi_data_en ;

wire [7:0] csr_data;


qspi_inst_buffer U_tran_qspi_inst_buffer
(
        .clock(clock),
        .rst_n(rst_n),
	//to control level 
	.io_tran_inst_label(io_tran_inst_label),
        //signal from module cmd_gen
        .io_buf_req_valid(io_buf_req_valid),
        .io_buf_req_ready(io_buf_req_ready),
        .io_buf_req_inst(io_buf_req_inst),
	.io_buf_req_inst_label(io_buf_req_inst_label),
        .io_buf_req_wr_en(io_buf_req_wr_en),
        .io_buf_req_rd_en(io_buf_req_rd_en),
        .io_buf_req_addr_en(io_buf_req_addr_en),
	.io_buf_req_erase_en(io_buf_req_erase_en),
        .io_buf_req_addr(io_buf_req_addr),
        .io_buf_req_data_size(io_buf_req_data_size),
        .io_buf_req_data_burstlen(io_buf_req_data_burstlen),
        .io_buf_req_dummy_en(io_buf_req_dummy_en),
        .io_buf_req_dummy_size(io_buf_req_dummy_size),
        .io_buf_req_dummy_burstlen(io_buf_req_dummy_burstlen),
        .io_buf_req_addr_mode_en(io_buf_req_addr_mode_en),
        .io_buf_req_addr_spi_mode(io_buf_req_addr_spi_mode),
        .io_buf_req_addr_dpi_mode(io_buf_req_addr_dpi_mode),
        .io_buf_req_data_mode_en(io_buf_req_data_mode_en),
        .io_buf_req_data_spi_mode(io_buf_req_data_spi_mode),
        .io_buf_req_data_dpi_mode(io_buf_req_data_dpi_mode),

        //signal to module fsm  or tran_rec
        .io_start_signal(start_signal), //to start tran flash req
        .io_next_req(next_req),  // from fsm for next req
        .io_dummy_valid(dummy_valid),
        .io_addr_valid(addr_valid),
        .io_wr_valid(wr_valid),
        .io_rd_valid(rd_valid),
	.io_erase_valid(erase_valid),
        .io_inst(inst),
        .io_addr(addr),
        .io_inst_size(inst_size),
        .io_inst_burstlen(inst_burstlen),
        .io_dummy_size(dummy_size),
        .io_dummy_burstlen(dummy_burstlen),
        .io_addr_size(addr_size),
        .io_addr_burstlen(addr_burstlen),
        .io_data_size(data_size),
        .io_data_burstlen(data_burstlen),
	.io_addr_mode_en(addr_mode_en),
	.io_addr_spi_mode(addr_spi_mode),
	.io_addr_dpi_mode(addr_dpi_mode),
	.io_data_mode_en(data_mode_en),
	.io_data_spi_mode(data_spi_mode),
	.io_data_dpi_mode(data_dpi_mode)
	
);

qspi_fsm U_tran_qspi_fsm(
        .clock(clock),
        .rst_n(rst_n),

	.io_interface_lev_wren(io_interface_lev_wren),

        .io_start_signal(start_signal), //to start tran flash req
        .io_next_req(next_req),  // for next req

        .io_dummy_valid(dummy_valid),
        .io_addr_valid(addr_valid),
        .io_wr_valid(wr_valid),
        .io_rd_valid(rd_valid),
	.io_erase_valid(erase_valid),

        .io_tran_finish(tran_finish),
        .io_state_free(state_free),
        .io_state_ready(state_ready),
	.io_state_wren(state_wren),
	.io_state_wren_way(state_wren_way),
        .io_state_req(state_req),
        .io_state_addr(state_addr),
        .io_state_rd_dummy(state_rd_dummy),
        .io_state_wr_csr(state_wr_csr),
        .io_state_wr_data(state_wr_data),
	.io_state_wait_check(state_wait_check),
        .io_state_check(state_check),
	.io_state_check_fail(state_check_fail),
        .io_state_rd(state_rd),
        .io_state_check_way(state_check_way),
	.io_state_finish(state_finish),
        .io_check_pass(check_pass)

);

qspi_clk_divider U_tran_qspi_clk_divider(
	.clock(clock),
	.rst_n(rst_n),
	.io_start_signal(start_signal),
	.io_cchan_divide(io_clk_divide_param),
	.io_qspi_data_en(qspi_data_en)
);

qspi_mode_ctrl U_tran_qspi_mode_ctrl
(
        .clock(clock),
        .rst_n(rst_n),
	.io_state_addr(state_addr),
        .io_state_wr_data(state_wr_data),
        .io_state_rd(state_rd),
        .io_addr_mode_en(addr_mode_en),
        .io_addr_spi_mode(addr_spi_mode),
        .io_addr_dpi_mode(addr_dpi_mode),
        .io_data_mode_en(data_mode_en),
        .io_data_spi_mode(data_spi_mode),
        .io_data_dpi_mode(data_dpi_mode),
        .io_start_signal(start_signal),
        .io_next_req(next_req),
        .io_inst(inst),
        .io_csr_data(csr_data),
        .io_spi_mode(spi_mode),
        .io_dpi_mode(dpi_mode),
	.io_tran_spi_mode(io_tran_spi_mode),
	.io_tran_dpi_mode(io_tran_dpi_mode)
);

qspi_tran_rec U_tran_qspi_tran_rec(
        .clock(clock),
        .rst_n(rst_n),
        .io_qspi_data_en(qspi_data_en),
//fsm state
        .io_state_free(state_free),
        .io_state_ready(state_ready),
	.io_state_wren(state_wren),
	.io_state_wren_way(state_wren_way),
        .io_state_req(state_req),
        .io_state_addr(state_addr),
        .io_state_rd_dummy(state_rd_dummy),
        .io_state_rd(state_rd),
        .io_state_wr_data(state_wr_data),
        .io_state_wr_csr(state_wr_csr),
        .io_state_check(state_check),
	.io_state_wait_check(state_wait_check),
	.io_state_check_fail(state_check_fail),
	.io_state_finish(state_finish),
        .io_state_check_way(state_check_way),
//tran signal
        .io_inst(inst),
        .io_addr(addr),
        .io_inst_size(inst_size),
        .io_inst_burstlen(inst_burstlen),
        .io_addr_size(addr_size),
        .io_addr_burstlen(addr_burstlen),
        .io_data_size(data_size),
        .io_data_burstlen(data_burstlen),
        .io_dummy_size(dummy_size),
        .io_dummy_burstlen(dummy_burstlen),
        .io_dummy_valid(dummy_valid),
        .io_addr_valid(addr_valid),
        .io_wr_valid(wr_valid),
        .io_rd_valid(rd_valid),
	.io_erase_valid(erase_valid),

        .io_dpi_mode(dpi_mode),
        .io_spi_mode(spi_mode),
        .io_tran_finish(tran_finish),
        .io_check_pass(check_pass),
//tran data fifo interface
        .io_tdata_fifo_wen(io_tdata_fifo_wen),
        .io_tdata_fifo_wdata(io_tdata_fifo_wdata),
        .io_tdata_fifo_full(io_tdata_fifo_full),
//rec data fifo interface
        .io_rdata_fifo_ren(io_rdata_fifo_ren),
        .io_rdata_fifo_rdata(io_rdata_fifo_rdata),
        .io_rdata_fifo_empty(io_rdata_fifo_empty),
	.io_csr_data(csr_data),
        .io_qspi_ce(io_qspi_ce),
        .io_qspi_oe0(io_qspi_oe0),
        .io_qspi_so0(io_qspi_so0),
        .io_qspi_si0(io_qspi_si0),
        .io_qspi_oe1(io_qspi_oe1),
        .io_qspi_so1(io_qspi_so1),
        .io_qspi_si1(io_qspi_si1),
        .io_qspi_oe2(io_qspi_oe2),
        .io_qspi_so2(io_qspi_so2),
        .io_qspi_si2(io_qspi_si2),
        .io_qspi_oe3(io_qspi_oe3),
        .io_qspi_so3(io_qspi_so3),
        .io_qspi_si3(io_qspi_si3),
        .io_qspi_sck(io_qspi_sck)
);

endmodule
