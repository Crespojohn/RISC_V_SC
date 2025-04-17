`timescale 1ns / 1ps

module tb_buffer_filler;

    // Inputs
    reg clk;
    reg rst_n;
    reg [7:0] data_in;
    reg dval;

    // Outputs
    wire [31:0] data_out;
    wire data_ready;

    // Instantiate the buffer_filler module
    buffer_filler uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .dval(dval),
        .data_out(data_out),
        .data_ready(data_ready)
    );

    // Clock generation
    always #5 clk = ~clk; // 100MHz clock, period = 10ns

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        data_in = 8'b0;
        dval = 0;

        // Apply reset
        $display("Applying reset...");
        #10;
        rst_n = 1;
        #10;

        // Test case 1: Send 4 packets of 8 bits and check the 32-bit output
        $display("Sending 8-bit data...");

        // Sending first 8 bits
        data_in = 8'h12;  // Send 0x12
        dval = 1;  // Data is valid
        #10;
        
        // Sending second 8 bits
        data_in = 8'h34;  // Send 0x34
        #10;
        
        // Sending third 8 bits
        data_in = 8'h56;  // Send 0x56
        #10;
        
        // Sending fourth 8 bits
        data_in = 8'h78;  // Send 0x78
        #10;

        // Now check if data is ready
        dval = 0;  // Disable data valid signal

        // After 4 clock cycles, the buffer should be full and data_ready should be high
        #10;
        if (data_ready) begin
            $display("32-bit data: %h (expected 0x12345678)", data_out);
        end else begin
            $display("Data not ready yet.");
        end

        // Test case 2: Reset and send new data
        $display("Sending new data after reset...");
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        // Send 4 more packets of 8 bits and check the 32-bit output again
        data_in = 8'hAB;  // Send 0xAB
        dval = 1;
        #10;
        
        data_in = 8'hCD;  // Send 0xCD
        #10;
        
        data_in = 8'hEF;  // Send 0xEF
        #10;
        
        data_in = 8'h01;  // Send 0x01
        #10;

        // Check the output again
        dval = 0;  // Disable data valid signal

        // After 4 clock cycles, the buffer should be full and data_ready should be high
        #10;
        if (data_ready) begin
            $display("32-bit data: %h (expected 0xABCDEF01)", data_out);
        end else begin
            $display("Data not ready yet.");
        end

        // End simulation
        $finish;
    end

endmodule
