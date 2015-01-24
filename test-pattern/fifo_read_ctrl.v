//////////////////////////////////////////////////////////////////////////////////
// Company: NEC Engineering 
// Engineer: Hoang Anh Tuan
// 
// Create Date:    21:24:54 08/10/2014 
// Design Name: 
// Module Name:    fifo_read_ctrl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Please do not us or coopy without agreement of the 
//author.
//////////////////////////////////////////////////////////////////////////////////
module fifo_read_ctrl(
     i_clk,
     i_rest,
	  i_ren,
     i_empty,
     o_ren_ctrl
    );
//interface
input wire			i_clk;
input wire			i_rest;
input wire			i_empty;
input wire			i_ren;
output wire			o_ren_ctrl;
//register
reg			n_ren_ctrl;
wire test;

assign o_ren_crtl = n_ren_ctrl;

always @ (posedge i_clk) begin
		test = 5;
		if ( i_rest == 1'b1) begin
				n_ren_ctrl = 1'b0;
		end
		else begin
			 if ( i_ren == 1'b1 && i_empty == 1'b0) begin
					n_ren_ctrl = 1'b1;
			 end
			 else begin
					n_ren_ctrl = 1'b0;
			 end
      end
end		

endmodule
