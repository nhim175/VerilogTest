`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:42:16 08/10/2014 
// Design Name: 
// Module Name:    full_empty_ctrl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module full_empty_ctrl(
     i_clk,
     i_rest,
     i_addrw,
     i_addrr,
     o_full,
     o_empty
    );
	 
//parameter
parameter   DEPTH_BIT = 4;
parameter   DEPTH_MAX = 15;
//interface
input wire								i_clk;
input wire								i_rest;
input wire		[DEPTH_BIT-1 : 0]	i_addrw;
input wire		[DEPTH_BIT-1 : 0]	i_addrr;
output wire								o_full;
output wire								o_empty;
//register
reg      [DEPTH_BIT-1 : 0]	n_addrw;
reg		[DEPTH_BIT-1 : 0]	n_addrr;
reg								n_full;
reg								n_empty;

assign	o_full = n_full;
assign	o_empty= n_empty;

always @ (posedge i_clk) begin
			if (i_rest == 1'b1) begin
				n_full  = 1'b0;
				n_empty = 1'b0;
				n_addrw = 'd0;
				n_addrr = 'd0;
			end
			else begin
				n_addrw = i_addrw;
				n_addrr = i_addrr;
				if ( i_addrw - i_addrr == DEPTH_MAX) begin
						n_full = 1'b1;
						n_empty = 1'b0;
				end
				else if (  i_addrw - i_addrr == 0)  begin
				      n_empty = 1'b0;
						n_full  = 1'b0;
				end
				else begin
						n_full = 1'b0;
                  n_empty = 1'b0;
				end
			end
end
				
endmodule
