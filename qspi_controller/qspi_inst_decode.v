# See LICENSE for license details.
module qspi_inst_decode
(
	clock,
	rst_n,

	io_interface_lev_wren,

	io_flash_req_valid,
	io_flash_req_ready,
	io_flash_req_inst,
	io_flash_req_inst_label,
	io_flash_req_data_size,
	io_flash_req_data_burstlen,
	io_flash_req_addr,

	io_flash_resp_valid,
	io_flash_resp_error,
	io_flash_resp_cause,
//to interface level 
        io_ctrl_lev_inst_label,
        io_ctrl_lev_inst_valid,
        io_ctrl_lev_wr_en,

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
 // from tran level 
	io_tran_spi_mode,
	io_tran_dpi_mode

	
);

input clock ;
input rst_n;
input io_interface_lev_wren;

output io_ctrl_lev_inst_label;
output io_ctrl_lev_inst_valid;
output io_ctrl_lev_wr_en;

input io_flash_req_valid;
output io_flash_req_ready;
input [7:0] io_flash_req_inst;
input io_flash_req_inst_label;
input[7:0] io_flash_req_data_size;
input[7:0] io_flash_req_data_burstlen;
input [23:0] io_flash_req_addr;

output io_flash_resp_valid;
output io_flash_resp_error;
output [1:0] io_flash_resp_cause;
//from control level to tran level
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
 // from tran level
input  io_tran_spi_mode;
input  io_tran_dpi_mode;


wire flash_req;
assign flash_req = io_flash_req_valid & io_flash_req_ready ;
assign io_flash_req_ready = io_buf_req_ready ;

assign io_buf_req_inst_label = io_flash_req_inst_label;
assign io_buf_req_data_burstlen = io_flash_req_data_burstlen;
assign io_buf_req_data_size = io_flash_req_data_size ;


 
assign io_ctrl_lev_inst_label = io_buf_req_inst_label;
assign io_ctrl_lev_inst_valid = io_buf_req_valid & io_buf_req_ready;
assign io_ctrl_lev_wr_en = io_buf_req_wr_en ; 



//N25Q125 Instruction 
///////////////////////////////////////////////////
`ifdef N25Q128 
parameter xxx_RDID 	= 	7'b1001_111;
parameter xxx_READ 	= 	8'b0000_0011;
parameter xxx_FAST_READ = 	8'b0000_1011 ;
parameter xxx_DOFR 	= 	8'b0011_1011 ;
parameter xxx_DIOFR 	= 	8'b1011_1011;
parameter xxx_QOFR 	= 	8'b0110_1011 ;
parameter xxx_QIOFR 	= 	8'b1110_1011 ;
parameter xxx_ROTP 	= 	8'b0100_1011 ;
parameter xxx_WREN 	= 	8'b0000_0110 ;
parameter xxx_WRDI 	= 	8'b0000_0100 ;
parameter xxx_PP 	= 	8'b0000_0010 ;
parameter xxx_DIFP 	= 	8'b1010_0010 ;
parameter xxx_DIEFP 	= 	8'b1101_0010 ;
parameter xxx_QIFP 	= 	8'b0011_0010 ;
parameter xxx_QIEFP 	= 	8'b1101_0010 ;
parameter xxx_POTP 	= 	8'b0100_0010 ;
parameter xxx_SSE 	= 	8'b0010_0000 ;
parameter xxx_SE 	= 	8'b1101_1000 ;
parameter xxx_BE 	= 	8'b1100_0111 ;
parameter xxx_PER 	= 	8'b0111_1010 ;
parameter xxx_PES 	= 	8'b0111_0101 ;
parameter xxx_RDSR 	= 	8'b0000_0101 ;
parameter xxx_WRSR 	= 	8'b0000_0001 ;
parameter xxx_RDLR 	= 	8'b1110_1000 ;
parameter xxx_WRLR 	= 	8'b1110_0101 ;
parameter xxx_RFSR 	= 	8'b0111_0000 ;
parameter xxx_CLFSR 	= 	8'b0101_0000 ;
parameter xxx_RDNVCR 	= 	8'b1011_0101 ;
parameter xxx_WRNVCR 	= 	8'b1011_0001 ;
parameter xxx_RDVCR 	= 	8'b1000_0101 ;
parameter xxx_WRVCR 	= 	8'b1000_0001 ;
parameter xxx_RDVECR 	= 	8'b0110_0101;
parameter xxx_WRVECR 	= 	8'b0110_0001 ;
`endif
wire [7:0] inst;
assign inst = io_flash_req_inst ;
//the low half byte of inst

wire inst_lhb_0; 
wire inst_lhb_1;
wire inst_lhb_2;
wire inst_lhb_3;
wire inst_lhb_4;
wire inst_lhb_5;
wire inst_lhb_6;
wire inst_lhb_7;
wire inst_lhb_8;
wire inst_lhb_9;
wire inst_lhb_a;
wire inst_lhb_b;
wire inst_lhb_c;
wire inst_lhb_d;
wire inst_lhb_e;
wire inst_lhb_f;
//the low half byte of inst
wire inst_hhb_0; 
wire inst_hhb_1;
wire inst_hhb_2;
wire inst_hhb_3;
wire inst_hhb_4;
wire inst_hhb_5;
wire inst_hhb_6;
wire inst_hhb_7;
wire inst_hhb_8;
wire inst_hhb_9;
wire inst_hhb_a;
wire inst_hhb_b;
wire inst_hhb_c;
wire inst_hhb_d;
wire inst_hhb_e;
wire inst_hhb_f;

assign inst_lhb_0 = inst[3:0] == 4'b0000 ? 1'b1 : 1'b0 ;
assign inst_lhb_1 = inst[3:0] == 4'b0001 ? 1'b1 : 1'b0 ;
assign inst_lhb_2 = inst[3:0] == 4'b0010 ? 1'b1 : 1'b0 ;
assign inst_lhb_3 = inst[3:0] == 4'b0011 ? 1'b1 : 1'b0 ;
assign inst_lhb_4 = inst[3:0] == 4'b0100 ? 1'b1 : 1'b0 ;
assign inst_lhb_5 = inst[3:0] == 4'b0101 ? 1'b1 : 1'b0 ;
assign inst_lhb_6 = inst[3:0] == 4'b0110 ? 1'b1 : 1'b0 ;
assign inst_lhb_7 = inst[3:0] == 4'b0111 ? 1'b1 : 1'b0 ;
assign inst_lhb_8 = inst[3:0] == 4'b1000 ? 1'b1 : 1'b0 ;
assign inst_lhb_9 = inst[3:0] == 4'b1001 ? 1'b1 : 1'b0 ;
assign inst_lhb_a = inst[3:0] == 4'b1010 ? 1'b1 : 1'b0 ;
assign inst_lhb_b = inst[3:0] == 4'b1011 ? 1'b1 : 1'b0 ;
assign inst_lhb_c = inst[3:0] == 4'b1100 ? 1'b1 : 1'b0 ;
assign inst_lhb_d = inst[3:0] == 4'b1101 ? 1'b1 : 1'b0 ;
assign inst_lhb_e = inst[3:0] == 4'b1110 ? 1'b1 : 1'b0 ;
assign inst_lhb_f = inst[3:0] == 4'b1111 ? 1'b1 : 1'b0 ;

assign inst_hhb_0 = inst[7:4] == 4'b0000 ? 1'b1 : 1'b0 ;
assign inst_hhb_1 = inst[7:4] == 4'b0001 ? 1'b1 : 1'b0 ;
assign inst_hhb_2 = inst[7:4] == 4'b0010 ? 1'b1 : 1'b0 ;
assign inst_hhb_3 = inst[7:4] == 4'b0011 ? 1'b1 : 1'b0 ;
assign inst_hhb_4 = inst[7:4] == 4'b0100 ? 1'b1 : 1'b0 ;
assign inst_hhb_5 = inst[7:4] == 4'b0101 ? 1'b1 : 1'b0 ;
assign inst_hhb_6 = inst[7:4] == 4'b0110 ? 1'b1 : 1'b0 ;
assign inst_hhb_7 = inst[7:4] == 4'b0111 ? 1'b1 : 1'b0 ;
assign inst_hhb_8 = inst[7:4] == 4'b1000 ? 1'b1 : 1'b0 ;
assign inst_hhb_9 = inst[7:4] == 4'b1001 ? 1'b1 : 1'b0 ;
assign inst_hhb_a = inst[7:4] == 4'b1010 ? 1'b1 : 1'b0 ;
assign inst_hhb_b = inst[7:4] == 4'b1011 ? 1'b1 : 1'b0 ;
assign inst_hhb_c = inst[7:4] == 4'b1100 ? 1'b1 : 1'b0 ;
assign inst_hhb_d = inst[7:4] == 4'b1101 ? 1'b1 : 1'b0 ;
assign inst_hhb_e = inst[7:4] == 4'b1110 ? 1'b1 : 1'b0 ;
assign inst_hhb_f = inst[7:4] == 4'b1111 ? 1'b1 : 1'b0 ;
 


`ifdef N25Q128 // for chip N25Q128

wire dummy_read_data ;
wire read_data ;

wire write_data ;

wire just_inst ;

wire just_inst_addr ;


wire reg_read;
wire reg_write;

wire erase_en;

wire inst_xcpt ;

/////////////////////////////////////////////////////
//Dummy Read
//0b Read Data Byte at High Speed  
//3b Dual Ouput Fast Read
//bb Dual Input/Output Fast Read 
//eb Quad Input/Output Fast Read
//4b Read OTP
//6b Quad Output Fast Read
assign dummy_read_data = inst_lhb_b & (inst_hhb_0 | inst_hhb_3 | inst_hhb_b | inst_hhb_e | inst_hhb_4 | inst_hhb_6);
///////////////////////////////////////////////////////
//read data without dummy
//03 Read Data Byte 
//
assign read_data = inst_lhb_3 & inst_hhb_0;
//////////////////////////////////////////////////////
//write data 
//02 Page Program
//a2 Dual Input Fast Program
//d2 Dual Input Extended Fast Program 
//32 Quad Input Fast Program 
//12 Quad Input Extended Fast Program 
//42 Program OTP
assign write_data = inst_lhb_2 & (inst_hhb_0 | inst_hhb_a | inst_hhb_d | inst_hhb_3 | inst_hhb_1 | inst_hhb_4);
///////////////////////////////////////////////////////
//Just send Inst
//06 Write Enable
//04 Write Disable
//50 Clear Flag Status Register
//7a Program / erase Resume
//75 Program / Erase Suspend
assign just_inst = (inst_hhb_0 & (inst_lhb_6 | inst_lhb_4))| 
		   (inst_hhb_5 & inst_lhb_0) |
		   (inst_hhb_c & inst_lhb_7) |
		   (inst_lhb_a | inst_lhb_5) & inst_hhb_7 ;
///////////////////////////////////////////////////////
//Read the chip register
//05 Read Status Reg
//b5 Read NV Configuration Register
//85 Read Volatile Configuration Register
//65 Read Volatile Enhanced Configuration Register
//70 Read Flag Status Register
//e8 Read Lock Register
assign reg_read = inst_lhb_5 & (inst_hhb_0 | inst_hhb_b | inst_hhb_8 | inst_hhb_6 ) |
		  inst_lhb_0 & inst_hhb_7 |
		  inst_lhb_8 & inst_hhb_e ;
////////////////////////////////////////////////////////
//Write the chip resgiter
//01 Write Status Reg
//b1 Write NV Configuration Register 
//81 Write Volatile Configuration Register
//61 Write Volatile Enhanced Configuration Register 
//e5 Write Lock Register 
assign reg_write = inst_lhb_1 & (inst_hhb_0 | inst_hhb_b | inst_hhb_8 | inst_hhb_6) |//0x01 0xb1 0x81 0x61
		   inst_lhb_5 & inst_hhb_e ; //e5
//////////////////////////////////////////////////////
//Just Inst + Addr
//20 SubSector Erase
//d8 Sector Erase
assign just_inst_addr = inst_lhb_0 & inst_hhb_2 |
			inst_lhb_8 & inst_hhb_d ;
//////////////////////////////////////////////////////////
//Erase Instruction:
//20 SubSector Erase
//D8 Sector Erase
//C7 Bulk Erase    
assign erase_en = inst_lhb_0 & inst_hhb_2 |
		  inst_lhb_8 & inst_hhb_d |
		  inst_lhb_7 & inst_hhb_c ;  


assign io_buf_req_valid = io_flash_req_valid & ~inst_xcpt;
//gen the control signal
assign io_buf_req_inst = inst;
assign io_buf_req_wr_en = write_data | reg_write;
assign io_buf_req_rd_en = dummy_read_data | read_data | reg_read ;
assign io_buf_req_addr_en = write_data | read_data | dummy_read_data | just_inst_addr;
assign io_buf_req_dummy_en = dummy_read_data ;
assign io_buf_req_erase_en = erase_en ;


//gen the data signal 
assign io_buf_req_dummy_size = 8'b1;
assign io_buf_req_addr = io_flash_req_addr;
wire [7:0] spi_mode_dummy_burstlen;
wire [7:0] dpi_mode_dummy_burstlen;
wire [7:0] qpi_mode_dummy_burstlen;
//spi mode  
//	one size need 4 clock
//	QIOFR   unsport because it need 10 clock 
//	others dummy read inst need 8 clock 
assign spi_mode_dummy_burstlen = 8'h2;
//dpi mode 
//	one size need 2 clock
//	all dummy read need 8 clock
assign dpi_mode_dummy_burstlen = 8'h4;
//qpi mode
//	one size need 1 clock 
//	all dummy read need 10 clock
assign qpi_mode_dummy_burstlen = 8'ha;
assign io_buf_req_dummy_burstlen = io_tran_spi_mode ? spi_mode_dummy_burstlen :
				   io_tran_dpi_mode ? dpi_mode_dummy_burstlen :
				   qpi_mode_dummy_burstlen ; 
//gen the mode select signal 
assign io_buf_req_addr_mode_en = inst_lhb_b & (inst_hhb_b | inst_hhb_e ) |
				 inst_lhb_2 & (inst_hhb_a | inst_hhb_d );
assign io_buf_req_addr_spi_mode = 1'b0 ;
assign io_buf_req_addr_dpi_mode = inst_lhb_b  & inst_hhb_6  |
				  inst_lhb_2 & inst_hhb_d ;
assign io_buf_req_data_mode_en = inst_lhb_b  & (inst_hhb_3 | inst_hhb_b | inst_hhb_6 | inst_hhb_e) | 
				 inst_lhb_2 & (inst_hhb_a | inst_hhb_b | inst_hhb_3 | inst_hhb_e);
assign io_buf_req_data_spi_mode = 1'b0;
assign io_buf_req_data_dpi_mode = inst_lhb_b  & (inst_hhb_3 | inst_hhb_b ) | 
				  inst_lhb_2 & (inst_hhb_a | inst_hhb_b );

//check the exception
//illegal instruction
wire illegal_inst ;

assign illegal_inst = ~(just_inst | 
			just_inst_addr | 
			dummy_read_data | 
			read_data | 
			write_data |
			reg_read |
			reg_write);

//wr disable 
wire wr_disable;
assign wr_disable  = ~io_interface_lev_wren & write_data ;

//instruction no suport
//	spi_mode
//		MIORDID
//	dpi_mode 
//		QOFR,QIOFR,QIFP,QIEFP
//	qpi_mode
//		DOFR,DIOFR,DIFP,DIEFP
wire inst_not_support;
assign inst_not_support = io_tran_spi_mode ? (inst_lhb_a & inst_hhb_f) :
			  io_tran_dpi_mode ? (inst_lhb_b & (inst_hhb_6 | inst_hhb_e) | inst_lhb_2 & (inst_hhb_3 | inst_hhb_1)) :
			  inst_lhb_b & (inst_hhb_3 | inst_hhb_b) | inst_lhb_2 & (inst_hhb_a | inst_hhb_d); 
reg flash_resp_error_r;
wire flash_resp_error_pre;
assign flash_resp_error_pre = inst_xcpt ;
assign inst_xcpt = illegal_inst | wr_disable | inst_not_support ;
reg [1:0] flash_resp_cause_r;
wire [1:0] flash_resp_cause_pre ;
assign flash_resp_cause_pre = 	illegal_inst ? 2'b01 :
				wr_disable ? 2'b10 :
				inst_not_support ? 2'b11 :
				2'b00;

reg flash_resp_valid_r;
always @(posedge clock or negedge rst_n)
	if(!rst_n)
	begin
		flash_resp_error_r <= 1'b0 ;
		flash_resp_cause_r <= 2'b0 ;
		flash_resp_valid_r <= 1'b0 ;
	end
	else
	begin
		flash_resp_error_r <= flash_resp_error_pre ;
		flash_resp_cause_r <= flash_resp_cause_pre ;
		flash_resp_valid_r <= flash_req ;
	end
 
assign io_flash_resp_error = flash_resp_error_r ;
assign io_flash_resp_cause = flash_resp_cause_r ;
assign io_flash_resp_valid = flash_resp_valid_r ;
`endif

`ifdef IS25LP128
wire inst_xcpt;

wire dummy_read_data;
wire dummy_read_without_addr;

/////////////////////////////////////////////
//read data with dummy data 
//0b Fast Read Node 		SPI/QPI
//bb Fast Read Dual I/O         SPI
//3b Fast Read Dual Output	SPI
//eb Fast Read Quad I/O		SPI/QPI
//6b Fast Read Quad Ouput 	SPI
//0d Fast Read DTR Mode         SPI
//bd Fast Read Dual I/O DTR     SPI
//ed Fast Read Quad I/O DTR     SPI/QPI
//4b Read Unique ID		SPI/QPI
//5a SFDO Read 			SPI/QPI 
assign  dummy_read_data = inst_lhb_b & (inst_hhb_0 | inst_hhb_b | inst_hhb_3 | inst_hhb_e | inst_hhb_6 | inst_hhb_4) | 
			  inst_lhb_d & (inst_hhb_0 | inst_hhb_b | inst_hhb_e);
////////////////////////////////////////////
//dummy read without addr
//ab Read ID / Release Power Down	SPI/QPI
//68 Read Information Row 		SPI/QPI
assign dummy_read_without_addr = inst_lhb_b & inst_hhb_a |
				      inst_lhb_8 & inst_hhb_6 ;

///////////////////////////////////////////
//read data without dummy data 
//90 Read Manufacturer & Device ID
wire  read_data = inst_lhb_0 & inst_hhb_9;
//////////////////////////////////////////
//write data
//02 Page Program  		SPI/QPI
//32 Quad Input Page Program    SPI
//38 Quad Input Page Program    SPI
//62 Program Information Row 	SPI/QPI
wire write_data = inst_lhb_2 & (inst_hhb_0 | inst_hhb_3 | inst_hhb_6 ) |
		  inst_lhb_8 & inst_hhb_3;
/////////////////////////////////////////////
//just instruction
//c7
//-60 Chip Erase		SPI/QPI
//-06 Write Enable       SPI/QPI
//-04 Write Disable      SPI/QPI
//-35 Enter QPI mode	SPI
//-f5 Exit QPI mode 	QPI
//-75 
//-b0 Suspend During program/erase SPI/QPI
//7a 
//-30 Resume During program/erase SPI/QPI
//b9 Deep Power Down	SPI/QPI
//-20 Sector Lock	SPI/QPI
wire just_inst = inst_lhb_0 & (inst_hhb_6 | inst_hhb_b | inst_hhb_3 | inst_hhb_2) |
		 inst_lhb_5 & (inst_hhb_3 | inst_hhb_f | inst_hhb_7) |
		 inst_hhb_0 & (inst_lhb_6 | inst_lhb_4) |
		 inst_hhb_c & inst_lhb_7 |
		 inst_hhb_7 & inst_lhb_a |
		 inst_hhb_b & inst_lhb_9 ;
/////////////////////////////////////////////////////////
//just inst + addr
//d7
//20 Sector Erase		SPI/QPI
//52 Block Erase 32K 		SPI/QPI
//d8 Block Erase 64K		SPI/QPI
//64 Erase Information Row	SPI/QPI
//26 Sector Unlock 		SPI/QPI
wire just_inst_addr = inst_hhb_d & (inst_lhb_7 | inst_lhb_8) |
		      inst_hhb_2 & (inst_lhb_0 | inst_lhb_6) |
		      inst_hhb_5 & inst_lhb_2 |
		      inst_hhb_6 & inst_lhb_4 ;

//////////////////////////////////////////
//read register
//05 Read Status Register
//48 Read Function Register
//9f Read JEDEC ID Common
wire reg_read  = inst_hhb_0 & inst_lhb_5 |
		 inst_hhb_4 & inst_lhb_8 |
		 inst_hhb_9 & inst_lhb_f ;
//////////////////////////////////////////
//write register
//01 Write Status Register
//42 Write Function Register
//c0 Set Read Parameter

wire reg_write = inst_hhb_0 & inst_lhb_1 | 
		 inst_hhb_4 & inst_lhb_2 |
		 inst_hhb_c & inst_lhb_0 ;
/////////////////////////////////////////
//erase instruction
//20 Sector Erase               SPI/QPI
//52 Block Erase 32K            SPI/QPI
//d8 Block Erase 64K            SPI/QPI
//64 Erase Information Row      SPI/QPI
//60 Chip Erase                SPI/QPI

wire erase_en  = inst_hhb_d & (inst_lhb_7 | inst_lhb_8) |
                 inst_hhb_2 & (inst_lhb_0 | inst_lhb_6) |
                 inst_hhb_5 & inst_lhb_2 |
		 inst_hhb_6 & inst_lhb_0;


/////////////////////////////////////////////////
//gen the ctrl signal 
assign io_buf_req_valid = io_flash_req_valid & ~inst_xcpt;

assign io_buf_req_inst = inst;
assign io_buf_req_wr_en = write_data | reg_write;
assign io_buf_req_rd_en = dummy_read_data | read_data | reg_read |dummy_read_without_addr ;
assign io_buf_req_addr_en = write_data | read_data | dummy_read_data | just_inst_addr;
assign io_buf_req_dummy_en = dummy_read_data | dummy_read_without_addr;
assign io_buf_req_erase_en = erase_en ;

//gen the data signal
assign io_buf_req_dummy_size = 8'b1;
assign io_buf_req_addr = io_flash_req_addr;

wire [7:0] spi_mode_dummy_burstlen;
wire [7:0] dpi_mode_dummy_burstlen;
wire [7:0] qpi_mode_dummy_burstlen;
//spi mode -- a size need 4 clock
//      Fast Read 		0b	: 	8 clock     2		 
//      Fast Read DTR 		0d	:	4 clock     1
//      Fast Read Dual output 	3b	:	8 clock     2
//	Fast Read Dual IO 	bb	:	4 clock     1
//	Fast Read Dual IO DTR	bd	:	2 clock not support 
//	Fast Read Quad Output 	6b	:	8 clock     2
//	Fast Read Quad IO 	eb	:	6 clock not support
//	Fast Read Quad IO DTR	ed	:	3 clock not support
assign spi_mode_dummy_burstlen = inst_lhb_b & (inst_hhb_0 | inst_hhb_3) ? 8'h2 : 8'h1;
//qpi mode -- a size need 1 clock 
//      Fast Read 		0b 	:	6 clock
//      Fast Read Quad IO	eb	:	6 clock
//	Fast Read Quad IO DTR   ed	:	3 clock
assign qpi_mode_dummy_burstlen = inst_lhb_b & (inst_hhb_0 | inst_hhb_e) ? 8'h6 : 
				 inst_lhb_d & inst_hhb_e ? 8'h3 :
				 8'h1;

assign dpi_mode_dummy_burstlen = 8'h1;
assign io_buf_req_dummy_burstlen = io_tran_spi_mode ? spi_mode_dummy_burstlen :
                                   io_tran_dpi_mode ? dpi_mode_dummy_burstlen :
                                   qpi_mode_dummy_burstlen ;


//gen the mode select signal
/////////////////////////////////////////////
//addr mode en
//bb Fast Read Dual IO 		01	
//eb Fast Read Quad IO          00
//bd Fast Read Dual IO DTR      01
//ed Fast Read Quad IO DTR      00
assign io_buf_req_addr_mode_en = (inst_lhb_b | inst_lhb_d) & (inst_hhb_b | inst_hhb_e ) ;
assign io_buf_req_addr_spi_mode = 1'b0 ;
assign io_buf_req_addr_dpi_mode = inst_hhb_b  & (inst_lhb_b  | inst_lhb_d);
//////////////////////////////////////////////
//data mode en
//
//bb Fast Read Dual IO          01
//eb Fast Read Quad IO          00
//bd Fast Read Dual IO DTR      01
//ed Fast Read Quad IO DTR      00
//3b Fast Read Dual Output      01
//6b Fast Read Quad Output 	00
//32/38 Quad Input Page Program 00
	
assign io_buf_req_data_mode_en = inst_lhb_b & (inst_hhb_3 | inst_hhb_b | inst_hhb_6 | inst_hhb_e) |
                                 inst_hhb_3 & (inst_lhb_2 | inst_lhb_8) | 
				 inst_lhb_d & (inst_hhb_b | inst_hhb_e );
assign io_buf_req_data_spi_mode = 1'b0;
assign io_buf_req_data_dpi_mode = inst_lhb_b  & (inst_hhb_3 | inst_hhb_b ) |
                                  inst_lhb_d & inst_hhb_b;
//check the exception
//illegal instruction
wire illegal_inst ;

assign illegal_inst = ~(just_inst |			//inst
                        just_inst_addr |		//inst + addr
			dummy_read_without_addr |	//inst + dummy + rdata
                        dummy_read_data |		//inst +addr + dummy + rdata
                        read_data |			//inst + addr + rdata
                        write_data |                    //inst + addr +wdata
                        reg_read |                      //inst + rdata
                        reg_write);                     //inst + wdata

//wr disable
wire wr_disable;
assign wr_disable  = ~io_interface_lev_wren & write_data ;

//instruction no suport:Is25LP128 not support DPI mode
//      spi_mode
//      	Fast Read Dual IO DTR   bd      :       2 clock not support
//	 	Fast Read Quad IO       eb      :       6 clock not support
//		Fast Read Quad IO DTR   ed      :       3 clock not support
//		Exit QPI mode		f5	QPI
//		Read JEDEC ID QPI mode	af	QPI
//      qpi_mode
//              Fast Read Dual Output   3b      SPI
//		Fast Read Quad Output   6b      SPI
//		Fast Read DTR Mode 	0d	SPI
//		Fast Read Dual I/O DTR  bd      SPI
//		Quad Input Page Program 32/38	SPI
//		Enter QPI mode  	35	SPI
wire inst_not_support;
wire spi_mode_not_support ;
wire qpi_mode_not_support ;
assign spi_mode_not_support = inst_hhb_e & (inst_lhb_b | inst_lhb_d) | 
			      inst_hhb_b & inst_lhb_d |
			      inst_hhb_f & inst_lhb_5 |
			      inst_hhb_a & inst_lhb_f ;
assign qpi_mode_not_support = inst_lhb_b &  inst_hhb_6 |
			      inst_lhb_d & (inst_hhb_0 | inst_hhb_b) |
			      inst_hhb_3 & (inst_lhb_b | inst_lhb_2 | inst_lhb_8 | inst_lhb_5);

assign inst_not_support = io_tran_spi_mode ? spi_mode_not_support :
                          qpi_mode_not_support;


reg flash_resp_error_r;
wire flash_resp_error_pre;
assign flash_resp_error_pre = inst_xcpt ;
assign inst_xcpt = illegal_inst | wr_disable | inst_not_support ;
reg [1:0] flash_resp_cause_r;
wire [1:0] flash_resp_cause_pre ;
assign flash_resp_cause_pre =   illegal_inst ? 2'b01 :
                                wr_disable ? 2'b10 :
                                inst_not_support ? 2'b11 :
                                2'b00;

reg flash_resp_valid_r;
always @(posedge clock or negedge rst_n)
        if(!rst_n)
        begin
                flash_resp_error_r <= 1'b0 ;
                flash_resp_cause_r <= 2'b0 ;
                flash_resp_valid_r <= 1'b0 ;
        end
        else
        begin
                flash_resp_error_r <= flash_resp_error_pre ;
                flash_resp_cause_r <= flash_resp_cause_pre ;
                flash_resp_valid_r <= flash_req ;
        end

assign io_flash_resp_error = flash_resp_error_r ;
assign io_flash_resp_cause = flash_resp_cause_r ;
assign io_flash_resp_valid = flash_resp_valid_r ;

`endif

`ifdef QSPI_SIM
integer qspi_inst_log;
initial begin
	qspi_inst_log = $fopen("qspi_inst_decode.log");
end

always@(posedge clock or negedge rst_n)
	if(!rst_n)
		;
	else
	if(io_flash_req_valid & io_flash_req_ready)
	begin
		$fwrite(qspi_inst_log,"Inst:[%h],FromCtrlChannel[%h],",io_flash_req_inst,io_flash_req_inst_label);
		if(just_inst)
			$fwrite(qspi_inst_log,"just_inst");
		else if(just_inst_addr)
			$fwrite(qspi_inst_log,"just_inst_addr");
		else if(dummy_read_data)
			$fwrite(qspi_inst_log,"dummy_read_data");
		else if(read_data)
			$fwrite(qspi_inst_log,"read_data");
		else if(write_data)
			$fwrite(qspi_inst_log,"write_data");
		else if(reg_read)
			$fwrite(qspi_inst_log,"reg_read");
		else if(reg_write)
			$fwrite(qspi_inst_log,"reg_write");
		else
			$fwrite(qspi_inst_log,"illegal Inst");
		$fwrite(qspi_inst_log,"\n");
		$fwrite(qspi_inst_log,"ctrl signal:\n");
		$fwrite(qspi_inst_log,"\twrite enable:\t%b",io_buf_req_wr_en);
		$fwrite(qspi_inst_log,"\tread enable:\t%b",io_buf_req_rd_en);
		$fwrite(qspi_inst_log,"\taddr enable:\t%b",io_buf_req_addr_en);
		$fwrite(qspi_inst_log,"\taddr:\t%b",io_buf_req_addr);
		$fwrite(qspi_inst_log,"\tdata size:\t%h",io_buf_req_data_size);
		$fwrite(qspi_inst_log,"\tdata burstlen:\t%h",io_buf_req_data_burstlen);
		$fwrite(qspi_inst_log,"\tdummy enable:\t%b", io_buf_req_dummy_en);
		$fwrite(qspi_inst_log,"\tdummy size:\t%h", io_buf_req_dummy_size);
		$fwrite(qspi_inst_log,"\tdummy burstlen:\t%h", io_buf_req_dummy_burstlen);
		$fwrite(qspi_inst_log,"\taddr mode en:\t%b", io_buf_req_addr_mode_en);
		$fwrite(qspi_inst_log,"\taddr spi mode:\t%b",io_buf_req_addr_spi_mode);
		$fwrite(qspi_inst_log,"\taddr dpi mode:\t%b",io_buf_req_addr_dpi_mode);
		$fwrite(qspi_inst_log,"\tdata mode en:\t%b",io_buf_req_data_mode_en);
		$fwrite(qspi_inst_log,"\tdata spi mode:\t%b",io_buf_req_data_spi_mode);
		$fwrite(qspi_inst_log,"\tdata dpi mode:\t%b\n",io_buf_req_data_dpi_mode);
	end


	


`endif


endmodule
