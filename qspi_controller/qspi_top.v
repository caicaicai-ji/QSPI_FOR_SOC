# See LICENSE for license details.
module qspi_top(
//data channel 
	clock,
	rst_n,
	io_qspi_interrupt,
`ifdef AXI4
        io_axi4_0_aw_ready,
        io_axi4_0_aw_valid,
        io_axi4_0_aw_bits_addr,
        io_axi4_0_aw_bits_id,
        io_axi4_0_aw_bits_len,
        io_axi4_0_aw_bits_size,
        io_axi4_0_aw_bits_burst,
        io_axi4_0_aw_bits_lock,
        io_axi4_0_aw_bits_cache,
        io_axi4_0_aw_bits_prot,
        io_axi4_0_aw_bits_qos,
        io_axi4_0_w_ready,
        io_axi4_0_w_valid,
        io_axi4_0_w_bits_data,
        io_axi4_0_w_bits_strb,
        io_axi4_0_w_bits_last,
        io_axi4_0_b_ready,
        io_axi4_0_b_valid,
        io_axi4_0_b_bits_id,
        io_axi4_0_b_bits_resp,
        io_axi4_0_ar_ready,
        io_axi4_0_ar_valid,
        io_axi4_0_ar_bits_id,
        io_axi4_0_ar_bits_addr,
        io_axi4_0_ar_bits_len,
        io_axi4_0_ar_bits_size,
        io_axi4_0_ar_bits_burst,
        io_axi4_0_ar_bits_lock,
        io_axi4_0_ar_bits_cache,
        io_axi4_0_ar_bits_prot,
        io_axi4_0_ar_bits_qos,
        io_axi4_0_r_ready,
        io_axi4_0_r_valid,
        io_axi4_0_r_bits_id,
        io_axi4_0_r_bits_data,
        io_axi4_0_r_bits_resp,
        io_axi4_0_r_bits_last,
`endif
//control channel 
	hsel_s,
        haddr_s,
        hsize_s,
        htrans_s,
        hwrite_s,
        hrdata_s,
        hwdata_s,
        hready_s,
        hresp_s,
//qspi inout
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

input clock ;
input rst_n;
output io_qspi_interrupt;
`ifdef AXI4
output  io_axi4_0_aw_ready;
input   io_axi4_0_aw_valid;
input   [`MEM_AWIDTH - 1 : 0 ]  io_axi4_0_aw_bits_addr;
input   [3:0] io_axi4_0_aw_bits_id;
input   [7:0] io_axi4_0_aw_bits_len;
input   [2:0] io_axi4_0_aw_bits_size;
input   [1:0] io_axi4_0_aw_bits_burst;
input   io_axi4_0_aw_bits_lock;
input   [3:0] io_axi4_0_aw_bits_cache;
input   [2:0] io_axi4_0_aw_bits_prot;
input   [3:0] io_axi4_0_aw_bits_qos;
output  io_axi4_0_w_ready;
input   io_axi4_0_w_valid;
input   [`BUS_WIDTH - 1 : 0] io_axi4_0_w_bits_data;
`ifdef X128
input   [15:0] io_axi4_0_w_bits_strb ;
`else
	`ifdef X64
input   [7:0] io_axi4_0_w_bits_strb;
	`else
input   [3:0] io_axi4_0_w_bits_strb;
	`endif
`endif
input   io_axi4_0_w_bits_last;
input   io_axi4_0_b_ready;
output  io_axi4_0_b_valid;
output  [3:0] io_axi4_0_b_bits_id;
output  [1:0] io_axi4_0_b_bits_resp;
output  io_axi4_0_ar_ready;
input   io_axi4_0_ar_valid;
input   [3:0] io_axi4_0_ar_bits_id;
input   [`MEM_AWIDTH - 1 :0]io_axi4_0_ar_bits_addr;
input   [7:0] io_axi4_0_ar_bits_len;
input   [2:0] io_axi4_0_ar_bits_size;
input   [1:0] io_axi4_0_ar_bits_burst;
input   io_axi4_0_ar_bits_lock;
input   [3:0] io_axi4_0_ar_bits_cache;
input   [2:0] io_axi4_0_ar_bits_prot;
input   [3:0] io_axi4_0_ar_bits_qos;
input   io_axi4_0_r_ready;
output  io_axi4_0_r_valid;
output  [3:0] io_axi4_0_r_bits_id;
output  [`BUS_WIDTH - 1 : 0 ] io_axi4_0_r_bits_data;
output  [1:0] io_axi4_0_r_bits_resp;
output  io_axi4_0_r_bits_last;
`endif


input hsel_s;
input [4:0] haddr_s;
input [2:0] hsize_s;
input [1:0] htrans_s;
input hwrite_s;
output [31:0] hrdata_s;
input [31 :0 ] hwdata_s;
output  hready_s;
output hresp_s;

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


///////////////////////////////////////////////////////////////
//qspi_intertface_level 

wire  dchan_req_valid;
wire   dchan_req_ready;
wire  [7:0] dchan_req_data_size;
wire  [7:0] dchan_req_data_burstlen;
wire  [7:0] dchan_req_inst;
wire  [23:0] dchan_req_addr;

wire tdata_lock;
wire dchan_tdata_fifo_wen;
wire [31 : 0 ] dchan_tdata_fifo_wdata;
wire dchan_tdata_fifo_full;

wire dchan_rdata_fifo_ren;
wire [31 : 0 ] dchan_rdata_fifo_rdata ;
wire dchan_rdata_fifo_empty;


wire  cchan_req_valid;
wire   cchan_req_ready;
wire [7:0] cchan_req_data_size;
wire [7:0] cchan_req_data_burstlen;
wire [7:0] cchan_req_inst;
wire [23:0] cchan_req_addr;
//data
wire cchan_tdata_fifo_wen;
wire [31 : 0 ] cchan_tdata_fifo_wdata;
wire  cchan_tdata_fifo_full;

wire cchan_rdata_fifo_ren;
wire  [31 : 0 ] cchan_rdata_fifo_rdata;
wire  cchan_rdata_fifo_empty;
//exceptta_lockion
wire  cchan_resp_valid;
wire  cchan_resp_error;
wire [1:0] cchan_resp_cause;

//from tran_level
wire   tran_spi_mode;
wire   tran_dpi_mode;
wire   tran_inst_label;
//from ctrl level 
wire ctrl_lev_inst_label;
wire ctrl_lev_inst_valid;
wire ctrl_lev_wr_en; 

//tran/rec data fifo interface
wire tdata_fifo_wen;
wire[31 : 0 ] tdata_fifo_wdata;
wire  tdata_fifo_full;

wire rdata_fifo_ren;
wire [31 : 0 ] rdata_fifo_rdata;
wire rdata_fifo_empty;


// from control level to tran level
wire buf_req_valid;
wire buf_req_ready;
wire [7:0] buf_req_inst;
wire buf_req_wr_en;
wire buf_req_rd_en;
wire buf_req_addr_en;
wire buf_req_erase_en;
wire [23:0] buf_req_addr;
wire [7:0] buf_req_data_size;
wire [7:0] buf_req_data_burstlen;
wire buf_req_dummy_en;
wire [7:0] buf_req_dummy_size;
wire [7:0] buf_req_dummy_burstlen;
wire buf_req_addr_mode_en;
wire buf_req_addr_spi_mode;
wire buf_req_addr_dpi_mode;
wire buf_req_data_mode_en;
wire buf_req_data_spi_mode;
wire buf_req_data_dpi_mode;
wire buf_req_inst_label;

wire [31:0] clk_divide_param;
wire interface_lev_wren;









qspi_interface_level U_qspi_interface_level
(
        .clock(clock),
        .rst_n(rst_n),
        .io_clk_divide_param(clk_divide_param),
	.io_interface_lev_wren(interface_lev_wren),
// ctrl channel
        .hsel_s(hsel_s),
        .haddr_s(haddr_s),
        .hsize_s(hsize_s),
        .htrans_s(htrans_s),
        .hwrite_s(hwrite_s),
        .hrdata_s(hrdata_s),
        .hwdata_s(hwdata_s),
        .hready_s(hready_s),
        .hresp_s(hresp_s),
//data channel
`ifdef AXI4
        .io_axi4_0_aw_ready(io_axi4_0_aw_ready),
        .io_axi4_0_aw_valid(io_axi4_0_aw_valid),
        .io_axi4_0_aw_bits_addr(io_axi4_0_aw_bits_addr),
        .io_axi4_0_aw_bits_id(io_axi4_0_aw_bits_id),
        .io_axi4_0_aw_bits_len(io_axi4_0_aw_bits_len),
        .io_axi4_0_aw_bits_size(io_axi4_0_aw_bits_size),
        .io_axi4_0_aw_bits_burst(io_axi4_0_aw_bits_burst),
        .io_axi4_0_aw_bits_lock(io_axi4_0_aw_bits_lock),
        .io_axi4_0_aw_bits_cache(io_axi4_0_aw_bits_cache),
        .io_axi4_0_aw_bits_prot(io_axi4_0_aw_bits_prot),
        .io_axi4_0_aw_bits_qos(io_axi4_0_aw_bits_qos),
        .io_axi4_0_w_ready(io_axi4_0_w_ready),
        .io_axi4_0_w_valid(io_axi4_0_w_valid),
        .io_axi4_0_w_bits_data(io_axi4_0_w_bits_data),
        .io_axi4_0_w_bits_strb(io_axi4_0_w_bits_strb),
        .io_axi4_0_w_bits_last(io_axi4_0_w_bits_last),
        .io_axi4_0_b_ready(io_axi4_0_b_ready),
        .io_axi4_0_b_valid(io_axi4_0_b_valid),
        .io_axi4_0_b_bits_id(io_axi4_0_b_bits_id),
        .io_axi4_0_b_bits_resp(io_axi4_0_b_bits_resp),
        .io_axi4_0_ar_ready(io_axi4_0_ar_ready),
        .io_axi4_0_ar_valid(io_axi4_0_ar_valid),
        .io_axi4_0_ar_bits_id(io_axi4_0_ar_bits_id),
        .io_axi4_0_ar_bits_addr(io_axi4_0_ar_bits_addr),
        .io_axi4_0_ar_bits_len(io_axi4_0_ar_bits_len),
        .io_axi4_0_ar_bits_size(io_axi4_0_ar_bits_size),
        .io_axi4_0_ar_bits_burst(io_axi4_0_ar_bits_burst),
        .io_axi4_0_ar_bits_lock(io_axi4_0_ar_bits_lock),
        .io_axi4_0_ar_bits_cache(io_axi4_0_ar_bits_cache),
        .io_axi4_0_ar_bits_prot(io_axi4_0_ar_bits_prot),
        .io_axi4_0_ar_bits_qos(io_axi4_0_ar_bits_qos),
        .io_axi4_0_r_ready(io_axi4_0_r_ready),
        .io_axi4_0_r_valid(io_axi4_0_r_valid),
        .io_axi4_0_r_bits_id(io_axi4_0_r_bits_id),
        .io_axi4_0_r_bits_data(io_axi4_0_r_bits_data),
        .io_axi4_0_r_bits_resp(io_axi4_0_r_bits_resp),
        .io_axi4_0_r_bits_last(io_axi4_0_r_bits_last),
`endif
//from tran level
        .io_tran_spi_mode(tran_spi_mode),
        .io_tran_dpi_mode(tran_dpi_mode),
        .io_tran_inst_label(tran_inst_label),
// from ctrl level 
	.io_ctrl_lev_inst_label(ctrl_lev_inst_label),
	.io_ctrl_lev_inst_valid(ctrl_lev_inst_valid),
	.io_ctrl_lev_wr_en(ctrl_lev_wr_en),

// from interface level to control level
        .io_dchan_req_valid(dchan_req_valid),
        .io_dchan_req_ready(dchan_req_ready),
        .io_dchan_req_data_size(dchan_req_data_size),
        .io_dchan_req_data_burstlen(dchan_req_data_burstlen),
        .io_dchan_req_inst(dchan_req_inst),
        .io_dchan_req_addr(dchan_req_addr),

	.io_tdata_lock(tdata_lock),
        .io_dchan_tdata_fifo_wen(dchan_tdata_fifo_wen),
        .io_dchan_tdata_fifo_wdata(dchan_tdata_fifo_wdata),
        .io_dchan_tdata_fifo_full(dchan_tdata_fifo_full),

        .io_dchan_rdata_fifo_ren(dchan_rdata_fifo_ren),
        .io_dchan_rdata_fifo_rdata(dchan_rdata_fifo_rdata),
        .io_dchan_rdata_fifo_empty(dchan_rdata_fifo_empty),

        .io_cchan_req_valid(cchan_req_valid),
        .io_cchan_req_ready(cchan_req_ready),
        .io_cchan_req_data_size(cchan_req_data_size),
        .io_cchan_req_data_burstlen(cchan_req_data_burstlen),
        .io_cchan_req_inst(cchan_req_inst),
        .io_cchan_req_addr(cchan_req_addr),
// resp the cchan the inst error to create a interrupt
        .io_cchan_resp_valid(cchan_resp_valid),
        .io_cchan_resp_error(cchan_resp_error),
        .io_cchan_resp_cause(cchan_resp_cause),

        .io_cchan_tdata_fifo_wen(cchan_tdata_fifo_wen),
        .io_cchan_tdata_fifo_wdata(cchan_tdata_fifo_wdata),
        .io_cchan_tdata_fifo_full(cchan_tdata_fifo_full),

        .io_cchan_rdata_fifo_ren(cchan_rdata_fifo_ren),
        .io_cchan_rdata_fifo_rdata(cchan_rdata_fifo_rdata),
        .io_cchan_rdata_fifo_empty(cchan_rdata_fifo_empty),


//interrupt signal
        .io_qspi_interrupt(io_qspi_interrupt)
);


qspi_ctrl_level U_qspi_ctrl_level
(
        .clock(clock),
        .rst_n(rst_n),
// from tran level to control level
        .io_tran_spi_mode(tran_spi_mode),
        .io_tran_dpi_mode(tran_dpi_mode),
        .io_tran_inst_label(tran_inst_label),
//from contrl level to interface level 
	.io_ctrl_lev_inst_label(ctrl_lev_inst_label),
	.io_ctrl_lev_inst_valid(ctrl_lev_inst_valid),	
	.io_ctrl_lev_wr_en(ctrl_lev_wr_en),
// from interface level to control level
        .io_interface_lev_wren(interface_lev_wren),

        .io_dchan_req_valid(dchan_req_valid),
        .io_dchan_req_ready(dchan_req_ready),
        .io_dchan_req_data_size(dchan_req_data_size),
        .io_dchan_req_data_burstlen(dchan_req_data_burstlen),
        .io_dchan_req_inst(dchan_req_inst),
        .io_dchan_req_addr(dchan_req_addr),

	.io_tdata_lock(tdata_lock),
        .io_dchan_tdata_fifo_wen(dchan_tdata_fifo_wen),
        .io_dchan_tdata_fifo_wdata(dchan_tdata_fifo_wdata),
        .io_dchan_tdata_fifo_full(dchan_tdata_fifo_full),

        .io_dchan_rdata_fifo_ren(dchan_rdata_fifo_ren),
        .io_dchan_rdata_fifo_rdata(dchan_rdata_fifo_rdata),
        .io_dchan_rdata_fifo_empty(dchan_rdata_fifo_empty),

        .io_cchan_req_valid(cchan_req_valid),
        .io_cchan_req_ready(cchan_req_ready),
        .io_cchan_req_data_size(cchan_req_data_size),
        .io_cchan_req_data_burstlen(cchan_req_data_burstlen),
        .io_cchan_req_inst(cchan_req_inst),
        .io_cchan_req_addr(cchan_req_addr),
// resp the cchan the inst error to create a interrupt
        .io_cchan_resp_valid(cchan_resp_valid),
        .io_cchan_resp_error(cchan_resp_error),
        .io_cchan_resp_cause(cchan_resp_cause),

        .io_cchan_tdata_fifo_wen(cchan_tdata_fifo_wen),
        .io_cchan_tdata_fifo_wdata(cchan_tdata_fifo_wdata),
        .io_cchan_tdata_fifo_full(cchan_tdata_fifo_full),

        .io_cchan_rdata_fifo_ren(cchan_rdata_fifo_ren),
        .io_cchan_rdata_fifo_rdata(cchan_rdata_fifo_rdata),
        .io_cchan_rdata_fifo_empty(cchan_rdata_fifo_empty),

//from control level to tran level
        .io_buf_req_valid(buf_req_valid),
        .io_buf_req_ready(buf_req_ready),
        .io_buf_req_inst(buf_req_inst),
        .io_buf_req_inst_label(buf_req_inst_label),
        .io_buf_req_wr_en(buf_req_wr_en),
        .io_buf_req_rd_en(buf_req_rd_en),
        .io_buf_req_addr_en(buf_req_addr_en),
	.io_buf_req_erase_en(buf_req_erase_en),
        .io_buf_req_addr(buf_req_addr),
        .io_buf_req_data_size(buf_req_data_size),
        .io_buf_req_data_burstlen(buf_req_data_burstlen),
        .io_buf_req_dummy_en(buf_req_dummy_en),
        .io_buf_req_dummy_size(buf_req_dummy_size),
        .io_buf_req_dummy_burstlen(buf_req_dummy_burstlen),
        .io_buf_req_addr_mode_en(buf_req_addr_mode_en),
        .io_buf_req_addr_spi_mode(buf_req_addr_spi_mode),
        .io_buf_req_addr_dpi_mode(buf_req_addr_dpi_mode),
        .io_buf_req_data_mode_en(buf_req_data_mode_en),
        .io_buf_req_data_spi_mode(buf_req_data_spi_mode),
        .io_buf_req_data_dpi_mode(buf_req_data_dpi_mode),

//tran data fifo interface
        .io_tdata_fifo_wen(tdata_fifo_wen),
        .io_tdata_fifo_wdata(tdata_fifo_wdata),
        .io_tdata_fifo_full(tdata_fifo_full),
//rec data fifo interface
        .io_rdata_fifo_ren(rdata_fifo_ren),
        .io_rdata_fifo_rdata(rdata_fifo_rdata),
        .io_rdata_fifo_empty(rdata_fifo_empty)



);
qspi_tran_level U_qspi_tran_level
(
        .clock(clock),
        .rst_n(rst_n),
//to control level signal
        .io_tran_inst_label(tran_inst_label),
//from interface level
        .io_clk_divide_param(clk_divide_param),
        .io_interface_lev_wren(interface_lev_wren),
//from control level to tran level
        .io_buf_req_valid(buf_req_valid),
        .io_buf_req_ready(buf_req_ready),
        .io_buf_req_inst(buf_req_inst),
        .io_buf_req_inst_label(buf_req_inst_label),
        .io_buf_req_wr_en(buf_req_wr_en),
        .io_buf_req_rd_en(buf_req_rd_en),
        .io_buf_req_addr_en(buf_req_addr_en),
	.io_buf_req_erase_en(buf_req_erase_en),
        .io_buf_req_addr(buf_req_addr),
        .io_buf_req_data_size(buf_req_data_size),
        .io_buf_req_data_burstlen(buf_req_data_burstlen),
        .io_buf_req_dummy_en(buf_req_dummy_en),
        .io_buf_req_dummy_size(buf_req_dummy_size),
        .io_buf_req_dummy_burstlen(buf_req_dummy_burstlen),
        .io_buf_req_addr_mode_en(buf_req_addr_mode_en),
        .io_buf_req_addr_spi_mode(buf_req_addr_spi_mode),
        .io_buf_req_addr_dpi_mode(buf_req_addr_dpi_mode),
        .io_buf_req_data_mode_en(buf_req_data_mode_en),
        .io_buf_req_data_spi_mode(buf_req_data_spi_mode),
        .io_buf_req_data_dpi_mode(buf_req_data_dpi_mode),

 // from tran level
        .io_tran_spi_mode(tran_spi_mode),
        .io_tran_dpi_mode(tran_dpi_mode),


//tran data fifo interface
        .io_tdata_fifo_wen(tdata_fifo_wen),
        .io_tdata_fifo_wdata(tdata_fifo_wdata),
        .io_tdata_fifo_full(tdata_fifo_full),
//rec data fifo interface
        .io_rdata_fifo_ren(rdata_fifo_ren),
        .io_rdata_fifo_rdata(rdata_fifo_rdata),
        .io_rdata_fifo_empty(rdata_fifo_empty),

//qspi io 
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
