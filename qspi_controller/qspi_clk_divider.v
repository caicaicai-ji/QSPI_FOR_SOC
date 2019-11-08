# See LICENSE for license details.
//////////////////////////////////////////////////////////
// use data gate to control the clock 
//
//

module qspi_clk_divider( 
input clock,
input rst_n,
input io_start_signal,
input [31:0] io_cchan_divide,
output io_qspi_data_en 
);


parameter BASE_DIVIDE_PARA=32'h0 ;

reg [31:0] divide_cnt;
wire [31:0] divide_cnt_pre;
wire [31:0] divide_cnt_flag;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		divide_cnt <= BASE_DIVIDE_PARA;
	else
		divide_cnt <= divide_cnt_pre ;
assign divide_cnt_flag = BASE_DIVIDE_PARA + io_cchan_divide ;
assign io_qspi_data_en = divide_cnt == 32'b0 ;
assign divide_cnt_pre = ~io_start_signal | io_qspi_data_en ? divide_cnt_flag : 
			divide_cnt + 32'hffff_ffff ;
endmodule

