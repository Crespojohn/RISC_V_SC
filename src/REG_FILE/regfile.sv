module regfile (
    // basic signals
    input logic clk,
    input logic rst_n,

    // Reads
    input logic [4:0] address1,
    input logic [4:0] address2,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,

    // Writes
    input logic write_enable,
    input logic [31:0] write_data,
    input logic [4:0] address3
);

reg [31:0] registers [0:31];
int i;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        for (i = 0; i < 32 ; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end else begin
        if(write_enable && address3) registers[address3] <= write_data;
    end
end

assign read_data1 = registers[address1];
assign read_data2 = registers[address2];

endmodule