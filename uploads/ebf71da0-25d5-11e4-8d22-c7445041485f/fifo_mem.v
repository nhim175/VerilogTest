`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:41:28 08/10/2014 
// Design Name: 
// Module Name:    fifo_mem 
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
module fifo_mem(
     i_clk,
     i_rest,
     i_wen,
     i_ren,
     i_data,
     o_data,
     o_addrw,
     o_addrr
    );
//parameter	 
parameter 	DATA_WIDTH=8; 
parameter	DATA_DEPTH=16;
parameter	UP_BIT    =4;
//interface
input wire									i_clk;
input wire									i_rest;
input wire									i_wen;
input wire									i_ren;
input wire		[DATA_WIDTH-1 : 0] 	i_data;
output wire		[DATA_WIDTH-1 : 0] 	o_data;
output wire		[UP_BIT-1:0]			o_addrw;
output wire		[UP_BIT-1:0]         o_addrr;

//register
reg		[UP_BIT-1:0]			n_addrw;
reg		[UP_BIT-1:0]         n_addrr;
reg		[DATA_WIDTH-1 : 0]   fifo_mem [0:DATA_DEPTH-1];
reg		[DATA_WIDTH-1 : 0]   n_o_data;

assign o_addrw = n_addrw;
assign o_addrr = n_addrr;
assign o_data  = n_o_data;

always @ (posedge i_clk) begin
		if ( i_rest == 1'b1) begin
				n_addrw = 'd0;
				n_addrr = 'd0;
				n_o_data= 'd0;
		end
		else begin
			//write process
				if (i_wen == 1'b1) begin
				  fifo_mem[n_addrw] = i_data;
				  if (n_addrw < DATA_DEPTH) begin
				   			n_addrw = n_addrw + 1;
              end
              else begin
                        n_addrw = 'd0;
              end
            end
            else begin
								n_addrw = n_addrw;
				end
			//read process	
				if ( i_ren == 1'b1) begin
				    n_o_data = fifo_mem [n_addrr];
					if (n_addrr < DATA_DEPTH) begin
				   			n_addrr = n_addrr + 1;
               end
               else begin
                        n_addrr = 'd0;
               end
            end
            else begin
								n_addrr = n_addrr;
				end
          end
end

endmodule
