`timescale 1ns / 1ps
`include "definitions.sv"
`include "BUS.sv"

module DLX_top(
input logic clk, rst,
input logic enable_ex,
input logic [31:0] src1, src2, imm,
input logic [6:0] control_in,
input logic [31:0] mem_data_read_in,
output logic mem_data_wr_en,
output logic [31:0] mem_data_write_out,
output logic [31:0]aluout,
output logic carry
);

BUS intf(clk, rst);
    
stage1 s1(intf.stage1, enable_ex, src1, src2, imm, control_in, mem_data_read_in, mem_data_wr_en, mem_data_write_out);
stage2 uut(intf.stage2, aluout, carry);

endmodule
