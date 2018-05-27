`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:14:39 03/29/2018 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
  input  signed	    [31:0]	alu_a,
  input  signed	    [31:0]	alu_b,
  input	            [2:0]	alu_op,
  output     reg   	    [31:0]	alu_out

);
parameter	A_NOP	= 3'h00;	//空运算 	
parameter	A_ADD	= 3'h01;	//符号加
parameter	A_SUB	= 3'h02;	//符号减
parameter	A_AND   = 3'h03;	//与
parameter	A_OR    = 3'h04;	//或
parameter	A_XOR   = 3'h05;	//异或
parameter	A_NOR   = 3'h06;	//或非
parameter	A_NEG	= 3'h07;	//负

always @(*) begin
	case (alu_op)
		A_NOP:
			alu_out<=32'b0;
		A_ADD:
			alu_out<=alu_a+alu_b;
		A_SUB:
			alu_out<=alu_a-alu_b;
		A_AND:
			alu_out<=alu_a&alu_b;
		A_OR:
			alu_out<=alu_a|alu_b;
		A_XOR:
			alu_out<=alu_a^alu_b;
		A_NOR:
			alu_out<=alu_a~^alu_b;	
		A_NOR:
			alu_out<=0-alu_a;
	endcase
	end		

endmodule