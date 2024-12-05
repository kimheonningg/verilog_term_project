`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:    SNU 
// Engineer:    SNUCAD 
// 
// Create Date:    11/08/2021 
// Design Name:    Traffic Light Controller 
// Module Name:    make_clk 
// Project Name:    TLC 
// Description:    Digital Logic Design and Lab (2021, Fall semester, 430.201A_001) 
//
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
module make_clk(
    input clk_osc,
    input RESET,
    output reg clk,
    output reset
    );
    
    
    reg [26:0] counter;
    
    
    // CLOCK signal
    always @(posedge clk_osc) begin
        // reset
        if (RESET) begin
            counter <= 27'd0;
            clk <= 1'b0;
        end
        else begin
            // if counter reaches desired timing: 0.5s (= 1s/2)
            // Spartan-3 FPGA Starter Kit Board has a 50 MHz clock oscillator
            if (counter == 27'd20) begin//24999999
                counter <= 27'd0;    // reset counter
                clk <= ~clk;    // invert CLOCK
            end
            else begin
                counter <= counter + 1;
            end
        end
    end
    
    // RESET_OUT signal
    assign reset = RESET;


endmodule
