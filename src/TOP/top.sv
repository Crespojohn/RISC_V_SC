`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2015 12:39:26 AM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top-level module integrating instruction memory,
//              register file, ALU, UART receiver, buffer, memory, and controller
// 
// Dependencies: clk_wiz_0, receiver, buffer_filler, instr_mem,
//               blk_mem_gen_0, regfile, ALUControl, ALU, Extend
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

(* dont_touch = "yes" *) 
module top (
    input  clk,             // Main clock
    input  [15:0] sw,       // Switch inputs
    input  RxD,             // UART receive input
    output reg [15:0] led   // LED output
); 

//----------------------------------------
// Clock & Reset
//----------------------------------------
wire clk_10MHz;
wire rst_n;
wire locked;

assign rst_n = sw[15];  // Active high reset

clk_wiz_0 clk_wiz (
    .clk_out1 (clk_10MHz),
    .reset    (!sw[15]),
    .locked   (locked),
    .clk_in1  (clk)
);

//----------------------------------------
// UART Receiver
//----------------------------------------
wire valid_RX;
wire [7:0] RX_data;

(* dont_touch = "yes" *) receiver RX (
    .clk   (clk_10MHz),
    .RxD   (RxD),
    .valid (valid_RX),
    .data  (RX_data)
);

//----------------------------------------
// Buffer Filler
//----------------------------------------
wire buffer_ready;
wire [31:0] buffer_data;

(* dont_touch = "yes" *) buffer_filler buffer_filler (
    .clk        (clk_10MHz),
    .rst_n      (rst_n && locked),
    .data_in    (RX_data),
    .dval       (valid_RX),
    .data_out   (buffer_data),
    .data_ready (buffer_ready)
);

//----------------------------------------
// Instruction Memory
//----------------------------------------
wire [31:0] instr_out;
reg load_done;
wire [7:0] pc;

(* dont_touch = "yes" *) instr_mem instr_mem (
    .clk         (clk_10MHz),
    .rst_n       (rst_n && locked),
    .address     (pc),
    .load_en     (buffer_ready),
    .load_inst   (buffer_data),
    .instruction (instr_out),
    .load_done   (load_done)
);

//----------------------------------------
// Register File
//----------------------------------------
wire [4:0]  address1, address2, address3;
wire [31:0] read_data1, read_data2;
wire        write_enable;
wire [31:0] write_data;

wire [6:0] op        = instr_out[6:0];
wire [2:0] funct3    = instr_out[14:12];
wire       funct7    = instr_out[30];
wire       zero;
wire       PCSrc, jump, ALUSrc, RegWrite, MemWrite, branch;
wire [1:0] ImmSrc;
wire [2:0] ALUControl;
wire [1:0] ResultSrc;

assign address1 = instr_out[19:15];
assign address2 = instr_out[24:20];
assign address3 = instr_out[11:7];

wire [31:0] register1;
(* dont_touch = "yes" *) regfile u_regfile (
    .clk           (clk_10MHz),
    .rst_n         (rst_n && locked),
    .address1      (address1),
    .address2      (address2),
    .read_data1    (read_data1),
    .read_data2    (read_data2),
    .write_enable  (RegWrite),
    .write_data    (write_data),
    .address3      (address3),
    .register1     (register1)
);

//----------------------------------------
// ALU Control
//----------------------------------------

(* dont_touch = "yes" *) ALUControl u_ALUControl (
    .op         (op),
    .funct3     (funct3),
    .funct7     (funct7),
    .zero       (zero),
    .PCSrc      (PCSrc),
    .jump       (jump),
    .ALUSrc     (ALUSrc),
    .RegWrite   (RegWrite),
    .MemWrite   (MemWrite),
    .branch     (branch),
    .ImmSrc     (ImmSrc),
    .ALUControl (ALUControl),
    .ResultSrc  (ResultSrc)
);

//----------------------------------------
// Immediate Generator
//----------------------------------------
wire [31:0] ImmExt;

(* dont_touch = "yes" *) Extend u_Extend (
    .instruction (instr_out[31:7]),
    .ImmSrc      (ImmSrc),
    .ImmExt      (ImmExt)
);

//----------------------------------------
// ALU
//----------------------------------------
wire [31:0] ALU_read_data2;
wire [31:0] alu_result_o;
wire [3:0]  alu_op_i = ALUControl;  // Cast to 4 bits

assign ALU_read_data2 = ALUSrc ? ImmExt : read_data2;

(* dont_touch = "yes" *) ALU u_ALU (
    .data_1_i     (read_data1),
    .data_2_i     (ALU_read_data2),
    .alu_op_i     (alu_op_i),
    .zero_o       (zero),
    .alu_result_o (alu_result_o)
);

//----------------------------------------
// Data Memory (Block RAM)
//----------------------------------------
wire [31:0] mem_data_out;
assign write_data = (ResultSrc == 2'b00) ? alu_result_o :
                    (ResultSrc == 2'b01) ? mem_data_out  :
                    pc_plus_4;
(* dont_touch = "yes" *) blk_mem_gen_0 MEMORY (
    .clka       (clk_10MHz),
    .rsta       (!rst_n && locked),
    .ena        (1'b1),
    .wea        (MemWrite),
    .addra      (alu_result_o),
    .dina       (read_data2),
    .douta      (mem_data_out),
    .rsta_busy  ()
);

// Declare signals for PC
wire [31:0] next_pc;
wire [31:0] branch_address;
wire [31:0] jump_address;
wire [31:0] pc_plus_4;

// Assign the next PC value
assign pc_plus_4 = pc + 1; // Next instruction address

// PC module instantiation
(* dont_touch = "yes" *) PC u_PC (
    .clk            (clk_10MHz),
    .rst_n          (rst_n && locked && load_done),
    .branch         (branch),
    .zero           (zero),
    .jump           (jump),
    .branch_address (branch_address),
    .jump_address   (jump_address),
    .pc_plus_4      (pc_plus_4),
    .pc             (pc) // Output current PC
);

// Branch or jump logic: Calculate the target addresses
assign branch_address = pc + {{20{instr_out[31]}}, instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
wire is_jalr = (op == 7'b1100111);
assign jump_address = is_jalr ? (read_data1 + ImmExt) :
                                   (pc + ImmExt); // for JAL

//----------------------------------------
// LED Output Logic
//----------------------------------------
always @(posedge clk_10MHz or negedge rst_n) begin
    if (!rst_n)
        led <= 16'd0;
    else begin
        if (!sw[14])
            led <= register1[15:0];
        else
            led <= register1[31:16];
    end
end

endmodule
