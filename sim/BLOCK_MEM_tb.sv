module tb_block_mem;
    // Testbench signals
    logic clk;
    logic rst_n;
    logic [13:0] address;
    logic mem_write;
    logic mem_read;
    logic [31:0] write_data;
    logic [31:0] read_data;

    // Instantiate the memory block module
    block_mem uut (
        .clk(clk),
        .rst_n(rst_n),
        .address(address),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        address = 14'b0;
        mem_write = 0;
        mem_read = 0;
        write_data = 32'b0;

        // Apply reset
        $display("Applying reset");
        #10 rst_n = 1;

        // Test 1: Write to memory
        $display("Test 1: Write to memory");
        #10 address = 14'h0001; // Memory address 1
        write_data = 32'hA5A5A5A5; // Data to write
        mem_write = 1; // Enable memory write
        #10 mem_write = 0; // Disable memory write

        // Test 2: Read from memory
        $display("Test 2: Read from memory");
        #10 mem_read = 1; // Enable memory read
        #10 mem_read = 0; // Disable memory read

        // Test 3: Write to another address
        $display("Test 3: Write to another address");
        #10 address = 14'h0002; // Memory address 2
        write_data = 32'hDEADDEAD; // Data to write
        mem_write = 1; // Enable memory write
        #10 mem_write = 0; // Disable memory write

        // Test 4: Read from first address
        $display("Test 4: Read from first address");
        #10 address = 14'h0001; // Address 1
        mem_read = 1; // Enable memory read
        #10 mem_read = 0; // Disable memory read

        // Test 5: Read from second address
        $display("Test 5: Read from second address");
        #10 address = 14'h0002; // Address 2
        mem_read = 1; // Enable memory read
        #10 mem_read = 0; // Disable memory read

        // Test 6: Reset functionality
        $display("Test 6: Reset functionality");
        #10 rst_n = 0; // Apply reset
        #10 rst_n = 1; // Release reset

        // Test 7: Read after reset
        $display("Test 7: Read after reset");
        #10 address = 14'h0001; // Address 1 after reset
        mem_read = 1; // Enable memory read
        #10 mem_read = 0; // Disable memory read

        // Test 8: Write to address after reset
        $display("Test 8: Write to address after reset");
        #10 address = 14'h0001; // Memory address 1
        write_data = 32'h12345678; // New data to write
        mem_write = 1; // Enable memory write
        #10 mem_write = 0; // Disable memory write

        // Test 9: Read after write
        $display("Test 9: Read after write");
        #10 mem_read = 1; // Enable memory read
        #10 mem_read = 0; // Disable memory read

        // End of simulation
        $finish;
    end
endmodule
