`timescale 1ns / 1ps

module tb_regfile;

    // Inputs
    reg clk;
    reg rst_n;
    reg [4:0] address1;
    reg [4:0] address2;
    reg write_enable;
    reg [31:0] write_data;
    reg [4:0] address3;

    // Outputs
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    // Instantiate the regfile module
    regfile uut (
        .clk(clk),
        .rst_n(rst_n),
        .address1(address1),
        .address2(address2),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .write_enable(write_enable),
        .write_data(write_data),
        .address3(address3)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Initial block to drive the test cases
    initial begin
        // Initialize inputs
        clk = 0;
        rst_n = 1;
        address1 = 5'b00000;
        address2 = 5'b00000;
        write_enable = 0;
        write_data = 32'b0;
        address3 = 5'b00000;

        // Apply reset
        $display("Applying reset...");
        #10;
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        // Test case 1: Write to register 1
        $display("Writing 32'h12345678 to register 1...");
        address3 = 5'b00001;
        write_data = 32'h12345678;
        write_enable = 1;
        #10;
        
        // Test case 2: Read from register 1 (should return 32'h12345678)
        address1 = 5'b00001;  // Read from register 1
        #10;
        $display("Read data from register 1: %h (expected 12345678)", read_data1);

        // Test case 3: Write to register 2
        $display("Writing 32'hDEADBEEF to register 2...");
        address3 = 5'b00010;
        write_data = 32'hDEADBEEF;
        write_enable = 1;
        #10;

        // Test case 4: Read from register 2 (should return 32'hDEADBEEF)
        address2 = 5'b00010;  // Read from register 2
        #10;
        $display("Read data from register 2: %h (expected DEADBEEF)", read_data2);

        // Test case 5: Test write disable (should not modify the register)
        $display("Testing write disable...");
        write_enable = 0;
        address3 = 5'b00001;  // Write to register 1 (but write is disabled)
        write_data = 32'h87654321;
        #10;

        // Check that the value of register 1 did not change
        address1 = 5'b00001;  // Read from register 1
        #10;
        $display("After write disable, read data from register 1: %h (expected 12345678)", read_data1);

        // Test case 6: Reset the registers
        $display("Applying reset...");
        rst_n = 1;
        #10;
        rst_n = 0;
        #10;

        // Check that register 1 and 2 are both 0 after reset
        address1 = 5'b00001;  // Read from register 1
        address2 = 5'b00010;  // Read from register 2
        #10;
        $display("After reset, read data from register 1: %h (expected 00000000)", read_data1);
        $display("After reset, read data from register 2: %h (expected 00000000)", read_data2);

        // Test case 7: Write to a different register after reset
        $display("Writing 32'hAABBCCDD to register 31...");
        address3 = 5'b11111;  // Write to register 31
        write_data = 32'hAABBCCDD;
        write_enable = 1;
        #10;

        // Check the value of register 31
        address1 = 5'b11111;  // Read from register 31
        #10;
        $display("Read data from register 31: %h (expected AABBCCDD)", read_data1);

        // Finish the simulation
        $finish;
    end
endmodule