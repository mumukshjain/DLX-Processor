`timescale 1ns / 1ps

module tb_dlx_top();

logic clk, rst;
logic enable_ex;
logic [31:0] src1, src2, imm;
logic [6:0] control_in;
logic [31:0] mem_data_read_in;
logic mem_data_wr_en;
logic [31:0] mem_data_write_out;
logic [31:0]aluout;
logic carry;

initial begin
clk = 0;
    forever #(`CLK_PERIOD/2) clk = ~clk;
end

DLX_top uut(clk, rst, enable_ex, src1, src2, imm, control_in, mem_data_read_in, mem_data_wr_en, 
            mem_data_write_out, aluout, carry);

logic check_flag;

task reference_model(
input logic rst,
input logic enable_ex,
input logic [31:0] src1, src2, imm,
input logic [6:0] control_in,
input logic [31:0] mem_data_read_in,
input logic mem_data_wr_en,
input logic [31:0] mem_data_write_out,
input logic [31:0]aluout,
input logic carry,
output logic check_flag
);

logic [4:0]shift_number;
logic [31:0] aluin1, aluin2;
logic [15:0] h_add;
logic h_carry;

    if(rst)
        check_flag = 1;
    else if(!enable_ex)
        check_flag = 1;
    //shifting
    else if(control_in[2:0] == `SHIFT_REG) begin
        shift_number = imm[2]?src2[4:0]:imm[10:6];
        case(control_in[6:4])
            `SHLEFTLOG: check_flag = (aluout == (src1 << shift_number));
            `SHLEFTART: check_flag = (aluout == (src1 << shift_number)); 
            `SHRGHTLOG: check_flag = (aluout == (src1 >> shift_number));
            `SHRGHTART: check_flag = (aluout == ($signed(src1) >>> shift_number));
            default: check_flag = 1;
        endcase
    end
    else if(control_in[2:0] == `ARITH_LOGIC) begin
        aluin2 = control_in[3]?imm:src2;
        aluin1 = src1;
        case(control_in[6:4])
            `ADD:
                check_flag = ($signed({carry, aluout}) == ($signed(aluin1) + $signed(aluin2)));
            `HADD: begin
                {h_carry, h_add} = aluin1[15:0] + aluin2[15:0];
                check_flag = (carry == h_carry && $signed(aluout) == $signed(h_add));
            end
            `SUB:
                check_flag = ($signed({carry, aluout}) == ($signed(aluin2) - $signed(aluin1)));
            `NOT:
                check_flag = (carry == 0 && aluout == ~aluin2);
            `AND:
                check_flag = (aluout == (aluin1 & aluin2));
            `OR:
                check_flag = (aluout == (aluin1 | aluin2));
            `XOR:
                check_flag = (aluout == (aluin1 ^ aluin2));                
            `LHG:
                check_flag = (aluout == {aluin2[15:0], 16'b0} && carry == 0);
            default: check_flag = 1; 
        endcase               
    end
    else if(control_in[2:0] == `MEM_READ) begin
        if(control_in[3] == 1)begin
            aluin2 = mem_data_read_in;
            case(control_in[6:4])
                `LOADBYTE:
                    check_flag = (aluout == $signed(aluin2[7:0]) && carry == 0);
                `LOADBYTEU:
                    check_flag = (aluout == {24'b0, aluin2[7:0]}&& carry == 0);
                `LOADHALF:
                    check_flag = (aluout == $signed(aluin2[15:0]) && carry == 0);
                `LOADHALFU:
                    check_flag = (aluout == {16'b0, aluin2[15 :0]} && carry == 0); 
                default: check_flag = 1;
            endcase
        end
        else
            check_flag = 1; //check for control_in = 0 still pending due to dependence on previous aluin2
    end 
endtask

int total = 0;
int pass = 0;

initial begin
rst = 1;
enable_ex = 1;
#`CLK_PERIOD;
rst = 0;
src1 = 32'h0203_25aa;
src2 = 32'h3425_7adc;
imm = 32'h980d_37fd;
mem_data_read_in = 32'hbaba_7632;
#`CLK_PERIOD;
for(int i=0; i<256; i++) begin
    control_in = i;
    total+=1;
    #`CLK_PERIOD;
    #`CLK_PERIOD;
    reference_model(rst, enable_ex, src1, src2, imm, i, mem_data_read_in, 
    mem_data_wr_en, mem_data_write_out, aluout, carry, check_flag);
    pass = check_flag?pass+1:pass;
end
$display("pass/total = %0d/%0d", pass, total);
$finish();
end


endmodule
