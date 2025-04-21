module buffer_filler (
    input logic clk,
    input logic rst_n,
    input logic [7:0] data_in,   // 8-bit data input
    input logic dval,            // Data valid signal (high when data is valid)
    output logic [31:0] data_out,  // 32-bit data output (after filling)
    output logic data_ready      // Signal when the 32-bit data is ready
);

    logic [31:0] shift_reg;
    logic [1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg   <= 32'b0;
            counter     <= 2'd0;
            data_ready  <= 1'b0;
            data_out    <= 32'b0;
        end else begin
            data_ready <= 1'b0;  // Default low unless triggered

            if (dval) begin
                shift_reg <= {data_in, shift_reg[31:8]};  // Shift in new 8 bits

                if (counter == 2'd3) begin
                    data_out <= {data_in, shift_reg[31:8]};  // Form final 32-bit word
                    data_ready <= 1'b1;
                    counter <= 2'd0;
                end else begin
                    counter <= counter + 1;
                end
            end
        end
    end

endmodule
