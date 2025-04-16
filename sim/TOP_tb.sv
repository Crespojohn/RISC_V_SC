`timescale 1ns / 1ps

module top_tb;

    reg clk = 0;
    reg [15:0] sw = 16'b1000_0000_0000_0000; // sw[15] = 1 for rst_n active high
    reg RxD;
    wire [15:0] led;

    // Clock generation
    always #5 clk = ~clk;  // 100 MHz clock

    // Instantiate the DUT
    //top uut (
    //    .clk(clk),
    //    .sw(sw),
    //    .RxD(RxD),
    //    .led(led)
    //);

    // Instruction memory contents to be loaded (replace with actual program)
    reg [7:0] instr_mem_data [0:255]; // each instruction is 4 bytes
    integer i;

    // UART sender task
    task uart_send_byte(input [7:0] data);
        integer j;
        begin
            // Start bit
            RxD = 0;
            #(8680); // Assuming baud rate ~115200bps (1/115200 ~ 8680ns per bit)

            // Data bits (LSB first)
            for (j = 0; j < 8; j = j + 1) begin
                RxD = data[j];
                #(8680);
            end

            // Stop bit
            RxD = 1;
            #(8680);
        end
    endtask

    initial begin
        // Initialize RxD to idle state (high)
        RxD = 1;

        // Load example instructions into memory (as 8-bit chunks)
        // Example: ADD x1, x2, x3 → encoded instruction: 0x003100B3
        // NOTE: This is little-endian byte order: [0] = 0xB3, [1] = 0x00, etc.
        instr_mem_data[0] = 8'hB3;
        instr_mem_data[1] = 8'h00;
        instr_mem_data[2] = 8'h31;
        instr_mem_data[3] = 8'h00;

        instr_mem_data[4] = 8'h93;
        instr_mem_data[5] = 8'h00;
        instr_mem_data[6] = 8'h20;
        instr_mem_data[7] = 8'h00;

        // Fill rest with NOPs (addi x0, x0, 0 → 0x00000013)
        for (i = 8; i < 256; i = i + 4) begin
            instr_mem_data[i+0] = 8'h13;
            instr_mem_data[i+1] = 8'h00;
            instr_mem_data[i+2] = 8'h00;
            instr_mem_data[i+3] = 8'h00;
        end

        // Wait some time for reset and clock lock
        #(100_000); // 100 us for system to stabilize

        // Send all instruction bytes through UART
        for (i = 0; i < 256; i = i + 1) begin
            uart_send_byte(instr_mem_data[i]);
        end

        // Wait some time after transmission
        #(1_000_000); // 1 ms

        $display("Finished loading instruction memory via UART.");
        $stop;
    end

endmodule
