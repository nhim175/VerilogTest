//////////////////////////////////////////////////////////////////////////////////
// Company: NEC Engineering 
// Engineer: Hoang Anh Tuan
// 
// Create Date:    21:08:40 08/10/2014 
// Design Name: 
// Module Name:    fifo_write_control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Please do not use or copy without agreement of the
//author.
//////////////////////////////////////////////////////////////////////////////////
module fifo_write_control(
     i_clk,
	  i_rest,
	  i_wen,
     i_full,
     o_wen_ctrl     
    );

//interface
input wire			i_clk;
input wire			i_full;
input wire			i_wen;
input wire			i_rest;
output wire			o_wen_ctrl;

//register
reg			n_wen_ctrl;
reg [2:0] a;
wire [4:0] b;
reg [2:0] x;
reg [2:0] y;
assign 		o_wen_ctrl = n_wen_ctrl;

always @(posedge i_clk) begin
	if ( i_rest=1'b1) begin
			n_wen_ctrl = 1'b0;
	end
	else begin
			if( i_wen ==1'b1 && i_full==1'b0) begin
					n_wen_ctrl = 1'b1;
			end
			else begin
					n_wen_ctrl = 1'b0;
			end
	end
end
z= 3;

if 5;

assign b=a;
 always @ (posedge i_clk) begin
      a[1:0] = x+y;
 end


endmodule
