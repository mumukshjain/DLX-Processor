`timescale 1ns / 1ps
`include "definitions.sv"

module stage2(
BUS if_2,
output logic [31:0]aluout,
output logic carry
);

logic [15:0] h_add;
logic h_carry;

always_ff@(posedge if_2.clk) begin
    if(if_2.rst) begin
        aluout <= 32'b0;
        carry <= 1'b0;
    end
    else if(if_2.enable_shift) begin
        case(if_2.operation)
            `SHLEFTLOG: aluout <= if_2.aluin1 << if_2.shift_number;
            `SHLEFTART: aluout <= if_2.aluin1 << if_2.shift_number; 
            `SHRGHTLOG: aluout <= if_2.aluin1 >> if_2.shift_number;
            `SHRGHTART: aluout <= $signed(if_2.aluin1) >>> if_2.shift_number;
            default: aluout <= aluout;
        endcase
    end
    else if(if_2.enable_arith)begin
        case({if_2.opselect, if_2.operation})
            {`ARITH_LOGIC, `ADD}:
                {carry, aluout} <= $signed(if_2.aluin1) + $signed(if_2.aluin2);
            {`ARITH_LOGIC, `HADD}: begin
                {h_carry, h_add} = if_2.aluin1[15:0] + if_2.aluin2[15:0];
                carry <= h_carry;
                aluout <= $signed(h_add);
                end
            {`ARITH_LOGIC, `SUB}:
                {carry, aluout} <= $signed(if_2.aluin2) - $signed(if_2.aluin1);
            {`ARITH_LOGIC, `NOT}: begin
                carry <= 1'b0;
                aluout <= ~if_2.aluin2;
            end
            {`ARITH_LOGIC, `AND}:
                aluout <= if_2.aluin1 & if_2.aluin2;
            {`ARITH_LOGIC, `OR}:
                aluout <= if_2.aluin1 | if_2.aluin2;
            {`ARITH_LOGIC, `XOR}:
                aluout <= if_2.aluin1 ^ if_2.aluin2;
            {`ARITH_LOGIC, `LHG}: begin
                aluout <= {if_2.aluin2[15:0], 16'b0};
                carry <= 0;
            end
            {`MEM_READ, `LOADBYTE}: begin
                aluout <= $signed(if_2.aluin2[7:0]);
                carry <= 1'b0;
            end 
            {`MEM_READ, `LOADBYTEU}: begin
                aluout <= {24'b0, if_2.aluin2[7:0]};
                carry <= 1'b0;
            end 
            {`MEM_READ, `LOADHALF}: begin
                aluout <= $signed(if_2.aluin2[15:0]);
                carry <= 1'b0;
            end 
            {`MEM_READ, `LOADHALFU}: begin
                aluout <= {16'b0, if_2.aluin2[15 :0]};
                carry <= 1'b0;
            end    
            {`MEM_READ, 3'b010}: begin
                aluout <= if_2.aluin2;
                carry <= 1'b0;
            end 
            {`MEM_READ, 3'b110}: begin
                aluout <= if_2.aluin2;
                carry <= 1'b0;
            end   
            {`MEM_READ, 3'b111}: begin
                aluout <= if_2.aluin2;
                carry <= 1'b0;
            end  
            default: begin
                aluout <= aluout;
                carry <= carry;
            end 
        endcase         
    end
    else begin
        aluout <= aluout;
        carry <= carry;
    end
end
endmodule
