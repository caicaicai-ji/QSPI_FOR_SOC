# See LICENSE for license details.
module qspi_inst_arbiter(
	clock,
	rst_n,
//from tran level 
	io_tran_inst_label,

	io_dchan_req_valid,
	io_dchan_req_ready,
	io_dchan_req_data_size,
	io_dchan_req_data_burstlen,
	io_dchan_req_inst,
	io_dchan_req_addr,

//data lock 
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

//to qspi_inst_decode module
        io_flash_req_valid,
        io_flash_req_ready,
        io_flash_req_inst,
        io_flash_req_data_size,
        io_flash_req_data_burstlen,
	io_flash_req_addr,
//instrcution label 
//	0:cchannel inst
//	1:dchannel inst
        io_flash_req_inst_label,
	io_flash_resp_valid,
        io_flash_resp_error,
        io_flash_resp_cause,

	io_tdata_fifo_wen,
	io_tdata_fifo_wdata,
	io_tdata_fifo_full,
	
	io_rdata_fifo_ren,
	io_rdata_fifo_rdata,
	io_rdata_fifo_empty
	
);
input clock;
input rst_n;
//from tran level
input io_tran_inst_label;

input io_dchan_req_valid;
output io_dchan_req_ready;
input [7:0] io_dchan_req_data_size;
input [7:0] io_dchan_req_data_burstlen;
input [7:0] io_dchan_req_inst;
input [23:0] io_dchan_req_addr;

input io_tdata_lock;
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

//to qspi_inst_decode module
output io_flash_req_valid;
input io_flash_req_ready;
output [7:0] io_flash_req_inst;
output io_flash_req_inst_label;
output [7:0] io_flash_req_data_size;
output [7:0] io_flash_req_data_burstlen;
output [23:0] io_flash_req_addr;
input io_flash_resp_valid;
input io_flash_resp_error;
input [1:0] io_flash_resp_cause;

output io_tdata_fifo_wen;
output[31 : 0 ] io_tdata_fifo_wdata;
input  io_tdata_fifo_full;

output io_rdata_fifo_ren;
input [31 : 0 ] io_rdata_fifo_rdata;
input io_rdata_fifo_empty;





assign io_flash_req_valid = io_dchan_req_valid | io_cchan_req_valid ;
assign io_dchan_req_ready = io_flash_req_ready;
assign io_cchan_req_ready = ~io_dchan_req_valid & io_flash_req_ready ;

assign io_flash_req_inst = io_dchan_req_valid ? io_dchan_req_inst :
			   io_cchan_req_valid ? io_cchan_req_inst :
			   8'b0;
assign io_flash_req_data_size = io_dchan_req_valid ? io_dchan_req_data_size :
				io_cchan_req_valid ? io_cchan_req_data_size :
				8'b0;
assign io_flash_req_data_burstlen = io_dchan_req_valid ? io_dchan_req_data_burstlen :
				    io_cchan_req_valid ? io_cchan_req_data_burstlen :
				    8'b0 ;
assign io_flash_req_addr = io_dchan_req_valid ? io_dchan_req_addr :
			   io_cchan_req_addr ;
assign io_cchan_resp_valid = io_flash_resp_valid ;
assign io_cchan_resp_error = io_flash_resp_error ;
assign io_cchan_resp_cause = io_flash_resp_cause ; 	


assign io_flash_req_inst_label = io_dchan_req_valid ; 

assign io_tdata_fifo_wen = io_tdata_lock ? io_dchan_tdata_fifo_wen :
			   io_cchan_tdata_fifo_wen ;

assign io_tdata_fifo_wdata = io_tdata_lock ? io_dchan_tdata_fifo_wdata :
		             io_cchan_tdata_fifo_wdata ;

assign io_dchan_tdata_fifo_full = io_tdata_fifo_full ;
assign io_cchan_tdata_fifo_full = io_tdata_fifo_full ;

assign io_rdata_fifo_ren = io_tran_inst_label ? io_dchan_rdata_fifo_ren :
			   io_cchan_rdata_fifo_ren ;
assign io_dchan_rdata_fifo_rdata = io_rdata_fifo_rdata ;
assign io_dchan_rdata_fifo_empty = io_rdata_fifo_empty ;

assign io_cchan_rdata_fifo_rdata = io_rdata_fifo_rdata ;
assign io_cchan_rdata_fifo_empty = io_rdata_fifo_empty ;



endmodule 


	
