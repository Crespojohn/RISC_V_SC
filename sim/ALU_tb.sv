`timescale 1ns / 1ps

module tb_ALU;

    // Inputs
    reg [31:0] data_1_i;
    reg [31:0] data_2_i;
    reg [03:0] alu_op_i;

    // Outputs
    wire zero_o;
    wire [31:0] alu_result_o;

    // Instantiate the ALU module
    ALU uut (
        .data_1_i(data_1_i),
        .data_2_i(data_2_i),
        .alu_op_i(alu_op_i),
        .zero_o(zero_o),
        .alu_result_o(alu_result_o)
    );

    // Test cases
    initial begin
        // Display header
        $display("Test starting...");

        // Test case 1: ALU_ADD
        data_1_i = 32'h00000005;  // 5
        data_2_i = 32'h00000003;  // 3
        alu_op_i = ALU_ADD;  // ALU operation: ADD
        #10;  // Wait for the result to propagate
        $display("ALU ADD: %d + %d = %d (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 2: ALU_SUB
        data_1_i = 32'h00000005;  // 5
        data_2_i = 32'h00000003;  // 3
        alu_op_i = ALU_SUB;  // ALU operation: SUB
        #10;
        $display("ALU SUB: %d - %d = %d (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 3: ALU_AND
        data_1_i = 32'h0000000F;  // 0000 0000 0000 1111
        data_2_i = 32'h000000F0;  // 0000 0000 1111 0000
        alu_op_i = ALU_AND;  // ALU operation: AND
        #10;
        $display("ALU AND: %h & %h = %h (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 4: ALU_OR
        data_1_i = 32'h0000000F;  // 0000 0000 0000 1111
        data_2_i = 32'h000000F0;  // 0000 0000 1111 0000
        alu_op_i = ALU_OR;  // ALU operation: OR
        #10;
        $display("ALU OR: %h | %h = %h (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 5: ALU_XOR (Not implemented, will return data_1_i)
        data_1_i = 32'h0000000F;  // 0000 0000 0000 1111
        data_2_i = 32'h000000F0;  // 0000 0000 1111 0000
        alu_op_i = ALU_XOR;  // ALU operation: XOR
        #10;
        $display("ALU XOR: %h ^ %h = %h (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 6: ALU_SLT (Not implemented, will return data_1_i)
        data_1_i = 32'h00000005;  // 5
        data_2_i = 32'h00000003;  // 3
        alu_op_i = ALU_SLT;  // ALU operation: SLT
        #10;
        $display("ALU SLT: %d < %d = %d (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 7: ALU_SRL (Not implemented, will return data_1_i)
        data_1_i = 32'h0000000F;  // 0000 0000 0000 1111
        data_2_i = 32'h00000003;  // 0000 0000 0000 0011
        alu_op_i = ALU_SRL;  // ALU operation: SRL
        #10;
        $display("ALU SRL: %h >> %h = %h (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 8: ALU_SLL (Not implemented, will return data_1_i)
        data_1_i = 32'h0000000F;  // 0000 0000 0000 1111
        data_2_i = 32'h00000003;  // 0000 0000 0000 0011
        alu_op_i = ALU_SLL;  // ALU operation: SLL
        #10;
        $display("ALU SLL: %h << %h = %h (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 9: ALU_SRA (Not implemented, will return data_1_i)
        data_1_i = 32'h0000000F;  // 0000 0000 0000 1111
        data_2_i = 32'h00000003;  // 0000 0000 0000 0011
        alu_op_i = ALU_SRA;  // ALU operation: SRA
        #10;
        $display("ALU SRA: %h >>> %h = %h (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 10: ALU_SLTU (Not implemented, will return data_1_i)
        data_1_i = 32'h00000005;  // 5
        data_2_i = 32'h00000003;  // 3
        alu_op_i = ALU_SLTU;  // ALU operation: SLTU
        #10;
        $display("ALU SLTU: %d <u %d = %d (zero_o = %b)", data_1_i, data_2_i, alu_result_o, zero_o);

        // Test case 11: Default case (ALU operation not recognized)
        data_1_i = 32'h00000005;  // 5
        data_2_i = 32'h00000003;  // 3
        alu_op_i = 4'b1111;  // Invalid ALU operation
        #10;
        $display("ALU Default: %d (zero_o = %b)", alu_result_o, zero_o);

        // Finish the simulation
        $finish;
    end

endmodule
