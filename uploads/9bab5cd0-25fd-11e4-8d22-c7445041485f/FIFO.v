`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:01:00 08/10/2014 
// Design Name: 
// Module Name:    FIFO 
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
module FIFO(
     i_clk,
     i_data,
     i_rest,
     i_wen,
     i_ren,
     o_data,
     o_full,
     o_empty
    );
//parameter
parameter WIDTH = 8;
parameter DEPTH = 32;
parameter UP_BIT =  (DEPTH ==16)? 4 :
						  (DEPTH ==32)? 5 : 6  ;
//interface
input wire							i_clk;
input wire		[WIDTH-1:0]		i_data;
input wire							i_rest;
input wire							i_wen;
input wire							i_ren;
output wire							o_data;
output wire							o_full;
output wire							o_empty;
//signal
wire							n_wen_ctrl;
wire							n_ren_ctrl;
wire							n_o_full;
wire                     n_o_empty;
wire		[UP_BIT-1:0]	n_addrr;
wire		[UP_BIT-1:0]	n_addrw;

assign		o_empty = n_o_empty;
assign      o_full  = n_o_full;

//components setting

fifo_write_control ff_w_ctr(
		.i_clk (i_clk),
		.i_rest(i_rest),
		.i_wen (i_wen),
		.i_full(n_o_full),
		.o_wen_ctrl (n_wen_ctrl)
		);

fifo_read_ctrl     ff_r_ctr(
		.i_clk (i_cllk),
		.i_rest(i_rest),
		.i_ren (i_ren),
		.i_empty(n_o_empty),
		.o_ren_ctrl(n_ren_ctrl)
		);

full_empty_ctrl #(UP_BIT,DEPTH) f_e_crt(
		.i_clk (i_clk),
		.i_rest(i_rest),
		.i_addrw(n_addrw),
		.i_addrr(n_addrr),
		.o_full (n_o_full),
		.o_empty(n_o_empty)
       );

fifo_mem # (WIDTH, DEPTH, UP_BIT) ff_mem (
		.i_clk(i_clk),
		.i_rest(i_rest),
		.i_wen(n_wen_ctrl),
		.i_ren(n_ren_ctrl),
		.i_data(i_data),
		.o_data(o_data),
		.o_addrw(n_addrw),
		.o_addrr(n_addrr)		
		);

endmodule




