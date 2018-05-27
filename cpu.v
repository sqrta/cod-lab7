`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:43:01 05/03/2018 
// Design Name: 
// Module Name:    dcpu 
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
module cpu(
	input clk,
	input rst,
	input [31:0]ir,
	input [31:0]in_data,
	output reg [7:0]pc,
	output reg [7:0]out_addr,
	output reg [31:0]out_data,
	output reg we,
	output [2:0]states,
	output signs,
	output [31:0]regc,
	output [31:0]regout,
	output [31:0]tmpreg1,
	output [31:0]tmpreg2,
	output [31:0]tmpir
    );
	/******定义指令部分********/

	 parameter cal = 6'b000000;
	 /*计算指令*/
	 parameter nop = 6'b000000;
	 parameter add = 6'b100000;
	 parameter addu = 6'b100001;
	 parameter sub = 6'b100010;
	 parameter subu = 6'b100011;	 
	 parameter m_and = 6'b100100;
	 parameter m_or = 6'b100101;
	 parameter m_xor = 6'b100110;
	 parameter m_nor = 6'b100111;
	 parameter jr = 6'b001000;
	 /*********************/
	 parameter addi = 6'b001000;
	 parameter andi = 6'b001100;
	 parameter lw = 6'b100011;
	 parameter sw = 6'b101011;

	 parameter bgtz = 6'b000111;
	 parameter bne = 6'b000101;
	 parameter j = 6'b000010;

	 parameter beq = 6'b000100;
	 parameter blez = 6'b000110;
	 parameter ori = 6'b001101;
	 parameter xori = 6'b001110;
	 parameter slti = 6'b001010;	 	
	 parameter jal = 6'b000011;
	 parameter bnez = 6'b001110;
	 parameter bgez = 6'b001111;
	 parameter bltz = 6'b010000;
	 parameter beqz = 6'b010001;
	 parameter neg = 6'b100111;
	 
	 parameter com = 6'b001110;
	 parameter seq = 6'h18;
	 parameter sne = 6'h19;
	 parameter sge = 6'h20;
	 parameter sgt = 6'h21;
	 parameter sle = 6'h22;
	 parameter slt = 6'h23;
	 /**********************/
	 //计算操作码
	 parameter op_nop=3'b000;
	 parameter op_add=3'b001;
	 parameter op_sub=3'b010;
	 parameter op_and=3'b011;
	 parameter op_or=3'b100;
	 parameter op_xor=3'b101;
	 parameter op_nor=3'b110; 
	 parameter op_neg=3'b111;
/***************定义变量，连接模块********************/
	 
	 integer i;
	 wire [31:0]extend,alu_out;
	 reg [31:0]regs[0:31];
	 reg [2:0]state;
	 reg [31:0]rs,rt,rd;
	 reg [31:0]id_ir;
	 reg [2:0]op;
	 ALU ALU(rs,rt,op,alu_out);
	 sign ex(id_ir,extend);	
/***************************************/

/*****状态机部分*****///仅仅用来方便debug，无实际作用
	always@(posedge clk or negedge rst) begin
		if(!rst) begin
			state<=3'b0;
			end
		else begin
			if (state==3'b101) state<=3'b1;
			else state<=state+1;
			end
		end
/**********************/

/*******多周期流水线控制部分*******/
/*******IF******/
	
	reg [7:0]branch_addr;
	reg branch;
	always@(posedge clk or negedge rst)begin
		if (!rst) begin
			id_ir<=32'b0;
			pc<=8'b0;
			
			end
		else begin
			id_ir<=ir;
			if (branch) begin
				pc<=branch_addr;
				end
			else begin
				pc<=pc+1;
				end
			end
		end
/*************************/		
	
/*******ID******/
	reg [31:0]ex_ir;
	
	reg [4:0]dest;//目标寄存器
	reg write,alu,read;
	
	always@(posedge clk or negedge rst)begin
		if (!rst) begin
			ex_ir<=32'b0;
			alu<=0;
			read<=0;
			write<=0;
			branch<=0;
			branch_addr<=8'b0;
			rs<=32'b0;
			rt<=32'b0;
			rd<=32'b0;	
			dest<=5'b0;	
			op<=3'b0;		
			end
		
		else if (id_ir[31:26]==nop && id_ir[5:0]==nop) begin
			dest<=5'b0;
			alu<=0;
			read<=0;
			write<=0;
			branch<=0;
			branch_addr<=8'b0;
			op<=3'b0;	
			rt<=0;
			end
		else begin
			ex_ir<=id_ir;
			if ((alu || read) && id_ir[25:21]==dest) rs<=alu_out;
			else if ((mem_alu || mem_read) && id_ir[25:21]==mem_dest) rs<=cal_out;
			else if (id_ir[25:21]==wb_dest)begin
				if (wb_alu)
					rs<=reg_in;
				else if (wb_read)
					rs<=in_data;
				end
			else rs<=regs[id_ir[25:21]];					
			//计算指令
			//R型指令
			if (id_ir[31:26]==cal && id_ir[5:0]!=nop) begin
				alu<=1;
				if ((alu || read) && id_ir[20:16]==dest) rt<=alu_out;
				
				else if ((mem_alu || mem_read) && id_ir[20:16]==mem_dest) rt<=cal_out;
				
				else if (id_ir[20:16]==wb_dest && (wb_alu || wb_read))begin
					if (wb_alu)
						rt<=reg_in;
					else if (wb_read)
						rt<=in_data;
					end /**/
				else rt<=regs[id_ir[20:16]];
				dest<=id_ir[15:11];			
				if (id_ir[5:0]==add) begin					
					op<=op_add;					
					end
				else if (id_ir[5:0]==addu) begin
					op<=op_add;
					end					
				else if (id_ir[5:0]==sub) begin
					op<=op_sub;
					end
				else if (id_ir[5:0]==subu) begin
					op<=op_sub;
					end
				else if (id_ir[5:0]==m_and) begin
					op<=op_and;
					end
				else if (id_ir[5:0]==m_or) begin
					op<=op_or;
					end
				else if (id_ir[5:0]==m_xor) begin
					op<=op_xor;
					end
				else if (id_ir[5:0]==m_nor) begin
					op<=op_nor;
					end 
				end
			//I型指令
			else if (id_ir[31:26]==com) begin
				alu<=1;
				op<=op_add;
				dest<=id_ir[15:11];
				rs<=0;
				case(id_ir[5:0]) 
					seq:
						if (regs[id_ir[25:21]]==regs[id_ir[20:16]]) rt<=1;
						else rt<=0;
					sne:
						if (regs[id_ir[25:21]]!=regs[id_ir[20:16]]) rt<=1;
						else rt<=0;						
					sge:
						if (regs[id_ir[25:21]]>=regs[id_ir[20:16]]) rt<=1;
						else rt<=0;							
					sgt:
						if (regs[id_ir[25:21]]>regs[id_ir[20:16]]) rt<=1;
						else rt<=0;
					sle:
						if (regs[id_ir[25:21]]<=regs[id_ir[20:16]]) rt<=1;
						else rt<=0;	
					slt:
						if (regs[id_ir[25:21]]<regs[id_ir[20:16]]) rt<=1;
						else rt<=0;
					endcase;
				end				
			else if (id_ir[31:26]==ori) begin
				alu<=1;
				op<=op_or;
				dest<=id_ir[20:16];
				if (id_ir[20:16]==ex_ir[15:11])
					rt<=alu_out;
				else
					rt<=regs[id_ir[20:16]];	
				end
			else if (id_ir[31:26]==xori) begin
				alu<=1;
				op<=op_xor;
				dest<=id_ir[20:16];
				if (id_ir[20:16]==ex_ir[15:11])
					rt<=alu_out;
				else
					rt<=regs[id_ir[20:16]];	
				end			
			else if (id_ir[31:26]==addi)begin
				alu<=1;
				op<=op_add;
				dest<=id_ir[20:16];
				rt<=extend;
				end
			else if (id_ir[31:26]==andi) begin
				alu<=1;
				op<=op_and;
				dest<=id_ir[20:16];
				if (id_ir[20:16]==ex_ir[15:11])
					rt<=alu_out;
				else
					rt<=regs[id_ir[20:16]];	
				end
			else if (id_ir[31:26]==neg) begin
				alu<=1;
				op<=op_neg;
				dest<=id_ir[20:16];	
				end					
			else alu<=0;
			//储存指令
			if (id_ir[31:26]==sw) begin
				write<=1;
				rd<=extend;
				//rt<=regs[id_ir[20:16]];
				/**/
				if ((alu || read) && id_ir[20:16]==dest) rt<=alu_out;
				else if ((mem_alu || mem_read) && id_ir[20:16]==mem_dest) rt<=cal_out;
				else if (id_ir[20:16]==wb_dest)begin
					if (wb_alu)
						rt<=reg_in;
					else if (wb_read)
						rt<=in_data;
					end	
				else rt<=regs[id_ir[20:16]];
				end
			else write<=0;
			//读取指令
			if (id_ir[31:26]==lw) begin
				read<=1;
				rd<=extend; 
				dest<=id_ir[20:16];
				end
			else read<=0;
			//跳转指令 （暂未右移两位）
			if (id_ir[31:26]==j) begin
				branch<=1;
				branch_addr<={6'b00000,id_ir[25:0]};
				end
				/*
			else if (id_ir[31:26]==jal) begin
				branch<=1;
				branch_addr<={6'b00000,id_ir[25:0]};
				regs[31]<=pc;
				end*/
			else if (id_ir[31:26]==bgtz) begin
				if (regs[id_ir[25:21]]>0) begin
					branch<=1;
					branch_addr<={11'b0,id_ir[20:0]};
					end
				else branch<=0;
				end
			else if (id_ir[31:26]==bne) begin
				if (regs[id_ir[25:21]]==regs[id_ir[20:16]]) begin
					branch<=1;
					branch_addr<=pc+(extend);
					end
				else branch<=0;
				end
			else if (id_ir[31:26]==cal && id_ir[5:0]==jr) begin
				branch<=1;
				branch_addr<=regs[id_ir[25:21]];
				end
			else if (id_ir[31:26]==beq) begin
				if (regs[id_ir[25:21]]==regs[id_ir[20:16]]) begin
					branch<=1;
					branch_addr<={11'b0,id_ir[20:0]};
					end
				else branch<=0;
				end
			else if (id_ir[31:26]==blez) begin
				if (regs[id_ir[25:21]]<=0) begin
					branch<=1;
					branch_addr<={11'b0,id_ir[20:0]};
					end
				else branch<=0;
				end
			else if (id_ir[31:26]==bnez) begin
				if (regs[id_ir[25:21]]!=0) begin
					branch<=1;
					branch_addr<={11'b0,id_ir[20:0]};
					end
				else branch<=0;
				end
			else if (id_ir[31:26]==bgez) begin
				if (regs[id_ir[25:21]]>=0) begin
					branch<=1;
					branch_addr<={11'b0,id_ir[20:0]};
					end
				else branch<=0;
				end	
			else if (id_ir[31:26]==bltz) begin
				if (regs[id_ir[25:21]]<0) begin
					branch<=1;
					branch_addr<={11'b0,id_ir[20:0]};
					end
				else branch<=0;
				end	
			else if (id_ir[31:26]==beqz) begin
				if (regs[id_ir[25:21]]==0) begin
					branch<=1;
					branch_addr<={11'b0,id_ir[20:0]};
					end
				else branch<=0;
				end																		
			else
				branch<=0;
			
			end
		end
/*************************/					
	
/********EX********/
	reg [31:0]mem_ir,cal_out;
	reg mem_read,mem_write,mem_alu;
	reg [4:0]mem_dest;
	always@(posedge clk or negedge rst)begin
		if (!rst) begin			
			cal_out<=32'b0;
			mem_ir<=32'b0;
			mem_read<=0;
			mem_write<=0;
			mem_alu<=0;
			mem_dest<=5'b0;
			end
		else begin
			mem_ir<=ex_ir;
			mem_read<=read;
			mem_write<=write;
			mem_alu<=alu;
			mem_dest<=dest;
			if (alu) begin
				cal_out<=alu_out;
				
				end
			if (read) begin
				out_addr<=rs+rd;
				end
			if (write) begin
				out_addr<=rs+rd;
				out_data<=rt;
				we<=1;
				end
			else we<=0;
			end
		end
/*************************/
	
/*******MEM*******/
	reg [31:0]reg_in,wb_ir;
	reg wb_read,wb_alu;
	reg [4:0]wb_dest;
	always@(posedge clk or negedge rst)begin
		if(!rst) begin
			reg_in<=32'b0;
			wb_ir<=32'b0;
			wb_read<=0;
			wb_alu<=0;
			wb_dest<=5'b0;
			end
		else begin
			wb_read<=mem_read;
			wb_alu<=mem_alu;
			wb_dest<=mem_dest;
			if (mem_alu) begin
				reg_in<=cal_out;
				end
			end
		end
/*************************/

/*******WB*******/
	always@(posedge clk or negedge rst)begin
		if (!rst) begin
			for (i=0;i<32;i=i+1)
				regs[i]<=32'b0;		
			end
		else begin	
			if (wb_alu) begin
				regs[wb_dest]<=reg_in;
				
				end
			else if (wb_read) begin
				regs[wb_dest]<=in_data;
				end
			end
		end
/*************************/
	 assign signs=alu;
	 assign states=wb_dest;
	 assign regc=regs[4];
	 assign regout=regs[3];
	 assign tmpreg1=rs;
	 assign tmpreg2=rt;
	 assign tmpir=id_ir;	



endmodule