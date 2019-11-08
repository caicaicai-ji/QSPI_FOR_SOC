# See LICENSE for license details.
module qspi_mode_ctrl
(
	clock,
	rst_n,
	io_state_addr,
	io_state_wr_data,
	io_state_rd,
	io_addr_mode_en,
	io_addr_spi_mode,
	io_addr_dpi_mode,
	io_data_mode_en,
	io_data_spi_mode,
	io_data_dpi_mode,
	io_start_signal,
	io_next_req,
	io_inst,
	io_csr_data,
	io_spi_mode,
	io_dpi_mode,
	io_tran_spi_mode,
	io_tran_dpi_mode
);


input clock;
input rst_n;

input io_state_addr ;
input io_state_wr_data;
input io_state_rd;
input io_addr_mode_en;
input io_addr_spi_mode;
input io_addr_dpi_mode;
input io_data_mode_en;
input io_data_spi_mode;
input io_data_dpi_mode;


input io_start_signal;
input io_next_req;
input [7:0] io_inst;
input [7 : 0] io_csr_data;
output io_spi_mode ;
output io_dpi_mode ;
output io_tran_spi_mode;
output io_tran_dpi_mode;

wire enter_qpi,enter_dpi;
wire exit_qpi,exit_dpi;

parameter QPI_MODE = 2'b00;
parameter SPI_MODE = 2'b01;
parameter DPI_MODE = 2'b10;

reg [1:0] mode_state_r;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		mode_state_r <= SPI_MODE;
	else
		case(mode_state_r) 
		QPI_MODE:
			if(exit_qpi)
				mode_state_r <= SPI_MODE ;
		SPI_MODE :
			if(enter_qpi)
				mode_state_r <= QPI_MODE ;
			else if(enter_dpi)
				mode_state_r <= DPI_MODE ;
		DPI_MODE :
			if(exit_dpi)
				mode_state_r <= SPI_MODE ;
			else if(enter_qpi)
				mode_state_r <= QPI_MODE ;
		default :
			mode_state_r <= SPI_MODE ;
		endcase

assign io_tran_spi_mode = mode_state_r[0];
assign io_tran_dpi_mode = mode_state_r[1];

assign io_spi_mode = io_state_addr ? (io_addr_mode_en & io_addr_spi_mode) :
		     io_state_wr_data | io_state_rd ? io_data_mode_en & io_data_spi_mode :
		     mode_state_r[0];
assign io_dpi_mode = io_state_addr ? io_addr_mode_en & io_addr_dpi_mode : 
		     io_state_wr_data | io_state_rd ? io_data_mode_en & io_data_dpi_mode : 
		     mode_state_r[1];

`ifdef N25Q128
assign enter_qpi = io_next_req & (io_inst == `QPIEN) & ~io_csr_data[7] ; 
assign enter_dpi = io_next_req & (io_inst == `DPIEN) & ~io_csr_data[6] ;

assign exit_qpi = io_next_req &  (io_inst == `QPIDI) & io_csr_data[7];

assign exit_dpi = io_next_req &  (io_inst == `DPIDI) & io_csr_data[6];
`endif
`ifdef IS25LP128
assign enter_qpi = io_next_req & (io_inst == `QPIEN) ;
assign exit_qpi  = io_next_req & (io_inst == `QPIDI) ;
/////////////////////////////////
//IS25LP128 not support dpi mode
assign enter_dpi = 1'b0;
assign exit_dpi = 1'b0;
`endif

`ifdef QSPI_SIM
reg [1:0] mode_state_d;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		mode_state_d <= SPI_MODE;
	else
		mode_state_d <= mode_state_r ;

always@(posedge clock)
	if(mode_state_d != mode_state_r)
		case(mode_state_r)
			SPI_MODE :
				$display("%d ns:\tQSPI_INFO:Now Enter SPI MODE",$time/1000);
			DPI_MODE :
				$display("%d ns:\tQSPI_INFO:Now Enter DPI MODE",$time/1000);
			QPI_MODE :
				$display("%d ns:\tQSPI_INFO:Now Enter QPI MODE",$time/1000);

		endcase
`endif 
endmodule 
