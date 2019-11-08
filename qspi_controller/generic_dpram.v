# See LICENSE for license details.

module generic_dpram  #(parameter aw=8, 
	 parameter dw=32) (
        input rclk,
        input rrst,
        input [aw-1 :0 ]raddr,
        output [dw-1 : 0] dout,
        input wclk,
        input wrst,
        input we,
        input [aw-1 : 0 ] waddr,
        input [dw-1 : 0 ] di
        );

reg [dw-1:0] mem[0:1<<aw];
reg [7:0] i;
`ifdef SIM
initial begin
	for(i=0;i<255;i++)
		mem[i] = {dw{1'b0}};
end
`endif

always @(posedge wclk )
	if(we)
		mem[waddr]<=di;

assign dout = mem[raddr];
endmodule




