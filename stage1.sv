`timescale 1ns / 1ps
`include "definitions.sv"

module stage1(
BUS if_1,
input logic enable_ex,
input logic [31:0] src1, src2, imm,
input logic [6:0] control_in,
input logic [31:0] mem_data_read_in,
output logic mem_data_wr_en,
output logic [31:0] mem_data_write_out
    );
    
logic [2:0] operation, opselect;
logic immp_regn;

always_comb begin
    {operation, immp_regn, opselect} = control_in;
    mem_data_write_out = src2;
    if((opselect == `MEM_WRITE) && immp_regn)
        mem_data_wr_en  = 1;
    else
        mem_data_wr_en = 0;  
end    
    
always_ff@(posedge if_1.clk) begin
    if(if_1.rst)begin
        if_1.aluin1 <= 32'b0;
        if_1.aluin2 <= 32'b0;
        if_1.operation <= 3'b0;
        if_1.opselect <= 3'b0;
        if_1.shift_number <= 5'b0;
        if_1.enable_arith <= 1'b0;
        if_1.enable_shift <= 1'b0;
    end
    else if(enable_ex == 0) begin
        if_1.aluin1 <= if_1.aluin1;
        if_1.aluin2 <= if_1.aluin2;
        if_1.operation <= if_1.operation;
        if_1.opselect <= if_1.opselect;
        if_1.shift_number <= 5'b0;
        if_1.enable_arith <= 1'b0;
        if_1.enable_shift <= 1'b0;
    end
    else begin
        // aluin1
        if_1.aluin1 <= src1;
        //aluin2
        case({opselect, immp_regn})
            {`ARITH_LOGIC, 1'b0}: if_1.aluin2 <= src2;
            {`ARITH_LOGIC, 1'b1}: if_1.aluin2 <= imm;
            {`MEM_READ, 1'b0}: if_1.aluin2 <= if_1.aluin2;
            {`MEM_READ, 1'b1}: if_1.aluin2 <= mem_data_read_in;
            default: if_1.aluin2 <= if_1.aluin2;
        endcase
        //operation_out
        if_1.operation <= operation;
        //opselect_out
        if_1.opselect <= opselect;
        //shift_number
        case({opselect, imm[2]})
            {`SHIFT_REG, 1'b0}: if_1.shift_number <= imm[10:6];
            {`SHIFT_REG, 1'b1}: if_1.shift_number <= src2[4:0];  
            default: if_1.shift_number <= 0;
        endcase
        //enable_arith
        case({opselect, immp_regn})
            {`ARITH_LOGIC, 1'b0}: if_1.enable_arith <= 1'b1;
            {`ARITH_LOGIC, 1'b1}: if_1.enable_arith <= 1'b1;
            {`MEM_READ, 1'b0}: if_1.enable_arith <= 1'b0;
            {`MEM_READ, 1'b1}: if_1.enable_arith <= 1'b1;
            default: if_1.enable_arith <= 1'b0;
        endcase
        //enable_shift
        if(opselect == `SHIFT_REG)
            if_1.enable_shift <= 1'b1;
        else
            if_1.enable_shift <= 1'b0;
    end
    
end

endmodule
