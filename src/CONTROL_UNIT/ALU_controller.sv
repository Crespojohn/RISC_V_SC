module ALUControl (
    input  [6:0] op,
    input  [2:0] funct3,
    input        funct7,
    input        zero,
    output       PCSrc,
    output       jump,
    output       ALUSrc,
    output       RegWrite,
    output       MemWrite,
    output       branch,
    output [1:0] ImmSrc,
    output [2:0] ALUControl,
    output [1:0] ResultSrc
);

    // Default values
    reg [2:0] alu_ctrl;
    reg       reg_write;
    reg       mem_write;
    reg       alu_src;
    reg       do_branch;
    reg       do_jump;
    reg [1:0] imm_src;
    reg [1:0] result_src;

    always_comb begin
        // Default control values
        alu_ctrl    = 3'b000;
        reg_write   = 0;
        mem_write   = 0;
        alu_src     = 0;
        do_branch   = 0;
        do_jump     = 0;
        imm_src     = 2'b00;
        result_src  = 2'b00;

        case (op)
            7'b0110011: begin // R-type
                reg_write   = 1;
                alu_src     = 0;
                case ({funct7, funct3})
                    4'b0000: alu_ctrl = 3'b000; // ADD
                    4'b1000: alu_ctrl = 3'b001; // SUB
                    4'b0111: alu_ctrl = 3'b010; // AND
                    4'b0110: alu_ctrl = 3'b011; // OR
                    default: alu_ctrl = 3'b000;
                endcase
                result_src = 2'b00; // ALU result
            end

            7'b0010011: begin // I-type (e.g., ADDI)
                reg_write   = 1;
                alu_src     = 1;
                alu_ctrl    = 3'b000; // ADD
                imm_src     = 2'b00;
                result_src  = 2'b00;
            end

            7'b0000011: begin // Load (e.g., LW)
                reg_write   = 1;
                alu_src     = 1;
                alu_ctrl    = 3'b000; // ADD for address
                imm_src     = 2'b00;
                result_src  = 2'b01; // from memory
            end

            7'b0100011: begin // Store (e.g., SW)
                mem_write   = 1;
                alu_src     = 1;
                alu_ctrl    = 3'b000; // ADD for address
                imm_src     = 2'b01;
            end

            7'b1100011: begin // Branch (e.g., BEQ)
                alu_src     = 0;
                alu_ctrl    = 3'b001; // SUB for compare
                imm_src     = 2'b10;
                do_branch   = 1;
            end

            7'b1101111: begin // JAL
                reg_write   = 1;
                alu_ctrl    = 3'b000;
                imm_src     = 2'b11;
                result_src  = 2'b10; // PC + 4
                do_jump     = 1;
            end

            default: begin
                alu_ctrl    = 3'b000;
                result_src  = 2'b00;
            end
        endcase
    end

    // Assign control signals
    assign ALUControl = alu_ctrl;
    assign RegWrite   = reg_write;
    assign MemWrite   = mem_write;
    assign ALUSrc     = alu_src;
    assign branch     = do_branch;
    assign jump       = do_jump;
    assign ImmSrc     = imm_src;
    assign ResultSrc  = result_src;
    assign PCSrc      = branch & zero;

endmodule
