`timescale 1ns / 1ps

module horizontal_counter(
    input clk,
    input reset,
    output enable_V_counter,
    output reg [15:0] H_count_value
    );
    //initialize counters to 0 with reset
    assign enable_V_counter = (H_count_value == 799);
   
    always @ (posedge clk)
    begin
        if(reset == 1)
        begin
            H_count_value <= 0;
        end
        else
        begin
            if(H_count_value < 799)
            begin
                H_count_value <= H_count_value + 1; //counting up
            end
            else if(H_count_value == 799)
            begin
                H_count_value <= 0; // reached end of screen so restart count
            end
        end
    end
    
    
endmodule
