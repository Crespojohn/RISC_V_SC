module instr_mem (
    input logic clk,
    input logic rst_n,

    input logic [7:0] address,
    input logic load_en,
    input logic [31:0] load_inst,

    output logic [31:0] instruction,
    output logic [31:0] instruction_1,
    output logic load_done
);

reg [31:0] registers [0:255];
reg [7:0] counter;
int i;

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        counter <= 8'd0;
        load_done <= 1'b0;
        for (i = 0; i < 256 ; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end else begin
        if(load_en) begin
            registers[counter] <= load_inst;
            if(counter >= 255) load_done <= 1'b1;
            if(!load_done) counter <= counter + 1'b1;
        end
    end
end

//Assign instruction from register with address input
assign instruction = registers[address];
assign instruction_1 = registers[1];

endmodule