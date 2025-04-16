`include "ALU.svh"

module ALU (
    input   wire [31:0] data_1_i,
    input   wire [31:0] data_2_i,
    input   wire [3:0]  alu_op_i,
    output  wire        zero_o,
    output  reg  [31:0] alu_result_o
);
    always @* begin
        alu_result_o = 32'd0;
        case (alu_op_i)
            ALU_ADD  : alu_result_o = data_1_i + data_2_i;
            ALU_SUB  : alu_result_o = data_1_i - data_2_i;
            ALU_AND  : alu_result_o = data_1_i & data_2_i;
            ALU_OR   : alu_result_o = data_1_i | data_2_i;
            ALU_XOR  : alu_result_o = data_1_i ^ data_2_i;
            ALU_SLL  : alu_result_o = data_1_i << data_2_i[4:0];
            ALU_SRL  : alu_result_o = data_1_i >> data_2_i[4:0];
            ALU_SRA  : alu_result_o = $signed(data_1_i) >>> data_2_i[4:0];
            ALU_SLT  : alu_result_o = {31'b0, $signed(data_1_i) < $signed(data_2_i)};
            ALU_SLTU : alu_result_o = {31'b0, data_1_i < data_2_i};
            default  : alu_result_o = 32'd0;
        endcase
    end

    assign zero_o = (alu_result_o == 32'd0);

endmodule
