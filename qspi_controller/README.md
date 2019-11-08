////////////////////////////////////////////////
//QSPI Controller

Feature:
	1.support falsh CHIP N25Q128 & IS25LP128
	2.support normal mdoe and program mode
	3.support clock divided by software
	
Architecture:


FIFO:
	1.flash_rdata_fifo define at qsi_ahb_if.v
		AW:5 DW:32
		Use data_fifo_32

	2.inst_fifo define at qspi_inst_buffer.v
		AW:5 DW:14
		Use info_fifo
	3.addr_fifo define at qspi_inst_buffer.v
		AW:5 DW:27
		Use addr_fifo
	4.data_info_fifo define at qspi_inst_buffer.v
		AW:3 DW:16
		Use info_fifo
	5.dummy_info_fifo define at qspi_inst_buffer.v
		AW:3 DW:13
		Use info_fifo
	6.tran_fifo define at qspi_inst_tran_rec.v
		AW:6 DW:`XLEN
		Use data_fifo_x x=32/64/128
	7.rec_fifo define at qspi_inst_tran_rec.v
		AW:6 DW:`XLEN 
		Use data_fifo_x x=32 / 64 / 128
		
Implement-FIFO:
	1.info_fifo 
		AW:5 DW:16	
		Used by 
	2.addr_fifo
		AW:5 DW:27
	3.data_fifo_32
		AW:5 DW:32
	4.data_fifo_64
		AW:6 DW:64

 
