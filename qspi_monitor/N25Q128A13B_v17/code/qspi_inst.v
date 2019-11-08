
N25Qxxx qspi(
	.S(qspi_ce), 
	.C(qspi_clk), 
	.HOLD_DQ3(qspi_so3), 
	.DQ0(qspi_so0), 
	.DQ1(qspi_so1), 
	.Vcc('d2700), 
	.Vpp_W_DQ2(qspi_so2)
);
