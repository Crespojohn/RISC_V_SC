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
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

(* dont_touch = "yes" *) module top(
    input clk,
    input [15:0]sw,
    input RxD//,
    //output reg [15:0] led
); 

wire valid_RX;
wire [7:0] RX_data;
wire buffer_ready;
wire [31:0] buffer_data;
wire locked;

wire clk_10MHz;

clk_wiz_0 clk_wiz
   (
    // Clock out ports
    .clk_out1(clk_10MHz),     // output clk_out1
    // Status and control signals
    .reset(!sw[15]), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk)      // input clk_in1
);

receiver RX(
    .clk       (clk_10MHz),
    .RxD       (RxD),
    .valid     (valid_RX),
    .data      (RX_data)
    );

 buffer_filler buffer_filler(
     .clk       (clk_10MHz),
     .rst_n     (sw[15] && locked),
     .data_in   (RX_data),
     .dval      (valid_RX),
     .data_out  (buffer_data),
     .data_ready(buffer_ready)
     );
 
 wire [31:0] instr_out;
 (* dont_touch = "yes" *) instr_mem instr_mem(
    .clk        (clk_10MHz),
    .rst_n      (sw[15]),
    .address    (sw[7:0]),
    .load_en    (buffer_ready),
    .load_inst  (buffer_data),
    .instruction(instr_out)
    );
    
    (* dont_touch = "yes" *) block_mem MEM(
    .clk(clk_10MHz),
    .rst_n(sw[15]),
    .address(sw[13:0]),
    .mem_write(1'b0),
    .mem_read(1'b0),
    .write_data(32'd0),
    .read_data()
);

//always @(posedge clk_10MHz, negedge sw[15]) begin
//    if(!sw[15]) begin
//        led <= 0;
//    end else begin
//        if(!sw[14]) led <= instr_out[15:0];
//        else led <= instr_out[31:16];
//    end
//end
    
endmodule