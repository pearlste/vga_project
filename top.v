`timescale 1ns / 1ps


module top(
    input clk_in1,
    input rst_,
    output VGA_HS,
    output VGA_VS,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B);
    
    wire enable_V_counter;
    wire [15:0] H_count_value;
    wire [15:0] V_count_value;
    reg reset;
    reg pre_reset;
    wire clk;
    wire locked;
    
    always @ (posedge clk)
    begin
        pre_reset <= ~rst_;
        reset <= pre_reset;
    end
    
    //values to use for simulation
//    `define ACTIVE_Hend (63)
//    `define FRONT_PORCH_Hend (65)
//    `define SYNC_PULSE_Hend (75)
//    `define BACKPORCH_Hend (79)
    
//    `define ACTIVE_Vend (40)
//    `define FRONT_PORCH_Vend (43)
//    `define SYNC_PULSE_Vend (46)
//    `define BACKPORCH_Vend (52)

    `define ACTIVE_Hend (639)
    `define FRONT_PORCH_Hend (655)
    `define SYNC_PULSE_Hend (751)
    `define BACKPORCH_Hend (799)
    
    `define ACTIVE_Vend (479)
    `define FRONT_PORCH_Vend (489)
    `define SYNC_PULSE_Vend (491)
    `define BACKPORCH_Vend (520)
    
    horizontal_counter #(.BACKPORCH_Hend(`BACKPORCH_Hend)) vga_horiz(clk, reset, enable_V_counter, H_count_value);
    vertical_counter #(.BACKPORCH_Vend(`BACKPORCH_Vend)) vga_vert(clk, reset, enable_V_counter, V_count_value);
    
    
    //real values


    
    //outputs
    assign VGA_HS = ~(H_count_value > `FRONT_PORCH_Hend && H_count_value <= `SYNC_PULSE_Hend) ? 1'b1:1'b0;
    assign VGA_VS = ~(V_count_value > `FRONT_PORCH_Vend && V_count_value <= `SYNC_PULSE_Vend) ? 1'b1:1'b0;
   
    reg signed [9:0] top; //y coord
    reg signed [10:0] left; //x coord
    reg [9:0] length;
    reg [8:0] height;
    reg [6:0] vx_mag; //x magnitude
    reg [6:0] vy_mag; //y magnitude
    reg signed [7:0] vx_dir; //actual x direction
    reg signed [7:0] vy_dir; //actual y direction
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            length <= 20;
            height <= 20;
            vx_mag <= 5;
            vy_mag <= 4;
            vx_dir <= -vx_mag; //initially = -5
            vy_dir <= vy_mag; //initially = 4
        end
        else if (H_count_value == 0 && V_count_value == 0)
        begin
            //left edge bounce
            if(left <= $signed(H_count_value)) //problem: must be signed comparison/ /
                vx_dir <= vx_mag;
            //right edge bounce
            else if((left + length) >= `ACTIVE_Hend)
                vx_dir <= -vx_mag;
            //top edge bounce
            if(top <= $signed(V_count_value))
                vy_dir <= vy_mag;
            //bottom edge bounce
            else if((top + height) >= `ACTIVE_Vend)
                vy_dir <= -vy_mag;
            
        end
    end
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            top <= 0;
            left <= 0;
        end
        else
        begin
            if(H_count_value == 0 && V_count_value == 0)
            begin
                top <= top + vy_dir;
                left <= left + vx_dir;
            end
        end
    end
    
    always @ (*)
    begin
        
    //animating a square
    //basically just a box
    if(H_count_value <= `ACTIVE_Hend && V_count_value <= `ACTIVE_Vend)
    begin
        if(V_count_value >= top && V_count_value <= (top + height) && H_count_value >= left && H_count_value <= (left + length))
        begin
            VGA_R = 4'hf;
            VGA_G = 4'hf;
            VGA_B = 4'hf;
        end
        else
        begin
            VGA_R = 4'h0;
            VGA_G = 4'h0;
            VGA_B = 4'h0;
        end
    end
end 
    
    
    clk_wiz_0 CLKWIZ0(.clk_out1(clk), .locked(locked), .clk_in1(clk_in1));
endmodule
