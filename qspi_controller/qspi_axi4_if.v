# See LICENSE for license details.

`define DATA_HALFBYTES 32
`define DATA_BYTES 16
`define DATA_HALFWORDS 8
`define DATA_WORDS 4
`define DATA_DOUBLEWORDS 2

module qspi_axi4_if 
(
	clock,
	rst_n,
//AXI4 Slave for Mem port
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
	io_dchan_req_valid,
	io_dchan_req_ready,
	io_dchan_req_data_size,
	io_dchan_req_data_burstlen,
	io_dchan_req_inst,
	io_dchan_req_addr,

	io_dchan_tdata_fifo_wen,
	io_dchan_tdata_fifo_wdata,
	io_dchan_tdata_fifo_full,

	io_dchan_tdata_lock,
	io_dchan_tdata_key,
	
	io_dchan_rdata_fifo_ren,
	io_dchan_rdata_fifo_rdata,
	io_dchan_rdata_fifo_empty,

	io_tran_inst_label
);
input clock ;
input rst_n;
`ifdef AXI4
output	io_axi4_0_aw_ready;
input	io_axi4_0_aw_valid;
input	[`MEM_AWIDTH - 1 : 0 ]	io_axi4_0_aw_bits_addr;
input	[3:0] io_axi4_0_aw_bits_id;
input	[7:0] io_axi4_0_aw_bits_len;
input	[2:0] io_axi4_0_aw_bits_size;
input	[1:0] io_axi4_0_aw_bits_burst;
input	io_axi4_0_aw_bits_lock;
input	[3:0] io_axi4_0_aw_bits_cache;
input	[2:0] io_axi4_0_aw_bits_prot;
input	[3:0] io_axi4_0_aw_bits_qos;
output	io_axi4_0_w_ready;
input	io_axi4_0_w_valid;
input	[`BUS_WIDTH - 1 : 0] io_axi4_0_w_bits_data;
`ifdef X128
input   [15:0] io_axi4_0_w_bits_strb;
`else
	`ifdef X64 
input   [7:0] io_axi4_0_w_bits_strb;
	`else
input	[3:0] io_axi4_0_w_bits_strb;
	`endif
`endif
input	io_axi4_0_w_bits_last;
input	io_axi4_0_b_ready;
output	io_axi4_0_b_valid;
output	[3:0] io_axi4_0_b_bits_id;
output	[1:0] io_axi4_0_b_bits_resp;
output	io_axi4_0_ar_ready;
input	io_axi4_0_ar_valid;
input	[3:0] io_axi4_0_ar_bits_id;
input	[`MEM_AWIDTH - 1 :0]io_axi4_0_ar_bits_addr;
input	[7:0] io_axi4_0_ar_bits_len;
input	[2:0] io_axi4_0_ar_bits_size;
input	[1:0] io_axi4_0_ar_bits_burst;
input	io_axi4_0_ar_bits_lock;
input	[3:0] io_axi4_0_ar_bits_cache;
input	[2:0] io_axi4_0_ar_bits_prot;
input	[3:0] io_axi4_0_ar_bits_qos;
input	io_axi4_0_r_ready;
output	io_axi4_0_r_valid;
output	[3:0] io_axi4_0_r_bits_id;
output	[`BUS_WIDTH - 1 : 0 ] io_axi4_0_r_bits_data;
output	[1:0] io_axi4_0_r_bits_resp;
output	io_axi4_0_r_bits_last;
`endif
output	io_dchan_req_valid;
input   io_dchan_req_ready;
output	[7:0] io_dchan_req_data_size;
output	[7:0] io_dchan_req_data_burstlen;
output	[7:0] io_dchan_req_inst;
output	[23:0]io_dchan_req_addr;


output io_dchan_tdata_fifo_wen;
output [31 : 0 ] io_dchan_tdata_fifo_wdata;
input io_dchan_tdata_fifo_full;

output io_dchan_tdata_lock;
output io_dchan_tdata_key;


output io_dchan_rdata_fifo_ren;
input [31: 0 ] io_dchan_rdata_fifo_rdata ;
input io_dchan_rdata_fifo_empty;
input io_tran_inst_label;
`ifdef AXI4
wire write_valid ,read_valid ;
wire w_data_req;
reg write_req_inflight_r; // indicate qspi dealing write req 
wire write_req_inflight_p;
assign write_valid = io_axi4_0_aw_valid & io_axi4_0_aw_ready ;
assign  read_valid = io_axi4_0_ar_valid & io_axi4_0_ar_ready ;
always@(posedge clock or negedge rst_n)
	if(!rst_n) 
		write_req_inflight_r <= 1'b0;
	else
		write_req_inflight_r <= write_req_inflight_p ;
assign write_req_inflight_p = write_valid ? 1'b1 :
			      io_axi4_0_b_valid & io_axi4_0_b_ready ? 1'b0 :
			      write_req_inflight_r ;

assign w_data_req = io_axi4_0_w_valid & io_axi4_0_w_ready ;


//data channel req signal gen 

assign io_dchan_req_valid = write_valid | read_valid;

//data size, 
//per unit: half bytes 
//max: 4 byte  
wire [7:0] write_data_size ;
wire [7:0] read_data_size ;
wire [7:0] read_words_inbeats ;
wire [7:0] write_words_inbeats ;
assign io_dchan_req_data_size = write_valid ? write_data_size :
				read_valid  ? read_data_size :
				8'b1 ;
assign read_data_size = io_axi4_0_ar_bits_size == 3'b000 ? 8'h2 :
                        io_axi4_0_ar_bits_size == 3'b001 ? 8'h4 :
                        8'h8  ;
assign write_data_size = io_axi4_0_aw_bits_size == 3'b000 ? 8'h2 :
			 io_axi4_0_aw_bits_size == 3'b001 ? 8'h4 : 
			 8'h8  ;;

assign read_words_inbeats = io_axi4_0_ar_bits_size <= 3'b010 ? 8'h1 :
                            8'h2;
assign write_words_inbeats = io_axi4_0_aw_bits_size <= 3'b010 ? 8'h1 :
                             8'h2;

//data length, unit: word
wire [7:0] write_length; 
wire [7:0] read_length;   
assign io_dchan_req_data_burstlen = write_valid ? write_length :
				    read_valid ?  read_length  :
				    8'b1 ;
assign read_length =  io_axi4_0_ar_bits_len == 'b0 ? read_words_inbeats :
                      (io_axi4_0_ar_bits_len + 8'b1) * `DATA_WORDS ;

assign write_length = io_axi4_0_aw_bits_len == 'b0 ? write_words_inbeats :
                      (io_axi4_0_aw_bits_len + 8'b1) * `DATA_WORDS ;




assign io_dchan_req_inst = write_valid ? `PP :
			   read_valid ? `FRQIO :
			   8'b0;


wire [23:0] write_address ;
wire [23:0] axi4_0_aw_bits_addr;
wire [`BUS_WIDTH-1 : 0 ] axi4_w_bits_data;
assign io_dchan_req_addr = write_valid ? write_address :
			   read_valid ? io_axi4_0_ar_bits_addr[23:0] :
			   24'b0 ;

assign axi4_0_aw_bits_addr = io_axi4_0_aw_bits_addr[23:0] ;

assign write_address = io_axi4_0_w_bits_strb[0] ? {axi4_0_aw_bits_addr[23:2],2'b00} : 
		       io_axi4_0_w_bits_strb[1] ? {axi4_0_aw_bits_addr[23:2],2'b01} :
		       io_axi4_0_w_bits_strb[2] ? {axi4_0_aw_bits_addr[23:2],2'b10} :
		       io_axi4_0_w_bits_strb[3] ? {axi4_0_aw_bits_addr[23:2],2'b11} :
                `ifdef X64 
		       io_axi4_0_w_bits_strb[4] ? {axi4_0_aw_bits_addr[23:3],3'b100} :
		       io_axi4_0_w_bits_strb[5] ? {axi4_0_aw_bits_addr[23:3],3'b101} :
		       io_axi4_0_w_bits_strb[6] ? {axi4_0_aw_bits_addr[23:3],3'b110} :
		       io_axi4_0_w_bits_strb[7] ? {axi4_0_aw_bits_addr[23:3],3'b111} :
		`endif
		`ifdef X128
		       io_axi4_0_w_bits_strb[8]  ? {axi4_0_aw_bits_addr[23:4],4'b1000} :
		       io_axi4_0_w_bits_strb[9]  ? {axi4_0_aw_bits_addr[23:4],4'b1001} :
		       io_axi4_0_w_bits_strb[10] ? {axi4_0_aw_bits_addr[23:4],4'b1010} :
                       io_axi4_0_w_bits_strb[11] ? {axi4_0_aw_bits_addr[23:4],4'b1011} :
                       io_axi4_0_w_bits_strb[12] ? {axi4_0_aw_bits_addr[23:4],4'b1100} :
                       io_axi4_0_w_bits_strb[13] ? {axi4_0_aw_bits_addr[23:4],4'b1101} :
                       io_axi4_0_w_bits_strb[14] ? {axi4_0_aw_bits_addr[23:4],4'b1110} :
                       io_axi4_0_w_bits_strb[15] ? {axi4_0_aw_bits_addr[23:4],4'b1111} :
		`endif
		       {axi4_0_aw_bits_addr[23:2],2'b00} ;





//write data to tran fifo 
reg [7:0] write_cnt_reg ;
wire [7:0] write_cnt_pre;
reg [7:0] write_cnt_buard_r;
wire [7:0] write_cnt_buard_p;
wire write_cnt_en ;
reg [`BUS_WIDTH-1:0] writing_data_reg ;
wire [`BUS_WIDTH-1:0] writing_data_pre ;
reg writing_reg ;
wire writing_pre ;

wire write_finish_flag ;

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		writing_reg <= 1'b0 ;
	else
		writing_reg <= writing_pre ;
assign writing_pre = write_finish_flag ? 1'b0 :
		     w_data_req  ? 1'b1 :
                     writing_reg ;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
		write_cnt_buard_r <= 8'b0;
	else
		write_cnt_buard_r <= write_cnt_buard_p;

assign write_cnt_buard_p = write_valid ? (1 << io_axi4_0_ar_bits_size) >> 2  : write_cnt_buard_r ;
 
assign write_finish_flag = (write_cnt_reg == write_cnt_buard_r ) & !io_dchan_tdata_fifo_full ;

assign io_dchan_tdata_fifo_wen = !io_dchan_tdata_fifo_full & writing_reg ;

always @(posedge clock or negedge rst_n)
	if(!rst_n)
		write_cnt_reg <= 8'b1;
	else
		write_cnt_reg <= write_cnt_pre ;
assign write_cnt_pre = write_valid | write_finish_flag ? 8'b1 : 
                       write_cnt_en ? write_cnt_reg + 8'b1 :
                       write_cnt_reg ;
assign write_cnt_en = writing_reg & !io_dchan_tdata_fifo_full ; 

assign axi4_w_bits_data = io_axi4_0_w_bits_strb[0] ? io_axi4_0_w_bits_data :                         		//YYYY  YYYY  YYYY  YYYY
			  io_axi4_0_w_bits_strb[1] ? {`DATA_BYTES{io_axi4_0_w_bits_data[15:8]}}  :   		//NNNN  NNNN  NNNN  NNYN
			  io_axi4_0_w_bits_strb[2] ? {`DATA_HALFWORDS{io_axi4_0_w_bits_data[31:16]}} :		//NNNN  NNNN  NNNN  YYNN
			  io_axi4_0_w_bits_strb[3] ? {`DATA_BYTES{io_axi4_0_w_bits_data[31:24]}} :		//NNNN  NNNN  NNNN  YNNN
                       `ifdef X64    
			  io_axi4_0_w_bits_strb[4] ? {`DATA_WORDS{io_axi4_0_w_bits_data[63:32]}} :		//NNNN  NNNN  YYYY  NNNN
                          io_axi4_0_w_bits_strb[5] ? {`DATA_BYTES{io_axi4_0_w_bits_data[47:40]}} :              //NNNN  NNNN  NNYN  NNNN
                          io_axi4_0_w_bits_strb[6] ? {`DATA_HALFWORDS{io_axi4_0_w_bits_data[63:40]}} :		//NNNN  NNNN  YYNN  NNNN
			  io_axi4_0_w_bits_strb[7] ? {`DATA_BYTES{io_axi4_0_w_bits_data[63:56]}} :		//NNNN  NNNN  YNNN  NNNN
		       `endif 
		       `ifdef X128
                          io_axi4_0_w_bits_strb[4] ? {`DATA_WORDS{io_axi4_0_w_bits_data[63:32]}} :              //NNNN  NNNN  YYYY  NNNN
                          io_axi4_0_w_bits_strb[5] ? {`DATA_BYTES{io_axi4_0_w_bits_data[47:40]}} :              //NNNN  NNNN  NNYN  NNNN
                          io_axi4_0_w_bits_strb[6] ? {`DATA_HALFWORDS{io_axi4_0_w_bits_data[63:40]}} :          //NNNN  NNNN  YYNN  NNNN
                          io_axi4_0_w_bits_strb[7] ? {`DATA_BYTES{io_axi4_0_w_bits_data[63:56]}} :              //NNNN  NNNN  YNNN  NNNN
                          io_axi4_0_w_bits_strb[8]  ? {`DATA_DOUBLEWORDS{io_axi4_0_w_bits_data[127:64]}} :	//YYYY  YYYY  NNNN  NNNN
                          io_axi4_0_w_bits_strb[9]  ? {`DATA_BYTES{io_axi4_0_w_bits_data[79:72]}} :		//NNNN  NNYN  NNNN  NNNN
                          io_axi4_0_w_bits_strb[10] ? {`DATA_HALFWORDS{io_axi4_0_w_bits_data[95:80]}} :		//NNNN  YYNN  NNNN  NNNN
                          io_axi4_0_w_bits_strb[11] ? {`DATA_BYTES{io_axi4_0_w_bits_data[95:88]}} :		//NNNN  YNNN  NNNN  NNNN
                          io_axi4_0_w_bits_strb[12] ? {`DATA_WORDS{io_axi4_0_w_bits_data[127:96]}} :		//YYYY  NNNN  NNNN  NNNN			
                          io_axi4_0_w_bits_strb[13] ? {`DATA_BYTES{io_axi4_0_w_bits_data[111:104]}} :           //NNYN  NNNN  NNNN  NNNN					 
                          io_axi4_0_w_bits_strb[14] ? {`DATA_HALFWORDS{io_axi4_0_w_bits_data[127:112]}} :	//YYNN  NNNN  NNNN  NNNN				
                          io_axi4_0_w_bits_strb[15] ? {`DATA_BYTES{io_axi4_0_w_bits_data[127:120]}} :		//YNNN  NNNN  NNNN  NNNN			
			`endif
			  io_axi4_0_w_bits_data ;   

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		writing_data_reg <= `BUS_WIDTH'b0;
	else
		writing_data_reg <= writing_data_pre;

assign writing_data_pre = w_data_req ? axi4_w_bits_data :
			  write_cnt_en ? writing_data_reg >> 32 :
			  writing_data_reg ;
                          
assign io_dchan_tdata_fifo_wdata = writing_data_reg[31:0] ; 

//mux lock
reg last_write_beat_r;
wire last_write_beat_p;
always@(posedge clock or negedge rst_n)
	if(!rst_n) 
		last_write_beat_r <= 1'b0;
	else 
		last_write_beat_r <= last_write_beat_p;
assign last_write_beat_p = w_data_req & io_axi4_0_w_bits_last ? 1'b1 :
			   write_finish_flag ? 1'b0 :
			   last_write_beat_r ; 
assign io_dchan_tdata_lock = write_valid  ;



assign io_dchan_tdata_key =  last_write_beat_r & write_finish_flag;


//read req info store
reg [31:0] read_info_fifo_id_reg;
wire[31:0] read_info_fifo_id_pre;
reg [63:0] read_info_fifo_len_reg;
wire[63:0] read_info_fifo_len_pre;
reg [23:0] read_info_fifo_size_reg;
wire[23:0] read_info_fifo_size_pre;
reg [7:0]  read_info_fifo_cursor_reg;
wire[7:0]  read_info_fifo_cursor_pre;

wire read_info_fifo_empty ;
wire read_info_fifo_full  ;

always@(posedge clock or negedge rst_n)
	if(!rst_n) begin
		read_info_fifo_id_reg <= 32'b0;
		read_info_fifo_len_reg <= 64'b0;
		read_info_fifo_size_reg <= 24'b0;
		read_info_fifo_cursor_reg <= 8'b1;
	end
	else begin
		read_info_fifo_id_reg      <= read_info_fifo_id_pre;
		read_info_fifo_len_reg     <= read_info_fifo_len_pre;
		read_info_fifo_size_reg    <= read_info_fifo_size_pre;
		read_info_fifo_cursor_reg  <= read_info_fifo_cursor_pre;
	end

assign read_info_fifo_id_pre = read_valid ? {read_info_fifo_id_reg[27:0],io_axi4_0_ar_bits_id} :
			       read_info_fifo_id_reg ;

assign read_info_fifo_len_pre = read_valid ? {read_info_fifo_len_reg[55:0],io_axi4_0_ar_bits_len} :
				read_info_fifo_len_reg ;

assign read_info_fifo_size_pre = read_valid ? {read_info_fifo_size_reg[17:0],io_axi4_0_ar_bits_size} :
				 read_info_fifo_size_reg ;

assign read_info_fifo_cursor_pre = read_info_fifo_cursor_reg == 8'b0 ? 8'b1 :
				   io_axi4_0_r_valid & io_axi4_0_r_ready & io_axi4_0_r_bits_last & read_valid ? read_info_fifo_cursor_reg :
				   io_axi4_0_r_valid & io_axi4_0_r_ready & io_axi4_0_r_bits_last ? {1'b0,read_info_fifo_cursor_reg[7:1]} :    //>>
				   read_valid ? {read_info_fifo_cursor_reg[6:0],1'b0} : 	      //<<
				   read_info_fifo_cursor_reg ;

assign read_info_fifo_empty = read_info_fifo_cursor_reg == 8'b1 ;
assign read_info_fifo_full  = read_info_fifo_cursor_reg == 8'b1000_0000;


reg  [3:0] axi4_b_bits_id_r;
wire [3:0] axi4_b_bits_id_p ;
reg  axi4_b_valid_r ;
wire axi4_b_valid_p ;
always @(posedge clock or negedge rst_n)
	if(!rst_n)
	begin
		axi4_b_bits_id_r <= 4'b0 ;
		axi4_b_valid_r   <= 1'b0 ;
	end
	else begin
		axi4_b_bits_id_r <= axi4_b_bits_id_p ;  
		axi4_b_valid_r   <= axi4_b_valid_p   ;
	end
assign axi4_b_bits_id_p  = write_valid ? io_axi4_0_aw_bits_id :
			   axi4_b_bits_id_r ;
assign axi4_b_valid_p    = w_data_req & io_axi4_0_w_bits_last  ? 1'b1 :
		           io_axi4_0_b_ready ? 1'b0 :
			   axi4_b_valid_r ;
//request ready signal 
assign io_axi4_0_aw_ready = io_dchan_req_ready & ~write_req_inflight_r & ~(io_dchan_tdata_fifo_full || writing_reg);
assign io_axi4_0_w_ready  =  ~(io_dchan_tdata_fifo_full || writing_reg) ;

assign io_axi4_0_ar_ready = ~(read_info_fifo_full | write_valid) & io_dchan_req_ready ;

//responce signal 
wire [2:0] read_size ;
wire [3:0] read_id ; 
wire [7:0] read_len ;
wire read_resp_valid;
wire can_read_fifo;
reg  [7:0] read_beats_cnt_r ;
wire [7:0] read_beats_cnt_p ;
reg tran_inst_label_d ;
wire [`BUS_WIDTH-1:0] data_joint;
wire MultiWord ;

assign MultiWord = read_size[2] || (read_size[1] & read_size[0]); // read_size > 3'b010 
//write resp 
assign io_axi4_0_b_valid 	= axi4_b_valid_r ;
assign io_axi4_0_b_bits_id 	= axi4_b_bits_id_r ;
assign io_axi4_0_b_bits_resp 	= 2'b0;

//read resp 
assign io_axi4_0_r_valid  	= read_resp_valid ;
assign io_axi4_0_r_bits_data 	= read_size == 3'b000 ? {`DATA_BYTES{data_joint[31:24]}} : 
				  read_size == 3'b001 ? {`DATA_HALFWORDS{data_joint[31:16]}} :
				  read_size == 3'b010 ? {`DATA_WORDS{data_joint[31:0]}} :
				  data_joint ;

assign io_axi4_0_r_bits_resp 	= 2'b00 ;
assign io_axi4_0_r_bits_last 	= (read_beats_cnt_r == read_len) ;
assign io_axi4_0_r_bits_id 	= read_id ;

assign read_size = read_info_fifo_cursor_reg [7] ? read_info_fifo_size_reg[20:18] :
		   read_info_fifo_cursor_reg [6] ? read_info_fifo_size_reg[17:15] :
		   read_info_fifo_cursor_reg [5] ? read_info_fifo_size_reg[14:12] :
		   read_info_fifo_cursor_reg [4] ? read_info_fifo_size_reg[11:9]  :
		   read_info_fifo_cursor_reg [3] ? read_info_fifo_size_reg[8:6]   :
		   read_info_fifo_cursor_reg [2] ? read_info_fifo_size_reg[5:3]   :
		   read_info_fifo_cursor_reg [1] ? read_info_fifo_size_reg[2:0]   :
		   3'b0 ;

assign read_id   = read_info_fifo_cursor_reg [7] ? read_info_fifo_id_reg[27:24] :
                   read_info_fifo_cursor_reg [6] ? read_info_fifo_id_reg[23:10] :
                   read_info_fifo_cursor_reg [5] ? read_info_fifo_id_reg[19:16] :
                   read_info_fifo_cursor_reg [4] ? read_info_fifo_id_reg[15:12]  :
                   read_info_fifo_cursor_reg [3] ? read_info_fifo_id_reg[11:8]   :
                   read_info_fifo_cursor_reg [2] ? read_info_fifo_id_reg[7:4]   :
                   read_info_fifo_cursor_reg [1] ? read_info_fifo_id_reg[3:0]   :
                   4'b0 ;

assign read_len  = read_info_fifo_cursor_reg [7] ? read_info_fifo_len_reg[55:48] :
                   read_info_fifo_cursor_reg [6] ? read_info_fifo_len_reg[47:40] :
                   read_info_fifo_cursor_reg [5] ? read_info_fifo_len_reg[39:32] :
                   read_info_fifo_cursor_reg [4] ? read_info_fifo_len_reg[31:24] :
                   read_info_fifo_cursor_reg [3] ? read_info_fifo_len_reg[23:16] :
                   read_info_fifo_cursor_reg [2] ? read_info_fifo_len_reg[15:8]  :
                   read_info_fifo_cursor_reg [1] ? read_info_fifo_len_reg[7:0]   :
                   8'b0 ;

reg [7:0] read_cnt_reg ;
wire [7:0] read_cnt_pre;
wire read_finish_flag ;
reg [`BUS_WIDTH : 0 ] read_data_from_fifo_reg;
wire [`BUS_WIDTH: 0 ] read_data_from_fifo_pre; 
reg can_tran_resp_reg;
wire can_tran_resp_pre;
always@(posedge clock or negedge rst_n)
	if(!rst_n)
	begin
		read_beats_cnt_r 	<= 8'b0 ;
		tran_inst_label_d 	<= 1'b0 ;
		read_cnt_reg 		<= 8'b0 ;		
		read_data_from_fifo_reg <= `BUS_WIDTH'b0;
		can_tran_resp_reg 	<= 1'b0 ;
	end
	else
	begin
		read_beats_cnt_r	<= read_beats_cnt_p ;
		tran_inst_label_d	<= io_tran_inst_label ;
		read_cnt_reg		<= read_cnt_pre ;
		read_data_from_fifo_reg <= read_data_from_fifo_pre;
		can_tran_resp_reg       <= can_tran_resp_pre; 
	end


assign can_read_fifo   =	~io_dchan_rdata_fifo_empty & tran_inst_label_d ; 

assign read_cnt_pre = read_finish_flag ? 8'b0 :
                      can_read_fifo & (MultiWord) ?  read_cnt_reg + 8'b1 :
		      read_cnt_reg ;

assign read_finish_flag = !MultiWord ? 1'b1 : (read_cnt_reg == 8'd`DATA_WORDS) ;


assign read_data_from_fifo_pre = can_read_fifo ? {io_dchan_rdata_fifo_rdata,read_data_from_fifo_reg[`BUS_WIDTH-1:32]} :
				 read_data_from_fifo_reg ;

assign read_beats_cnt_p  =  io_axi4_0_r_ready & io_axi4_0_r_valid & io_axi4_0_r_bits_last  ? 8'b0 :
			    io_axi4_0_r_ready & io_axi4_0_r_valid ? read_beats_cnt_r +8'b1 :
			    read_beats_cnt_r ;


assign can_tran_resp_pre = 	io_axi4_0_r_valid & io_axi4_0_r_ready ? 1'b0 :
				(!MultiWord ? 
				(can_read_fifo ? 1'b1 : can_tran_resp_reg) :
				(read_finish_flag) ? 1'b1 : can_tran_resp_reg) ;
assign read_resp_valid = can_tran_resp_reg ;

assign data_joint = read_data_from_fifo_reg[`BUS_WIDTH-1:0] ;

assign io_dchan_rdata_fifo_ren = can_read_fifo ;


`endif

endmodule 
	
