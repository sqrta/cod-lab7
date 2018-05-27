`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:45:48 05/17/2018 
// Design Name: 
// Module Name:    top 
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
module top(
	input clk,
	input rst,
	output [31:0]regc,
	output [7:0]addr_out,
	output [7:0]pc,
	output [31:0]data_out,
	output [31:0]data_in,
	output [31:0]ir,
	output signs,
	output we,
	output [2:0]state,
	output [31:0]regout,
	output [31:0]tmpreg,
	output [31:0]tmpir
    );
	 wire [31:0]in_cpu,out_cpu,ir_cpu;
	 wire [7:0]outaddr,pc_cpu;
	 wire wa;
	 assign ir=ir_cpu;
	 assign data_out=out_cpu;
	 assign data_in=in_cpu;
	 assign we=wa;
	 assign addr_out=outaddr;
	 assign pc=pc_cpu;
	 cpu cpu(clk,rst,ir_cpu,in_cpu,pc_cpu,outaddr,out_cpu,wa,state,signs,regc,regout,tmpreg,tmpir);
	 mem memory(clk,we,outaddr,out_cpu,clk,outaddr,in_cpu);
	 ins instruction(clk,1'b0,8'b0,0,clk,pc_cpu,ir_cpu);

endmodule
