`timescale 1ns / 1ps

interface BUS(
input logic clk, rst
);

logic [31:0] aluin1, aluin2;
logic [2:0] operation, opselect;
logic [4:0] shift_number;
logic enable_arith, enable_shift;

modport stage1(input clk, rst, output aluin1, aluin2, operation, opselect,
                shift_number, enable_arith, enable_shift);
modport stage2(input clk, rst, aluin1, aluin2, operation, opselect,
                shift_number, enable_arith, enable_shift);   
                       
endinterface
