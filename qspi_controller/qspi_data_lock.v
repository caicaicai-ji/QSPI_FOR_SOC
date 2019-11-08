# See LICENSE for license details.

//////////////////////////////////////////////////////
//
//	Use to add lock for protecting write data 
//		because it may be write many data,but
//			the instruction just one
//		and dchan or cchan may tran many instruction 
//			it may make the data chaos
//
//


module qspi_data_lock
(
	clock,
	rst_n,
	io_dchan_tdata_lock,
	io_dchan_tdata_key,
	io_tdata_lock
);


input clock;
input rst_n;
input io_dchan_tdata_lock;
input io_dchan_tdata_key;
output io_tdata_lock;


reg lock_r;
wire lock_pre;
always@(posedge clock or negedge rst_n )
	if(!rst_n)
		lock_r <= 1'b0;
	else
		lock_r <= lock_pre ;

assign lock_pre = io_dchan_tdata_key ? 1'b0 :
		  io_dchan_tdata_lock ? 1'b1 :
		  lock_r ;

assign io_tdata_lock = lock_r | io_dchan_tdata_lock ;
		  
endmodule 


