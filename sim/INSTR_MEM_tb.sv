`timescale 1ns / 1ps

module tb_instr_mem;

    // Inputs
    reg clk;
    reg rst_n;
    reg [7:0] address;
    reg load_en;
    reg [31:0] load_inst;

    // Outputs
    wire [31:0] instruction;
    wire load_done;

    // Instantiate the instr_mem module
    instr_mem uut (
        .clk(clk),
        .rst_n(rst_n),
        .address(address),
        .load_en(load_en),
        .load_inst(load_inst),
        .instruction(instruction),
        .load_done(load_done)
    );

    // Clock generation (100 MHz clock)
    always #5 clk = ~clk; // Toggle every 5ns, clock period = 10ns

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        address = 8'b0;
        load_en = 0;
        load_inst = 32'b0;

        // Apply reset
        $display("Applying reset...");
        #10;
        rst_n = 1;  // Deassert reset after 10ns
        #10;

        // Test case 1: Load 256 instructions into memory
        $display("Loading 256 instructions into memory...");

        // Load 256 instructions
        load_en = 1; // Enable loading
        for (address = 0; address < 256; address = address + 1) begin
            load_inst = {24'hDEADBEEF, address};  // Load example instructions (DEADBEEF + address)
            #10;  // Wait for 10ns before the next load
        end

        // After all loads, check if load_done is high
        if (load_done) begin
            $display("All 256 instructions loaded.");
        end else begin
            $display("Load operation not complete.");
        end

        // Test case 2: Read some instructions from memory
        $display("Reading instructions from memory...");

        // Read instruction from address 0x00
        address = 8'h00;
        #10;
        $display("Read instruction at address 0x00: %h", instruction);

        // Read instruction from address 0x10
        address = 8'h10;
        #10;
        $display("Read instruction at address 0x10: %h", instruction);

        // Read instruction from address 0xFF (last address)
        address = 8'hFF;
        #10;
        $display("Read instruction at address 0xFF: %h", instruction);

        // Read instruction from address 0x80 (mid address)
        address = 8'h80;
        #10;
        $display("Read instruction at address 0x80: %h", instruction);

        // Test case 3: Reset and verify memory is cleared
        $display("Applying reset...");
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        // After reset, read from address 0x00 to verify memory is cleared
        address = 8'h00;
        #10;
        $display("After reset, read instruction at address 0x00: %h (expected 00000000)", instruction);

        // End simulation
        $finish;
    end

endmodule
