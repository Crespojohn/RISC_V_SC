//Author: Oscar Balan
//TODO: Test against less reliable UART connections
module receiver
(
    input        clk  ,
    input        RxD  ,
    output       valid,
    output [7:0] data 
);

reg [13:0] counter;
reg        baud_clk;
reg [ 7:0] shift_buffer;
reg [ 3:0] shift_counter;
reg        shift_mode;
reg        shift_valid;

assign valid = shift_valid;
assign data = shift_buffer;

initial begin
    counter <= 0;
    baud_clk <= 0;
    shift_valid <= 0;
    shift_mode <= 0;
end

always @(posedge clk) begin 
    //Counter for 9600 Hz clock
    if(counter >= 1042) begin 
        counter <= 0;
        baud_clk <= 1;
    end
    else begin 
        counter <= counter + 1;
        baud_clk <= 0;
    end
    //Reset valid signal after asserted for 1 cycle
    if(shift_valid) begin 
        shift_valid <= 0;
    end
    //State machine for receiver on 9600 Hz clock
    if(baud_clk) begin 
        if(shift_mode == 0) begin 
            if(RxD == 0) begin 
                shift_counter <= 0;
                shift_mode <= 1;
            end
            shift_valid <= 0;
        end
        else begin 
            if(shift_counter >= 8) begin 
                shift_mode <= 0;
                shift_valid <= 1;
            end
            else begin 
                shift_counter <= shift_counter + 1;
                shift_buffer[6:0] <= shift_buffer[7:1];
                shift_buffer[7] <= RxD;
            end
        end
    end
end

endmodule