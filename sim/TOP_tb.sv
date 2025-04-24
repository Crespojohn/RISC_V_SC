`timescale 1ns / 1ps

module uart_loader_tb;

    reg clk;
    initial clk = 1'b0;
    reg [15:0] sw = 16'b1000_0000_0000_0000; // sw[15] = 1 for rst_n active high
    reg RxD;
    wire [15:0] led;

    // Clock generation
    always #5 clk = ~clk;  // 100 MHz clock

    // Instantiate the DUT
    top uut (
        .clk(clk),
        .sw(sw),
        .RxD(RxD),
        .led(led)
    );

    // Instruction memory contents to be loaded (replace with actual program)
    reg [7:0] instr_mem_data [0:255]; // each instruction is 4 bytes
    integer i;

    // UART sender task
    task uart_send_byte(input [7:0] data);
        integer j;
        begin
            // Start bit
            RxD = 0;
            #(104166); // Assuming baud rate ~9600bps (1/9600 ~ 104166ns per bit)
    
            // Data bits (LSB first)
            for (j = 0; j < 8; j = j + 1) begin
                RxD = data[j];
                #(104166);
            end
    
            // Stop bit
            RxD = 1;
            #(104166);
        end
    endtask

    initial begin
        // Initialize RxD to idle state (high)
        RxD = 1;
    
        // Instruction memory initialization for register file read/write only operations

        // 1. ADDI x5, x0, 10  → x5 = 10
        //    Encoding: 0x00A00293
        //0x00A00293
        instr_mem_data[0] = 8'h93;
        instr_mem_data[1] = 8'h72;
        instr_mem_data[2] = 8'hA0;
        instr_mem_data[3] = 8'h00;
        
        // 2. ADD x6, x6, x5   → x6 = x6 + x5
        //    Encoding: 0x00528333
        //0x00528333
        instr_mem_data[4] = 8'hB3;
        instr_mem_data[5] = 8'h80;
        instr_mem_data[6] = 8'h50;
        instr_mem_data[7] = 8'h00;
        
        // 3. SD x5 x0 5 -> Store register x5 into base 0 address 5
        //    Encoding: 0x005303B3
        instr_mem_data[8]  = 8'hB3;
        instr_mem_data[9]  = 8'h80;
        instr_mem_data[10] = 8'h00;
        instr_mem_data[11] = 8'h00;
        
        // 4. LD x5 x0 5 -> Load register x5 into base 0 address 5
        //    Encoding: 0x005303B3
        instr_mem_data[12] = 8'h83;
        instr_mem_data[13] = 8'h32;
        instr_mem_data[14] = 8'h20;
        instr_mem_data[15] = 8'h00;
        
        // 5. BEQ x0, x0, 0  return to start of program
        //    Encoding: 0x405244B3 (SUB is ADD with funct7 = 0x20)FE000EE3

        instr_mem_data[16] = 8'hE3;
        instr_mem_data[17] = 8'h0E;
        instr_mem_data[18] = 8'h00;
        instr_mem_data[19] = 8'hFE;

    
        // Fill rest with NOPs (addi x0, x0, 0 → 0x00000013)
        for (i = 20; i < 256; i = i + 4) begin
            instr_mem_data[i]   = 8'h13;
            instr_mem_data[i+1] = 8'h00;
            instr_mem_data[i+2] = 8'h00;
            instr_mem_data[i+3] = 8'h00;
        end
        uut.load_done = 1'b1;
    
        // Wait some time for reset and clock lock
        #(100_000); // 100 us for system to stabilize
    
        // Send all instruction bytes through UART
        for (i = 0; i < 256; i = i + 1) begin
            uart_send_byte(instr_mem_data[i]);
        end
        //
        //// Wait some time after transmission

        //#(1_000_000); // 1 ms
    
        $display("Finished loading instruction memory via UART.");
        $stop;
    end

endmodule
