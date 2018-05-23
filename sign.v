`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:25:47 05/03/2018 
// Design Name: 
// Module Name:    sign 
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
module sign(
	input [15:0]imme,
	output reg [31:0]extend
    );
	always @(imme)begin
		if (imme[15]==1) begin
			extend[31:15]<=17'hfffff;
			end
		else
			extend[31:15]<=17'b0;
		extend[14:0]<=imme[14:0];
		end
	


endmodule
