`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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
// Additional Comments: 
//
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

assign 		o_wen_ctrl = n_wen_ctrl;

always @(posedge i_clk) begin
	if ( i_rest==1'b1) begin
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




endmodule
