# See LICENSE for license details.
module qspi_interface_level
(
	clock,
	rst_n,
	io_clk_divide_param,
	io_interface_lev_wren,
// ctrl channel        
	hsel_s,
        haddr_s,
        hsize_s,
        htrans_s,
        hwrite_s,
        hrdata_s,
        hwdata_s,
        hready_s,
        hresp_s,
//data channel
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
//from ctrl level 
	io_ctrl_lev_inst_label,
	io_ctrl_lev_inst_valid,
	io_ctrl_lev_wr_en,

//from tran level 
        io_tran_spi_mode,
        io_tran_dpi_mode,
        io_tran_inst_label,

// from interface level to control level
        io_dchan_req_valid,
        io_dchan_req_ready,
        io_dchan_req_data_size,
        io_dchan_req_data_burstlen,
        io_dchan_req_inst,
        io_dchan_req_addr,

	io_tdata_lock,
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
//interrupt signal
        io_qspi_interrupt
);
input clock ;
input rst_n;

output [31:0] io_clk_divide_param;
output io_interface_lev_wren;
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
input   [15:0] io_axi4_0_w_bits_strb;
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

output io_qspi_interrupt;
input hsel_s;
input [4:0] haddr_s;
input [2:0] hsize_s;
input [1:0] htrans_s;
input hwrite_s;
output [ 31: 0 ] hrdata_s;
input [31 : 0 ] hwdata_s;
output  hready_s;
output hresp_s;


output  io_dchan_req_valid;
input   io_dchan_req_ready;
output  [7:0] io_dchan_req_data_size;
output  [7:0] io_dchan_req_data_burstlen;
output  [7:0] io_dchan_req_inst;
output  [23:0]io_dchan_req_addr;


output io_dchan_tdata_fifo_wen;
output [31 : 0 ] io_dchan_tdata_fifo_wdata;
input io_dchan_tdata_fifo_full;

output io_dchan_rdata_fifo_ren;
input [31 : 0 ] io_dchan_rdata_fifo_rdata ;
input io_dchan_rdata_fifo_empty;


output  io_cchan_req_valid;
input   io_cchan_req_ready;
output [7:0] io_cchan_req_data_size;
output [7:0] io_cchan_req_data_burstlen;
output [7:0] io_cchan_req_inst;
output [23:0] io_cchan_req_addr;




//data
output io_cchan_tdata_fifo_wen;
output [31 : 0 ] io_cchan_tdata_fifo_wdata;
input  io_cchan_tdata_fifo_full;

output io_cchan_rdata_fifo_ren;
input  [31 : 0 ] io_cchan_rdata_fifo_rdata;
input  io_cchan_rdata_fifo_empty;
//exception
input  io_cchan_resp_valid;
input  io_cchan_resp_error;
input [1:0] io_cchan_resp_cause;

//from ctrl level
input   io_ctrl_lev_inst_label;
input   io_ctrl_lev_inst_valid;
input   io_ctrl_lev_wr_en;


//from tran_level
input   io_tran_spi_mode;
input   io_tran_dpi_mode;
input   io_tran_inst_label;

//data lock 
output  io_tdata_lock;






////////////////////////////////////////////////////////
//module axi_if
wire dchan_tdata_lock;
wire dchan_tdata_key;
/////////////////////////////////////////////////////////
//module ahb_if
//program mode
wire  qspi_ctrl_mode;
wire [7:0] pmode_inst;
wire [23:0] pmode_addr;
wire pmode_start;
wire  pmode_start_clr;
wire [7:0] pmode_size;

wire [1:0]  flash_state_csr;

wire  cchan_eqpi;
wire  cchan_qpidi;
wire  cchan_edpi;
wire  cchan_dpidi;
wire  cchan_cer;
wire  cchan_ber32;
wire  cchan_ber64;
wire  cchan_ser;
wire  cchan_wrcsr;
wire  cchan_rdcsr;
wire  cchan_eqpi_clr;
wire  cchan_qpidi_clr;
wire  cchan_edpi_clr;
wire  cchan_dpidi_clr;
wire  cchan_cer_clr;
wire  cchan_ber32_clr;
wire  cchan_ber64_clr;
wire  cchan_ser_clr;
wire  cchan_wrcsr_clr;
wire  cchan_rdcsr_clr;









qspi_axi4_if U_interface_qspi_axi4_if(
        .clock(clock),
        .rst_n(rst_n),
//AXI4 Slave for Mem port
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
        .io_dchan_req_valid(io_dchan_req_valid),
        .io_dchan_req_ready(io_dchan_req_ready),
        .io_dchan_req_data_size(io_dchan_req_data_size),
        .io_dchan_req_data_burstlen(io_dchan_req_data_burstlen),
        .io_dchan_req_inst(io_dchan_req_inst),
        .io_dchan_req_addr(io_dchan_req_addr),

        .io_dchan_tdata_fifo_wen(io_dchan_tdata_fifo_wen),
        .io_dchan_tdata_fifo_wdata(io_dchan_tdata_fifo_wdata),
        .io_dchan_tdata_fifo_full(io_dchan_tdata_fifo_full),

        .io_dchan_tdata_lock(dchan_tdata_lock),
        .io_dchan_tdata_key(dchan_tdata_key),

        .io_dchan_rdata_fifo_ren(io_dchan_rdata_fifo_ren),
        .io_dchan_rdata_fifo_rdata(io_dchan_rdata_fifo_rdata),
        .io_dchan_rdata_fifo_empty(io_dchan_rdata_fifo_empty),

	.io_tran_inst_label(io_tran_inst_label)
);



qspi_ahb_if U_interface_qspi_ahb_if(
        .clock(clock),
        .rst_n(rst_n),
	.io_flash_state_csr(flash_state_csr),
//interrupt
        .io_qspi_interrupt(io_qspi_interrupt),

        .hsel_s(hsel_s),
        .haddr_s(haddr_s),
        .hsize_s(hsize_s),
        .htrans_s(htrans_s),
        .hwrite_s(hwrite_s),
        .hrdata_s(hrdata_s),
        .hwdata_s(hwdata_s),
        .hready_s(hready_s),
        .hresp_s(hresp_s),
//from ctrl level
	.io_ctrl_lev_inst_label(io_ctrl_lev_inst_label),
	.io_ctrl_lev_inst_valid(io_ctrl_lev_inst_valid),
	.io_ctrl_lev_wr_en(io_ctrl_lev_wr_en),


//from tran_level
        .io_tran_spi_mode(io_tran_spi_mode),
        .io_tran_dpi_mode(io_tran_dpi_mode),
        .io_tran_inst_label(io_tran_inst_label),
//to tran level
        .io_clk_divide_param(io_clk_divide_param),
	.io_interface_lev_wren(io_interface_lev_wren),
//program mode
        .io_qspi_ctrl_mode(qspi_ctrl_mode),
        .io_pmode_inst(pmode_inst),
        .io_pmode_addr(pmode_addr),
        .io_pmode_start(pmode_start),
        .io_pmode_start_clr(pmode_start_clr),
	.io_pmode_size(pmode_size),
//normal mode signal
        .io_cchan_edpi(cchan_edpi),
        .io_cchan_dpidi(cchan_dpidi),
        .io_cchan_eqpi(cchan_eqpi),
        .io_cchan_qpidi(cchan_qpidi),
        .io_cchan_cer(cchan_cer),
        .io_cchan_ber32(cchan_ber32),
        .io_cchan_ber64(cchan_ber64),
        .io_cchan_ser(cchan_ser),
        .io_cchan_wrcsr(cchan_wrcsr),
        .io_cchan_rdcsr(cchan_rdcsr),
        .io_cchan_edpi_clr(cchan_edpi_clr),
        .io_cchan_dpidi_clr(cchan_dpidi_clr),
        .io_cchan_eqpi_clr(cchan_eqpi_clr),
        .io_cchan_qpidi_clr(cchan_qpidi_clr),
        .io_cchan_cer_clr(cchan_cer_clr),
        .io_cchan_ber32_clr(cchan_ber32_clr),
        .io_cchan_ber64_clr(cchan_ber64_clr),
        .io_cchan_ser_clr(cchan_ser_clr),
        .io_cchan_wrcsr_clr(cchan_wrcsr_clr),
        .io_cchan_rdcsr_clr(cchan_rdcsr_clr),
//data
        .io_cchan_tdata_fifo_wen(io_cchan_tdata_fifo_wen),
        .io_cchan_tdata_fifo_wdata(io_cchan_tdata_fifo_wdata),
        .io_cchan_tdata_fifo_full(io_cchan_tdata_fifo_full),

        .io_cchan_rdata_fifo_ren(io_cchan_rdata_fifo_ren),
        .io_cchan_rdata_fifo_rdata(io_cchan_rdata_fifo_rdata),
        .io_cchan_rdata_fifo_empty(io_cchan_rdata_fifo_empty),
//data lock
        .io_tdata_lock(io_tdata_lock),
//except.ion
        .io_cchan_resp_valid(io_cchan_resp_valid),
        .io_cchan_resp_error(io_cchan_resp_error),
        .io_cchan_resp_cause(io_cchan_resp_cause)

);


qspi_data_lock U_interface_qspi_data_lock
(
        .clock(clock),
        .rst_n(rst_n),
        .io_dchan_tdata_lock(dchan_tdata_lock),
        .io_dchan_tdata_key(dchan_tdata_key),
        .io_tdata_lock(io_tdata_lock)
);

qspi_cchan_inst_gen U_interface_qspi_cchan_inst_gen(
        .clock(clock),
        .rst_n(rst_n),
// from ahb if
        .io_flash_state_csr(flash_state_csr) ,



//cchan ctrl signal
//qspi ctrl mode
//      0:normal mode
//      1:program mode
        .io_qspi_ctrl_mode(qspi_ctrl_mode),
        .io_pmode_start(pmode_start),
        .io_pmode_start_clr(pmode_start_clr),
        .io_pmode_inst(pmode_inst),
        .io_pmode_addr(pmode_addr),
	.io_pmode_size(pmode_size),

        .io_cchan_edpi(cchan_edpi),
        .io_cchan_dpidi(cchan_dpidi),
        .io_cchan_eqpi(cchan_eqpi),
        .io_cchan_qpidi(cchan_qpidi),
        .io_cchan_cer(cchan_cer),
        .io_cchan_ber32(cchan_ber32),
        .io_cchan_ber64(cchan_ber64),
        .io_cchan_ser(cchan_ser),
        .io_cchan_wrcsr(cchan_wrcsr),
        .io_cchan_rdcsr(cchan_rdcsr),
        .io_cchan_edpi_clr(cchan_edpi_clr),
        .io_cchan_dpidi_clr(cchan_dpidi_clr),
        .io_cchan_eqpi_clr(cchan_eqpi_clr),
        .io_cchan_qpidi_clr(cchan_qpidi_clr),
        .io_cchan_cer_clr(cchan_cer_clr),
        .io_cchan_ber32_clr(cchan_ber32_clr),
        .io_cchan_ber64_clr(cchan_ber64_clr),
        .io_cchan_ser_clr(cchan_ser_clr),
        .io_cchan_wrcsr_clr(cchan_wrcsr_clr),
        .io_cchan_rdcsr_clr(cchan_rdcsr_clr),
// to control level
        .io_cchan_req_valid(io_cchan_req_valid),
        .io_cchan_req_ready(io_cchan_req_ready),
        .io_cchan_req_data_size(io_cchan_req_data_size),
        .io_cchan_req_data_burstlen(io_cchan_req_data_burstlen),
        .io_cchan_req_inst(io_cchan_req_inst),
        .io_cchan_req_addr(io_cchan_req_addr)

        );

endmodule
