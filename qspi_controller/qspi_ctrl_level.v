# See LICENSE for license details.

module qspi_ctrl_level
(
	clock,
	rst_n,
// from tran level to control level 
        io_tran_spi_mode,
        io_tran_dpi_mode,
	io_tran_inst_label,
// from interface level to control level
	io_interface_lev_wren, 
        io_dchan_req_valid,
        io_dchan_req_ready,
        io_dchan_req_data_size,
        io_dchan_req_data_burstlen,
        io_dchan_req_inst,
        io_dchan_req_addr,
//to interface level 
        io_ctrl_lev_inst_label,
        io_ctrl_lev_inst_valid,
        io_ctrl_lev_wr_en,	

        io_dchan_tdata_fifo_wen,
        io_dchan_tdata_fifo_wdata,
        io_dchan_tdata_fifo_full,

        io_dchan_rdata_fifo_ren,
        io_dchan_rdata_fifo_rdata,
        io_dchan_rdata_fifo_empty,

        io_cchan_req_valid,
        io_cchan_req_ready,
        io_cchan_req_data_size,
        io_cchan_req_data_burstlen,
        io_cchan_req_inst,
        io_cchan_req_addr,

// resp the cchan the inst error to create a interrupt
        io_cchan_resp_valid,
        io_cchan_resp_error,
        io_cchan_resp_cause,

        io_cchan_tdata_fifo_wen,
        io_cchan_tdata_fifo_wdata,
        io_cchan_tdata_fifo_full,

        io_cchan_rdata_fifo_ren,
        io_cchan_rdata_fifo_rdata,
        io_cchan_rdata_fifo_empty,
//data lock 
	io_tdata_lock,
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
        io_rdata_fifo_empty



);
input clock;
input rst_n;

input io_tran_inst_label;
input  io_tran_spi_mode;
input  io_tran_dpi_mode;

output io_ctrl_lev_inst_label;
output io_ctrl_lev_inst_valid;
output io_ctrl_lev_wr_en;

input io_interface_lev_wren;

input io_dchan_req_valid;
output io_dchan_req_ready;
input [7:0] io_dchan_req_data_size;
input [7:0] io_dchan_req_data_burstlen;
input [7:0] io_dchan_req_inst;
input [23:0] io_dchan_req_addr;

input io_dchan_tdata_fifo_wen;
input [31 : 0 ] io_dchan_tdata_fifo_wdata;
output io_dchan_tdata_fifo_full;

input io_dchan_rdata_fifo_ren;
output [31 : 0 ] io_dchan_rdata_fifo_rdata;
output io_dchan_rdata_fifo_empty;

input io_cchan_req_valid;
output io_cchan_req_ready;
input [7:0] io_cchan_req_data_size;
input [7:0] io_cchan_req_data_burstlen;
input [7:0] io_cchan_req_inst;
input [23:0] io_cchan_req_addr;

// resp the cchan the inst error to create a interrupt
output io_cchan_resp_valid;
output io_cchan_resp_error;
output [1:0] io_cchan_resp_cause;

input io_cchan_tdata_fifo_wen;
input [31 : 0 ] io_cchan_tdata_fifo_wdata;
output io_cchan_tdata_fifo_full;

input io_cchan_rdata_fifo_ren;
output [31 : 0 ] io_cchan_rdata_fifo_rdata;
output io_cchan_rdata_fifo_empty;

//data lock 
input io_tdata_lock;
//tran/rec data fifo interface 
output io_tdata_fifo_wen;
output[31 : 0 ] io_tdata_fifo_wdata;
input  io_tdata_fifo_full;

output io_rdata_fifo_ren;
input [31 : 0 ] io_rdata_fifo_rdata;
input io_rdata_fifo_empty;


// from control level to tran level 
output io_buf_req_valid;
input io_buf_req_ready;
output [7:0] io_buf_req_inst;
output io_buf_req_inst_label;
output io_buf_req_wr_en;
output io_buf_req_rd_en;
output io_buf_req_addr_en;
output io_buf_req_erase_en;
output [23:0] io_buf_req_addr;
output [7:0] io_buf_req_data_size;
output [7:0] io_buf_req_data_burstlen;
output io_buf_req_dummy_en;
output [7:0] io_buf_req_dummy_size;
output [7:0] io_buf_req_dummy_burstlen;
output io_buf_req_addr_mode_en;
output io_buf_req_addr_spi_mode;
output io_buf_req_addr_dpi_mode;
output io_buf_req_data_mode_en;
output io_buf_req_data_spi_mode;
output io_buf_req_data_dpi_mode;




//to qspi_inst_decode module
wire flash_req_valid;
wire flash_req_ready;
wire [7:0] flash_req_inst;
wire flash_req_inst_label;
wire [7:0] flash_req_data_size;
wire [7:0] flash_req_data_burstlen;
wire [23:0] flash_req_addr;

wire flash_resp_valid;
wire flash_resp_error;
wire [1:0] flash_resp_cause;

	
qspi_inst_arbiter U_ctrl_qspi_inst_arbiter (
        .clock(clock),
        .rst_n(rst_n),
//from tran level
        .io_tran_inst_label(io_tran_inst_label),
//from interface level 
        .io_dchan_req_valid(io_dchan_req_valid),
        .io_dchan_req_ready(io_dchan_req_ready),
        .io_dchan_req_data_size(io_dchan_req_data_size),
        .io_dchan_req_data_burstlen(io_dchan_req_data_burstlen),
        .io_dchan_req_inst(io_dchan_req_inst),
        .io_dchan_req_addr(io_dchan_req_addr),

	.io_tdata_lock(io_tdata_lock),
        .io_dchan_tdata_fifo_wen(io_dchan_tdata_fifo_wen),
        .io_dchan_tdata_fifo_wdata(io_dchan_tdata_fifo_wdata),
        .io_dchan_tdata_fifo_full(io_dchan_tdata_fifo_full),

        .io_dchan_rdata_fifo_ren(io_dchan_rdata_fifo_ren),
        .io_dchan_rdata_fifo_rdata(io_dchan_rdata_fifo_rdata),
        .io_dchan_rdata_fifo_empty(io_dchan_rdata_fifo_empty),

        .io_cchan_req_valid(io_cchan_req_valid),
        .io_cchan_req_ready(io_cchan_req_ready),
        .io_cchan_req_data_size(io_cchan_req_data_size),
        .io_cchan_req_data_burstlen(io_cchan_req_data_burstlen),
        .io_cchan_req_inst(io_cchan_req_inst),
        .io_cchan_req_addr(io_cchan_req_addr),

// resp the cchan the inst error to create a interrupt
        .io_cchan_resp_valid(io_cchan_resp_valid),
        .io_cchan_resp_error(io_cchan_resp_error),
        .io_cchan_resp_cause(io_cchan_resp_cause),

        .io_cchan_tdata_fifo_wen(io_cchan_tdata_fifo_wen),
        .io_cchan_tdata_fifo_wdata(io_cchan_tdata_fifo_wdata),
        .io_cchan_tdata_fifo_full(io_cchan_tdata_fifo_full),

        .io_cchan_rdata_fifo_ren(io_cchan_rdata_fifo_ren),
        .io_cchan_rdata_fifo_rdata(io_cchan_rdata_fifo_rdata),
        .io_cchan_rdata_fifo_empty(io_cchan_rdata_fifo_empty),

//to qspi_inst_decode module
        .io_flash_req_valid(flash_req_valid),
        .io_flash_req_ready(flash_req_ready),
        .io_flash_req_inst(flash_req_inst),
        .io_flash_req_data_size(flash_req_data_size),
        .io_flash_req_data_burstlen(flash_req_data_burstlen),
	.io_flash_req_addr(flash_req_addr),
//instrcution label
//      0:cchannel inst
//      1:dchannel inst
        .io_flash_req_inst_label(flash_req_inst_label),

        .io_flash_resp_valid(flash_resp_valid),
        .io_flash_resp_error(flash_resp_error),
        .io_flash_resp_cause(flash_resp_cause),
 
        .io_tdata_fifo_wen(io_tdata_fifo_wen),
        .io_tdata_fifo_wdata(io_tdata_fifo_wdata),
        .io_tdata_fifo_full(io_tdata_fifo_full),

        .io_rdata_fifo_ren(io_rdata_fifo_ren),
        .io_rdata_fifo_rdata(io_rdata_fifo_rdata),
        .io_rdata_fifo_empty(io_rdata_fifo_empty)

);


qspi_inst_decode U_ctrl_qspi_inst_decode
(
        .clock(clock),
        .rst_n(rst_n),
	.io_interface_lev_wren(io_interface_lev_wren),
        .io_ctrl_lev_inst_label(io_ctrl_lev_inst_label),
        .io_ctrl_lev_inst_valid(io_ctrl_lev_inst_valid),
        .io_ctrl_lev_wr_en(io_ctrl_lev_wr_en),

        .io_flash_req_valid(flash_req_valid),
        .io_flash_req_ready(flash_req_ready),
        .io_flash_req_inst(flash_req_inst),
	.io_flash_req_inst_label(flash_req_inst_label),
        .io_flash_req_data_size(flash_req_data_size),
        .io_flash_req_data_burstlen(flash_req_data_burstlen),
	.io_flash_req_addr(flash_req_addr),
        .io_flash_resp_valid(flash_resp_valid),
        .io_flash_resp_error(flash_resp_error),
        .io_flash_resp_cause(flash_resp_cause),

//from control level to tran level
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
 // from tran level
        .io_tran_spi_mode(io_tran_spi_mode),
        .io_tran_dpi_mode(io_tran_dpi_mode)


);


endmodule
