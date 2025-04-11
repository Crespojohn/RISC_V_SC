`include "ALU.svh"

module ALU (
    input   wire [31:0] data_1_i, // 32-bit data input
    input   wire [31:0] data_2_i, // 32-bit data input
    input   wire [03:0] alu_op_i,
    output  wire zero_o,
    output  reg  [31:0] alu_result_o = 0
);
    always @* begin
        case (alu_op_i)
            ALU_ADD  : alu_result_o = data_1_i + data_2_i;
            ALU_SUB  : alu_result_o = data_1_i - data_2_i;
            ALU_AND  : alu_result_o = data_1_i & data_2_i;
            ALU_OR   : alu_result_o = data_1_i | data_2_i;
            ALU_SLL  : alu_result_o = data_1_i; //Not implemented
            ALU_SLT  : alu_result_o = {31'b0, $signed(data_1_i) < $signed(data_2_i)};
            ALU_SRL  : alu_result_o = data_1_i; //Not implemented
            ALU_SLTU : alu_result_o = {31'b0, (data_1_i) < (data_2_i)};
            ALU_XOR  : alu_result_o = data_1_i ^ data_2_i; //Not implemented
            ALU_SRA  : alu_result_o = data_1_i; //Not implemented
            default: alu_result_o = data_1_i;
        endcase
    end

    // Zero logic
    assign zero_o = !(|alu_result_o);

endmodule
