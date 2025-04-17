module block_mem (
    input logic clk,
    input logic rst_n,

    input logic [13:0] address,
    input logic mem_write,
    input logic mem_read,
    input logic [31:0] write_data,

    output logic [31:0] read_data
);
// 9600 32-bit registers to map the entire display, 640x480 
// 14 bit addressing

reg [31:0] mem [0:9600-1];
int i;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        for (i = 0; i < 9600 ; i = i + 1) begin
            mem[i] <= 32'b0;
        end
    end else begin
        if(mem_write) mem[address] <= write_data;
    end
end

//Assign read_data from register with address input only if read is enabled, else keep data on read line
assign read_data = mem_read ? mem[address] : read_data;

endmodule