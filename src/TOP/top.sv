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

module top(
    input clk,
    input [15:0]sw,
    input RxD,
    output reg [15:0] led    
); 

wire valid_RX;
wire [7:0] RX_data;
wire buffer_ready;
wire [31:0] buffer_data;

//uart_rx RX(
//    .clk          (clk),
//    .resetn       (sw[15]),
//    .uart_rxd     (RxD),
//    .uart_rx_en   (1'b1),
//    .uart_rx_valid(valid_RX),
//    .uart_rx_data (RX_data)
//    );

uart_receiver RX(
    .i_Clk          (clk),
    .i_RX_Serial    (RxD),
    .o_RX_DV        (valid_RX),
    .o_RX_Byte      (RX_data)
    );
    
// buffer_filler buffer_filler(
//     .clk       (clk),
//     .rst_n     (sw[15]),
//     .data_in   (RX_data), 
//     .dval      (valid_RX),         
//     .data_out  (buffer_data),
//     .data_ready(buffer_ready) 
//     );
// 
// wire [31:0] instr_out;
// instr_mem instr_mem(
//    .clk        (clk),
//    .rst_n      (sw[15]),
//    .address    (sw[7:0]),
//    .load_en    (buffer_ready),
//    .load_inst  (buffer_data),
//    .instruction(instr_out)
//    );

always @(posedge clk, negedge sw[15]) begin
    if(!sw[15]) begin
        led <= 0;
    end else begin
        if(valid_RX) begin
            led <= {8'b0,RX_data};
        end
    end
end

    
endmodule