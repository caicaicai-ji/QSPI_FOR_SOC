///////////////////////////////////////////////////////////////////////
// Verification Plan 
//--------------------------------------------------------------------------------
//Section 1:Function Verification 
//	1.Verification the Control Channel Register Function 
//		1.1.Verification FlashCtrl bits op and its inst gen at normal mode
//		1.2.Verification FlashDivide and the divide of sck 
//		1.3.Verification the Program mode and inst tran
//	2.Verification the Data Channel 
//		2.1 Verification Data Req and its inst gen 
//	3.Verification the inst decode 
//		3.1 Verification the signal ctrl gen by decoder
//		3.2 Verification the size/burstlen gen by decoder
//		3.3 Verification the Exception at program mode
//	4.Verification the tran rec 
//		4.1 Verification the tran data 
//		4.2 Verification the rec data 
//---------------------------------------------------------------------------------------
//Section 2:Assertion & Coverage
//	1. the signal ****_clr at module cchan_inst_gen must be at most one to be high
//	2. 

//-----------------------------------------------------------------------------------
//Section 1 : Function Verification 
//verification report
//	report format: 
//		label \n       
//		\tshould message 
//		\ttest message
//		\tPASS?[]
//		endlabel
//	note:label is the number of verification plan
//`define IS25LP128

`include "/home/liaoll/project/WH/trust_verification/uvm/soc_sim/monitor/QSPI/veri/qspi_define.v"
`ifdef IS25LP128
integer veri_rpt_log;
initial begin
	veri_rpt_log = $fopen("../sim_log/qspi_veri.rpt");
end
//////////////////////////////////////////////////////////////
//qspi clock and rst_n
wire qspi_clock = /**/dut.U_w01_core.U_Core.U_qspi_ctl.clock;
wire qspi_rst_n = /**/dut.U_w01_core.U_Core.U_qspi_ctl.rst_n;

//      1.Verification the Control Channel Register Function
//		1.1 Verification FlashCtrl bits op and its inst gen at normal mode


wire cchan_req_valid=/**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_cchan_inst_gen.io_cchan_req_valid;
wire cchan_req_ready=/**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_cchan_inst_gen.io_cchan_req_ready;
wire[7:0] cchan_req_inst=/**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_cchan_inst_gen.io_cchan_req_inst;
wire[23:0] cchan_req_addr = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_cchan_inst_gen.io_cchan_req_addr;
//
//FlashCtrlReg
//	15	14	13	12	11	10	9	8	7	6	5	4	3	2	1	0	
//     mode     st      ie     flush   wren   reserve wrcsr   rdcsr    ser     ber64  ber32    cer    qpidi   eqpi    dpidi   edpi
wire flash_ctrl_mode  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_qspi_ctrl_mode;

wire flash_ctrl_st    = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_pmode_start;

`ifdef NETLIST_SIM
wire flash_ctrl_ie    = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.flash_ctrl_reg_13;
`else
wire flash_ctrl_ie    = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.flash_ctrl_ie;
`endif

`ifdef NETLIST_SIM
wire flash_ctrl_flush = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.n13;
`else
wire flash_ctrl_flush = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.flash_ctrl_flush;
`endif

wire flash_ctrl_wren  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_interface_lev_wren;
wire flash_ctrl_wrcsr = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_wrcsr;
wire flash_ctrl_rdcsr = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_rdcsr;
wire flash_ctrl_ser   = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_ser;
wire flash_ctrl_ber64 = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_ber64;
wire flash_ctrl_ber32 = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_ber32;
wire flash_ctrl_cer   = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_cer;
wire flash_ctrl_qpidi = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_qpidi;
wire flash_ctrl_eqpi  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_eqpi;
wire flash_ctrl_dpidi =/**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_dpidi;
wire flash_ctrl_edpi  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_cchan_edpi;
//
//FlashCsrReg 
//   7:0
wire[7:0] flash_csr_reg = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.flash_csr; 
//
//FlashStateReg
//	7	6	5	4	3	   2		1     0
//      flash mode          csr     ctrl_mode  rd_finish         cause
// flash mode
//	00:qpi mode
//	01:spi mode
//	10:dpi mode 
//csr:
//   00	SR 
//   01 FR

wire [1:0] flash_state_flash_mode = /**/{dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_tran_dpi_mode,dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_tran_spi_mode};
wire [1:0] flash_state_csr = dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_flash_state_csr;
wire flash_state_ctrl_mode = dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_qspi_ctrl_mode;
`ifdef NETLIST_SIM
wire flash_state_rd_finish = dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.flash_state_reg_2;
`else
wire flash_state_rd_finish = dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.flash_state_rd_finish;
`endif

wire [1:0] flash_state_cause = dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.flash_state_cause;

reg [7:0] should_inst;
reg [7:0] actual_inst;
//print the report of 1.1
reg report_en_1_1 ;
always@(posedge qspi_clock or negedge qspi_rst_n)
	if(!qspi_rst_n)
	begin
		should_inst <= 8'b0;
		actual_inst <= 8'b0;
		report_en_1_1 <= 1'b0;
	end
	else
		if(cchan_req_valid & cchan_req_ready & ~flash_ctrl_mode)
		begin
			actual_inst <= cchan_req_inst;
			if(flash_ctrl_edpi)
				should_inst <= `DPIEN;
			else if(flash_ctrl_dpidi)
				should_inst <= `DPIDI;
			else if(flash_ctrl_eqpi)
				should_inst <= `QPIEN;
			else if(flash_ctrl_qpidi)
				should_inst <= `QPIDI;
			else if(flash_ctrl_cer)
				should_inst <= `CER;
			else if(flash_ctrl_ber32)
				should_inst <= `BER32;
			else if(flash_ctrl_ber64)
				should_inst <= `BER64;
			else if(flash_ctrl_ser)
				should_inst <= `SER;
			else if(flash_ctrl_rdcsr)
			begin
				if(flash_state_csr == 2'b0)
					should_inst <= `RDSR;
				else if(flash_state_csr == 2'b1)
					should_inst <= `RDFR;
			end
			else if(flash_ctrl_wrcsr)
			begin
                                if(flash_state_csr == 2'b0)
                                        should_inst <= `WRSR;
                                else if(flash_state_csr == 2'b1)
                                        should_inst <= `WRFR;
			end
			else
				should_inst <= 8'b0;
			report_en_1_1 <= 1'b1;
		end
		else
			report_en_1_1 <= 1'b0;
wire [7:0] pass_message_1_1 = should_inst==actual_inst ? "Y" : "N";
always @(posedge qspi_clock or negedge qspi_rst_n)
	if(!qspi_rst_n)
		;
	else if(report_en_1_1)
		$fwrite(veri_rpt_log,"PLAN1_1\n\tshould:inst[%h]\n\tactual:inst[%h]\n\tPASS?[%s]\nENDPLAN1_1\n",should_inst,actual_inst,pass_message_1_1);

//              1.2.Verification FlashDivide and the divide of sck
wire qspi_sck = /**/dut.U_w01_core.U_Core.U_qspi_ctl.io_qspi_sck;
wire[31:0]  flash_divide_reg = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_clk_divide_param;

reg [31:0] flash_divide_reg_d;
always@(posedge qspi_clock or negedge qspi_rst_n)
	if(!qspi_rst_n)
		flash_divide_reg_d <= 32'b0;
	else
		flash_divide_reg_d <= flash_divide_reg;
integer clock_cnt;
always@(posedge qspi_clock or negedge qspi_rst_n)
	if(!qspi_rst_n)
		clock_cnt <= 0;
	else	
		clock_cnt <= clock_cnt + 1;
//first detect 
integer sck_start,sck_end;
wire [7:0] pass_message_1_2 = (sck_end-sck_start) == ((flash_divide_reg+2+1)*2) ? "Y" : "N" ;
initial begin
	sck_end=0;
	sck_start=0;
	@(posedge qspi_sck)
		sck_start = clock_cnt;
	@(posedge qspi_sck)
		sck_end = clock_cnt ;
	@(posedge qspi_sck)
		$fwrite(veri_rpt_log,"PLAN1_2\n\tshould:clk divided[%0d]\n\tactual:clk divided[%0d]\n\tPASS?[%s]\nENDPLAN1_2\n",
			(flash_divide_reg+1+2)*2,
			sck_end-sck_start,
			pass_message_1_2);
end

always@(posedge qspi_clock or negedge qspi_rst_n) 	
	if(qspi_rst_n)
		;
	else if(flash_divide_reg_d != flash_divide_reg)
	begin
		@(posedge qspi_sck) ;
		@(posedge qspi_sck)
			sck_start = clock_cnt;
		@(posedge qspi_sck)
			sck_end = clock_cnt;
	        @(posedge qspi_sck)
			$fwrite(veri_rpt_log,"PLAN1_2\n\tshould:clk divided[%d]\n\tactual:clk divided[%d]\n\tPASS?[%s]\nENDPLAN1_2\n",
	                	sck_end-sck_start,
	                	(flash_divide_reg+1+2)*2,
	                	pass_message_1_2);
	end
//              1.3.Verification the Program mode and inst tran
//addr register
wire [7:0] flash_addr_inst = dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_pmode_inst;
wire [23:0] flash_addr_addr = dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_ahb_if.io_pmode_addr;
wire [7:0] pass_message_1_3 = flash_addr_inst == cchan_req_inst && flash_addr_addr == cchan_req_addr ? "Y" : "N";
always@(posedge qspi_clock or negedge qspi_rst_n)
	if(!qspi_rst_n)
		;
	else if(cchan_req_valid & cchan_req_ready & flash_ctrl_mode)
		$fwrite(veri_rpt_log,"PLAN1_3\n\tshould:inst[%h],addr[%h]\n\tactual:inst[%h],addr[%h]\n\tPASS?[%s]\nENDPLAN1_3\n",
			flash_addr_inst,
			flash_addr_addr,
			cchan_req_inst,
			cchan_req_addr,
			pass_message_1_3);

//      2.Verification the Data Channel
//              2.1 Verification Data Req and its inst gen
wire dchan_req_valid = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_dchan_req_valid;
wire dchan_req_ready = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_dchan_req_ready; 
wire [7:0] dchan_req_inst = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_dchan_req_inst;
wire [23:0]dchan_req_addr = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_dchan_req_addr;
wire [4:0] dchan_req_size = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_dchan_req_data_size;
wire [7:0] dchan_req_burstlen = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_dchan_req_data_burstlen;

wire axi_aw_valid        = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_aw_valid;
wire axi_aw_ready        = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_aw_ready;
wire [23:0] axi_aw_addr  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_aw_bits_addr; 
wire [2:0] axi_aw_size   = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_aw_bits_size;
wire [7:0] axi_aw_len    = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_aw_bits_len;
wire axi_ar_valid        = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_ar_valid;
wire axi_ar_ready        = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_ar_ready;
wire [23:0] axi_ar_addr  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_ar_bits_addr;
wire [2:0]  axi_ar_size  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_ar_bits_size;
wire [7:0]  axi_ar_len   = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_interface_level.U_interface_qspi_axi4_if.io_axi4_0_ar_bits_len;

wire[7:0]   dchan_should_inst= axi_aw_valid ? `PP : 
	                 axi_ar_valid ? `FRQIO :
	                 8'b0;

wire [23:0] dchan_should_addr = axi_aw_valid ? axi_aw_addr : 
	                   axi_ar_valid ? axi_ar_addr :
		           24'b0;
//size : 2^n byte = 2^(n+1) half byte
//equal: 1<<(size+1)
wire[4:0]  dchan_should_size = axi_aw_valid ? (5'b1<<(axi_aw_size+5'b1)) :
	                 axi_ar_valid ? (5'b1<<(axi_ar_size+5'b1)) :
		         5'b0;
wire[7:0] dchan_should_burstlen = axi_aw_valid ? (axi_aw_len + 8'b1) :
			    axi_ar_valid ? (axi_ar_len + 8'b1) :
			    8'b0;
wire [7:0] pass_message_2_1 = (dchan_should_inst == dchan_req_inst) && 
			      (dchan_should_addr == dchan_req_addr) && 
			      (dchan_should_size == dchan_req_size) && 
			      (dchan_req_burstlen == dchan_should_burstlen) ? "Y" : "N" ;
always@(posedge qspi_clock or negedge qspi_rst_n)
	if(!qspi_rst_n)
		;
	else if(dchan_req_valid & dchan_req_ready)
		$fwrite(veri_rpt_log,"PLAN2_1\n\tshould:inst[%h],addr[%h],data_size[%d],data_burstlen[%d]\n\t\
actual:inst[%h],addr[%h],data_size[%d],data_burstlen[%d]\n\t\
PASS?[%s]\nENDPLAN2_1\n",
				dchan_should_inst,dchan_should_addr,dchan_should_size,dchan_should_burstlen,
				dchan_req_inst,dchan_req_addr,dchan_req_size,dchan_req_burstlen,
				pass_message_2_1);
		

//      3.Verification the inst decode
//              3.1 Verification the signal ctrl gen by decoder
wire[7:0] buf_inst = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_buf_req_inst;
wire buf_valid     = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_buf_req_valid ;
wire buf_ready     = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_buf_req_ready ;
wire buf_wr_en     = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_buf_req_wr_en ;
wire buf_rd_en     = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_buf_req_rd_en ;
wire buf_addr_en   = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_buf_req_addr_en ;
wire buf_erase_en  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_buf_req_erase_en ;
wire buf_dummy_en  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_buf_req_dummy_en ;
wire should_buf_wr_en    = 	buf_inst == 8'h02 | //PP
			   	buf_inst == 8'h32 | //PPQ
				buf_inst == 8'h38 | //PPQ
				buf_inst == 8'h01 | //WRSR
				buf_inst == 8'h42 | //WRFR
				buf_inst == 8'hc0 | //SRP
				buf_inst == 8'h62 ; //IRP

wire should_buf_rd_en    = 	buf_inst == 8'h03 | //NORD
				buf_inst == 8'h0b | //FRD
				buf_inst == 8'hbb | //FRDIO
				buf_inst == 8'h3b | //FRDO
				buf_inst == 8'heb | //FRQIO
				buf_inst == 8'h6b | //FRQO
				buf_inst == 8'h0d | //FRDTR
				buf_inst == 8'hbd | //FRDDTR
				buf_inst == 8'hed | //FRQDTR
				buf_inst == 8'h05 | //RDSR
				buf_inst == 8'h48 | //RDFR
				buf_inst == 8'hab | //RDID
				buf_inst == 8'h9f | //RDJDID
				buf_inst == 8'h90 | //RDMDID
				buf_inst == 8'haf | //RDJDIDQ
				buf_inst == 8'h4b | //RDUID
				buf_inst == 8'h5a | //RDSFDP
				buf_inst == 8'h68 ; //IRRD 

wire should_buf_addr_en  =	buf_inst == 8'h03 | //NORD 
				buf_inst == 8'h0b | //FRD
				buf_inst == 8'hbb | //FRDIO
				buf_inst == 8'h3b | //FRDO
				buf_inst == 8'heb | //FRQIO
				buf_inst == 8'h6b | //FRQO
				buf_inst == 8'h0d | //FRDTR
				buf_inst == 8'hbd | //FRDDTR
				buf_inst == 8'hed | //FRDQTR
				buf_inst == 8'h02 | //PP
				buf_inst == 8'h32 | //PPQ
				buf_inst == 8'h38 | //PPQ
				buf_inst == 8'hd7 | //SER
				buf_inst == 8'h20 | //SER
				buf_inst == 8'h52 | //BER32
				buf_inst == 8'hd8 | //BER64
				buf_inst == 8'h4b | //RDUID
				buf_inst == 8'h5a | //RDSFDP
				buf_inst == 8'h64 | //IRER
				buf_inst == 8'h62 | //IRP
				buf_inst == 8'h68 | //IRRD
				buf_inst == 8'h26 ; //SEC_UNLOCK

wire should_buf_erase_en =	buf_inst == 8'hd7 | //SER
				buf_inst == 8'h20 | //SER
				buf_inst == 8'h52 | //BER32
				buf_inst == 8'hd8 | //BER64
				buf_inst == 8'hc7 | //CER
				buf_inst == 8'h60 ; //CER

wire should_buf_dummy_en = 	buf_inst == 8'h0b | //FRD
				buf_inst == 8'hbb | //FRDIO
				buf_inst == 8'h3b | //FRDO
				buf_inst == 8'heb | //FRQIO
				buf_inst == 8'h6b | //FRQO
				buf_inst == 8'h0d | //FRDTR
				buf_inst == 8'hbd | //FRDDTR
				buf_inst == 8'hed | //FRQDTR
				buf_inst == 8'hab | //RDID
				buf_inst == 8'h90 ; //RDMDID
wire [7:0] pass_message_3_1 = should_buf_wr_en     ==  buf_wr_en     &
			should_buf_rd_en     ==  buf_rd_en     &
			should_buf_addr_en   ==  buf_addr_en   &
			should_buf_erase_en  ==  buf_erase_en  &
			should_buf_dummy_en  ==  buf_dummy_en  ? "Y" : "N"; 
always@(posedge qspi_clock or negedge qspi_rst_n)
	if(!qspi_rst_n)
		;
	else if(buf_valid & buf_ready)
		$fwrite(veri_rpt_log,"PLAN3_1\n\tshould:inst[%h],wr_en[%b],rd_en[%b],addr_en[%b],erase_en[%b],dummy_en[%b]\n\t\
actual:inst[%h],wr_en[%b],rd_en[%b],addr_en[%b],erase_en[%b],dummy_en[%b]\n\t\
PASS?[%s]\nENDPLAN3_1\n",
			buf_inst,should_buf_wr_en,should_buf_rd_en,should_buf_addr_en,should_buf_erase_en,should_buf_dummy_en,
			buf_inst,buf_wr_en,buf_rd_en,buf_addr_en,buf_erase_en,buf_dummy_en,pass_message_3_1);

//              3.2 Verification the size/burstlen gen by decoder
wire qspi_spi_mode = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_tran_level.U_tran_qspi_mode_ctrl.io_tran_spi_mode;
wire qspi_dpi_mode = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_tran_level.U_tran_qspi_mode_ctrl.io_tran_dpi_mode;



wire [4:0] buf_dummy_burstlen     = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_buf_req_dummy_burstlen; 
wire [4:0] spi_dummy_burstlen     = 	buf_inst == 8'h0b ? 5'h2 :		//FRD     8clock
                              	  	buf_inst == 8'hbb ? 5'h1 :		//FRDIO   4clock
                                	buf_inst == 8'h3b ? 5'h2 :		//FRDO    8clock
                                	buf_inst == 8'h6b ? 5'h2 :		//FRQO    8clock
                                	buf_inst == 8'h0d ? 5'h1 :		//FRDTR   4clock 
                                	buf_inst == 8'hab ? 5'h6 :		//RDID    3Byte
                                	buf_inst == 8'h90 ? 5'h4 :		//RDMDID  2Byte
					5'h1;

wire [4:0] qpi_dummy_burstlen	= 	buf_inst == 8'h0b ? 5'h6 :		//FRD	   6clock	
                               	 	buf_inst == 8'heb ? 5'h6 :		//FRQIO    6clock
                                	buf_inst == 8'h0d ? 5'h6 :		//FRDTR    6clock
                                	buf_inst == 8'hed ? 5'h3 :		//FRQDTR   3clock
                                	buf_inst == 8'hab ? 5'h6 :		//RDID     3Byte
                                	buf_inst == 8'h90 ? 5'h4 :		//RDMDID   2Byte
					5'h1;
wire [4:0] should_dummy_burstlen     = 	qspi_spi_mode ? spi_dummy_burstlen : 
					~qspi_dpi_mode ? qpi_dummy_burstlen :
					5'b1;

wire [7:0] pass_message_3_2 = should_dummy_burstlen == buf_dummy_burstlen ? "Y" : "N" ;

always@(posedge qspi_clock or negedge qspi_rst_n) 
	if(!qspi_rst_n)
		;
	else if(buf_valid & buf_ready)
		$fwrite(veri_rpt_log,"PLAN3_2\n\tshould:inst[%h],dummy_burstlen[%d]\n\tactual:inst[%h],dummy_burstlen[%d]\n\tPASS?[%s]\nENDPLAN3_2\n",
				buf_inst,should_dummy_burstlen,buf_inst,buf_dummy_burstlen,pass_message_3_2);

//              3.3 Verification the inst Exception 
`ifdef NETLIST_SIM
wire decode_illegal_inst = ~ /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.n135;
`else
wire decode_illegal_inst = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.illegal_inst;
`endif
`ifdef NETLIST_SIM
//searched by signal <io_tran_spi_mode>
wire decode_not_support = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.n133 ;
`else 
wire decode_not_support = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.inst_not_support;
`endif
`ifdef NETLIST_SIM
//searched by signal <io_interface_lev_wren>
wire decode_wr_disable  = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.n134;
`else
wire decode_wr_disable = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.wr_disable;
`endif
wire should_legal_inst = buf_inst == 8'h03 |
			 buf_inst == 8'h0b |
			 buf_inst == 8'hbb |
			 buf_inst == 8'h3b |
			 buf_inst == 8'heb |
			 buf_inst == 8'h6b |
			 buf_inst == 8'h0d |
			 buf_inst == 8'hbd |
			 buf_inst == 8'hed |
			 buf_inst == 8'h02 |
			 buf_inst == 8'h32 |
			 buf_inst == 8'h38 |
			 buf_inst == 8'hd7 |
      			 buf_inst == 8'h20 |
			 buf_inst == 8'h52 |
			 buf_inst == 8'hd8 |
			 buf_inst == 8'hc7 |
			 buf_inst == 8'h60 |
			 buf_inst == 8'h06 |
			 buf_inst == 8'h04 |
			 buf_inst == 8'h05 |
			 buf_inst == 8'h01 |
			 buf_inst == 8'h48 |
			 buf_inst == 8'h42 |
			 buf_inst == 8'h35 |
			 buf_inst == 8'hf5 |
			 buf_inst == 8'h75 |
			 buf_inst == 8'hb0 |
			 buf_inst == 8'h7a |
			 buf_inst == 8'h30 |
   			 buf_inst == 8'h42 |
			 buf_inst == 8'h35 |
			 buf_inst == 8'hf5 |
			 buf_inst == 8'h75 |
			 buf_inst == 8'hb0 |
			 buf_inst == 8'h7a |
			 buf_inst == 8'h30 |
			 buf_inst == 8'hb9 |
			 buf_inst == 8'hab |
			 buf_inst == 8'hc0 |
			 buf_inst == 8'h9f |
			 buf_inst == 8'h90 |
			 buf_inst == 8'haf |
			 buf_inst == 8'h4b |
			 buf_inst == 8'h5a |
			 buf_inst == 8'h66 |
		  	 buf_inst == 8'h99 |
			 buf_inst == 8'h64 |
			 buf_inst == 8'h62 |
			 buf_inst == 8'h68 |
			 buf_inst == 8'h26 |
			 buf_inst == 8'h24 ;
wire should_illegal_inst = ~should_legal_inst;
wire should_not_support = qspi_spi_mode ?  (buf_inst == 8'hbd) | (buf_inst == 8'heb) | (buf_inst == 8'hed) | (buf_inst == 8'hf5) | (buf_inst == 8'haf) :
			  ~qspi_dpi_mode ?  (buf_inst == 8'h03) | 
					   (buf_inst == 8'hbb) |
					   (buf_inst == 8'h3b) |
					   (buf_inst == 8'h6b) |
					   (buf_inst == 8'hbd) |
					   (buf_inst == 8'h32) |
					   (buf_inst == 8'h38) |
					   (buf_inst == 8'h35)  :
			  1'b0;
wire qspi_wren = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.io_ctrl_lev_wr_en;
wire should_wr_disable = ~qspi_wren & ((buf_inst == 8'h02) |
				       (buf_inst == 8'h32) |
				       (buf_inst == 8'h38) |
				       (buf_inst == 8'hd7) |
				       (buf_inst == 8'h20) |
				       (buf_inst == 8'h52) |
				       (buf_inst == 8'hd8) |
				       (buf_inst == 8'hc7) |
				       (buf_inst == 8'h60) |
				       (buf_inst == 8'h01) |
				       (buf_inst == 8'h42) |
				       (buf_inst == 8'h64) |	
				       (buf_inst == 8'h62) );
wire decode_flash_req = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.flash_req;
wire decode_flash_error = /**/dut.U_w01_core.U_Core.U_qspi_ctl.U_qspi_ctrl_level.U_ctrl_qspi_inst_decode.flash_resp_error_pre ;

wire [7:0] pass_message_3_2 = (should_illegal_inst == decode_illegal_inst) &&
			      (should_not_support==decode_not_support) && 
			      (should_wr_disable==decode_wr_disable) ? "Y" : "N" ;
always@(posedge qspi_clock or negedge qspi_rst_n)
	if(!qspi_rst_n)
		;
	else if(decode_flash_error & decode_flash_req) 
		$fwrite(veri_rpt_log,"PLAN3_3\n\tshould:inst[%h],illegal[%b],not_support[%b],wr_disable[%b]\n\t\
actual:inst[%h],illegal[%b],not_support[%b],wr_disable[%b]\n\t\
PASS?[%s]\nENDPLAN3_3\n",
			buf_inst,should_illegal_inst,should_not_support,should_wr_disable,
			buf_inst,decode_illegal_inst,decode_not_support,decode_wr_disable,
			pass_message_3_2);

//      4.Verification the tran rec 
//              4.1 Verification the tran data



//              4.2 Verification the rec data
`endif
