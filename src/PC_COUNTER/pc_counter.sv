module PC (
    input         clk,            // Clock input
    input         rst_n,          // Active-low reset
    input         branch,         // Branch condition signal (1 if branch)
    input         zero,           // Zero signal for branch condition (if true, branch)
    input         jump,           // Jump signal (1 if jump)
    input  [31:0] branch_address, // Branch target address (calculated during branch)
    input  [31:0] jump_address,   // Jump target address (calculated during jump)
    input  [31:0] pc_plus_4,      // The current PC + 4 (to increment normally)
    output reg [31:0] pc          // The current PC value
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset the PC to zero (or a starting address if desired)
            pc <= 32'b0;
        end else begin
            // Decide on the next PC value
            if (jump) begin
                // For JUMP instructions (e.g., `jal` or `jalr`)
                pc <= jump_address;
            end else if (branch && zero) begin
                // For BRANCH instructions (e.g., `beq`), update PC if condition is met
                pc <= branch_address;
            end else begin
                // Default: increment PC by 4 for normal instruction fetch
                pc <= pc_plus_4;
            end
        end
    end

endmodule
