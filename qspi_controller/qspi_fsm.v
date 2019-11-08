# See LICENSE for license details.

module qspi_fsm(
	clock,
	rst_n,
///////////////////////////////////////////////////
// from interface level 
	io_interface_lev_wren,

        io_start_signal, //to start tran flash req
        io_next_req,  // for next req

        io_dummy_valid,
        io_addr_valid,
        io_wr_valid,
        io_rd_valid,
	io_erase_valid,

	io_tran_finish,
	io_state_free,
	io_state_ready,
	io_state_wren,
	io_state_req,
	io_state_addr,
	io_state_rd_dummy,
	io_state_wr_csr,
	io_state_wr_data,
	io_state_wait_check,
	io_state_check,
	io_state_check_fail,
	io_state_rd,
	io_state_wren_way,
	io_state_check_way,
	io_state_finish,
	io_check_pass
	
);

parameter FREE          =       4'b0000;  
parameter FINISH        =       4'b0001;
parameter READY         =       4'b0010;
parameter WREN		=       4'b1011;
parameter REQ           =       4'b0011;  
parameter ADDR          =       4'b0100;  
parameter WR_DATA       =       4'b0101;  
parameter RD_DUMMY      =       4'b0110;  
parameter RD            =       4'b0111; 
parameter WR_CSR 	=	4'b1000;
parameter CHECK		=	4'b1001;
parameter CHECK_FAIL    =	4'b1101; 
parameter WAIT_CHECK    =       4'b1100;
parameter WAIT_READ	=	4'b1010;
parameter START		=	4'b1111;
input clock;
input rst_n;

input io_interface_lev_wren;


input io_start_signal; //to start tran flash req
output  io_next_req;  //from fsm, for next flash req

input io_dummy_valid;
input io_addr_valid;
input io_wr_valid;
input io_rd_valid;
input io_erase_valid;

input io_tran_finish;
//state of fsm 
output io_state_free;
output io_state_ready;
output io_state_wren;
output io_state_req;
output io_state_addr;
output io_state_rd_dummy;
output io_state_wr_data;
output io_state_wr_csr;
output io_state_rd;
output io_state_wait_check;
output io_state_check;
output io_state_check_fail;
output io_state_finish;

output io_state_check_way;
output io_state_wren_way;
input io_check_pass;

reg wren_ctrl_r;
wire wren_ctrl_pre;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		wren_ctrl_r <= 1'b0;
	else
		wren_ctrl_r <= wren_ctrl_pre;
assign wren_ctrl_pre = io_state_wren ? 1'b1 :
		       io_state_free ? 1'b0 :
		       wren_ctrl_r ;

assign io_state_wren_way = wren_ctrl_r;
reg [3:0] state_r;
wire check_ctrl;
wire loop_flag;

wire next_enwren;
assign next_enwren = io_wr_valid & io_interface_lev_wren|io_erase_valid;

///////////////////////////////////////////////////////////////////
//Inst Stream 
///////////////////////////////////////////////
//Inst Stream: Start Inst End Free
//Source Symbol:o
//Target Symbol:>/^
//   ------------->Free<---------------
//   |         |                      |
//   o         o                      o
//  Inst o--->ADDR o--->DUMMY o---->DATA
//   o         o        ^   ^       ^  ^
//   |         |        |   |       |  |
//   ----------|------------|--------  |      
//             -------------------------
//   
//   
//   
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		state_r <= FREE;
	else 
		case(state_r)
			FREE:	
				if(io_start_signal)
					state_r<=START;
			START:
				state_r <= READY ;
			READY:
				if(io_tran_finish)
					if( next_enwren & ~wren_ctrl_r )
						state_r <= WREN;
					else
						state_r <= REQ;
			WREN:
				if(io_tran_finish)
					state_r <= READY;
				
			REQ:	
				if(io_tran_finish)
				begin
					if(check_ctrl)
						state_r<=RD;
					else if(io_addr_valid)
						state_r<=ADDR;
					else if(io_wr_valid)
						state_r<=WR_CSR;
					else if (io_dummy_valid)
                                                state_r<=RD_DUMMY;
					else if(io_rd_valid )
						state_r<=RD;
					else	
						state_r<=FINISH;
				end
			ADDR:
				if(io_tran_finish)
				begin
					if(io_rd_valid)
						state_r<=RD_DUMMY;
					else if(io_wr_valid )
						state_r<=WR_DATA;
					else	
						state_r<=FINISH;
				end
			WR_DATA:
				if(io_tran_finish )
					state_r<=READY ;
			WAIT_CHECK :
					state_r<=CHECK ;
			CHECK:
				if(io_check_pass)
					state_r <= FINISH ;
				else
					state_r <= CHECK_FAIL;
			CHECK_FAIL:
				if(loop_flag)
					state_r <= READY ;
			WR_CSR:
				if(io_tran_finish)
					state_r<=FINISH;
			RD_DUMMY:
				if(io_tran_finish)
					state_r<=RD;
			RD:
				if(io_tran_finish)
				begin
					if(check_ctrl)
						state_r <= WAIT_CHECK;
					else
						state_r <= WAIT_READ;
				end
			WAIT_READ:
				state_r <= FINISH;
			FINISH:
				state_r <= FREE;
			default:
				state_r <= FREE;	
		endcase
		

assign io_state_free 	=	state_r == FREE | state_r == START;
assign io_state_ready  =	state_r == READY ;
assign io_state_wren   = 	state_r == WREN;
assign io_state_req	=	state_r == REQ;
assign io_state_addr	=	state_r == ADDR;
assign io_state_rd_dummy=	state_r == RD_DUMMY;
assign io_state_wr_csr	=	state_r == WR_CSR;
assign io_state_wr_data =	state_r == WR_DATA;
assign io_state_wait_check = 	state_r == WAIT_CHECK;
assign io_state_check	=	state_r == CHECK;
assign io_state_check_fail =    state_r == CHECK_FAIL;
assign io_state_rd	=	state_r == RD;
assign io_next_req	=	state_r == FINISH;
assign io_state_finish  = 	io_next_req;
reg check_ctrl_r;
wire check_ctrl_pre;
always@(posedge clock or negedge rst_n )
	if(!rst_n)
		check_ctrl_r <= 1'b0;
	else
		check_ctrl_r <= check_ctrl_pre;
assign check_ctrl_pre = io_state_wr_data & io_tran_finish ? 1'b1 :
			io_state_free ? 1'b0 :
			check_ctrl_r;
assign check_ctrl = check_ctrl_r;
assign io_state_check_way = check_ctrl;

reg [7:0] loop_cnt_r;
wire [7:0] loop_cnt_pre;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		loop_cnt_r <= 8'b0;
	else	
		loop_cnt_r <= loop_cnt_pre ;

assign loop_cnt_pre = state_r != CHECK_FAIL ? 8'b0 :
		      loop_cnt_r + 8'b1 ;
assign loop_flag = loop_cnt_r[7] ;




`ifdef QSPI_SIM
reg [3:0] state_delay;
	always@(posedge clock or negedge rst_n)
		if(!rst_n)
			state_delay <= FREE;
		else
			state_delay <= state_r;

integer inst_seq_log;
integer inst_clock_log;
initial begin
	inst_seq_log = $fopen("../sim_log/qspi_fsm->inst_seq.log");
	inst_clock_log = $fopen("../sim_log/qspi_fsm->inst_clock.log");
end

wire [7:0] instruction = top.dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_tran_level.U_tran_qspi_inst_buffer.io_inst;
wire [23:0] address =  top.dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_tran_level.U_tran_qspi_inst_buffer.io_addr ;
always@(posedge clock )
	if(state_delay != state_r)
		case(state_r)
		FREE :
			$display("%d ns:QSPI_INFO:Now FSM Enter FREE",$time/1000);
		READY: 
		begin
			if(~check_ctrl_r & ~wren_ctrl_r)
				$fwrite(inst_seq_log,"Inst[%h] Addr[%h]\n",instruction,address);
			$display("%d ns:QSPI_INFO:Now FSM Enter READY",$time/1000);		
		end
		WREN:
			$display("%d ns:QSPI_INFO:Now FSM Enter WREN",$time/1000);	
		REQ:
		begin
			$fwrite(inst_seq_log,"\tINST");
			$display("%d ns:QSPI_INFO:Now FSM Enter REQ",$time/1000);
		end
		ADDR:
		begin
			$fwrite(inst_seq_log,"==>ADDR");
			$display("%d ns:QSPI_INFO:Now FSM Enter ADDR",$time/1000);
		end
		RD_DUMMY:
		begin
			$fwrite(inst_seq_log,"==>RD_DUMMY");
			$display("%d ns:QSPI_INFO:Now FSM Enter RD_DUMMY",$time/1000);
		end
		WR_CSR:
		begin
			$fwrite(inst_seq_log,"==>WR_DATA");
			$display("%d ns:QSPI_INFO:Now FSM Enter WR_CSR",$time/1000);
		end
		WR_DATA:
		begin
			$fwrite(inst_seq_log,"==>WR_DATA");
			$display("%d ns:QSPI_INFO:Now FSM Enter WR_DATA",$time/1000);
		end
		WAIT_CHECK:
			$display("%d ns:QSPI_INFO:Now FSM Enter WAIT_CHECK",$time/1000);	
		CHECK:
			$display("%d ns:QSPI_INFO:Now FSM Enter CHECK",$time/1000);
		CHECK_FAIL:
			$display("%d ns:QSPI_INFO:Now FSM Enter CHECK_FAIL",$time/1000);
		RD:
		begin
			$fwrite(inst_seq_log,"==>RD_DATA");	
			$display("%d ns:QSPI_INFO:Now FSM Enter RD",$time/1000);
		end
		FINISH:
		begin
			$fwrite(inst_seq_log,"\n");
			$display("%d ns:QSPI_INFO:Now FSM Enter FINISH",$time/1000);
		end
		endcase
`endif		
endmodule 
