`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Seoul National University. ECE. Logic Design
// Engineer: Huiwone Kim
// 
// Create Date: 2024/11/26 16:25:00
// Design Name: 
// Module Name: 
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

// define constants
`define SERVICERESET = 4'b0000; // reset
`define SERVICE1 = 4'b1000; // spdt switch1 on - service 1
`define SERVICE2 = 4'b0100; // spdt switch2 on - service 2
`define SERVICE3 = 4'b0010; // spdt switch3 on - service 3
`define SERVICE4 = 4'b0001; // spdt switch4 on - service 4

// D flip flop
module DFF(clk, in, out);
    parameter n = 1;
    input clk;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;
    always @(posedge clk)
        out = in;
endmodule

// Main module
module Main(
    input [4:0] push, // 5 push buttons
    input [14:0] spdt, 
    // 4 spdt switches for changing modes + 
    // 10 spdt switches for mini game +
    // 1 spdt switch for reset
    input clk, // clock
    
    output [27:0] seg, // 4 7-segment control
    output [9:0] led, // 10 leds control
    output clk_led // clock led control
    );

    // interpret spdt switches
    wire [3:0] spdt_service = spdt[14:11]; // 4 spdt switches for changing modes
    wire [9:0] spdt_mini_game = spdt[10:1]; // 10 spdt switches for mini game
    wire resetn = spdt[0]; // 1 spdt switch for reset

    // assign service buttons 
    wire SPDT1_dff_in, SPDT2_dff_in, SPDT3_dff_in, SPDT4_dff_in;
    wire SPDT1, SPDT2, SPDT3, SPDT4;

    assign SPDT1_dff_in = resetn ? 0 : spdt_service[3];
    assign SPDT2_dff_in = resetn ? 0 : spdt_service[2];
    assign SPDT3_dff_in = resetn ? 0 : spdt_service[1];
    assign SPDT4_dff_in = resetn ? 0 : spdt_service[0];
    
    // update spdt switch states using d flip flops
    DFF #(1) dff_SPDT1 (.clk(clk), .in(SPDT1_dff_in), .out(SPDT1));
    DFF #(1) dff_SPDT2 (.clk(clk), .in(SPDT2_dff_in), .out(SPDT2));
    DFF #(1) dff_SPDT3 (.clk(clk), .in(SPDT3_dff_in), .out(SPDT3));
    DFF #(1) dff_SPDT4 (.clk(clk), .in(SPDT4_dff_in), .out(SPDT4));

    // assign push buttons
    wire push_u = push[0]; // is push up button pressed
    wire push_d = push[1]; // is push down button pressed
    wire push_l = push[2]; // is push left button pressed
    wire push_r = push[3]; // is push right button pressed
    wire push_m = push[4]; // is push middle button pressed

    // store current time and alarm time
    reg [15:0] current; // current time
    reg [15:0] alarm; // alarm time

    reg [2:0] alarm_state; // state 1. alarm on, state 2. minigame, state 3. alarm off.

    // instantiate modules
    // Service_1_ service_1();
    // Service_2_ service_2();
    // Service_3_ service_3();
    Service_4_alarm_check service_4(
        .clk(clk), 
        .resetn(resetn), 
        .SPDT4(SPDT4), 
        .current(current),
        .alarm(alarm),
        .push_m(push_m),
        .mini_game(),
        .alarm_state(alarm_state)
    );

    // wire that connect with 7-segment
    wire [27:0] segValues;
    wire [27:0] finalSegValues;

    // reg that stores the output number array for the 7-segment
    reg [15:0] num;

    // use the NumArrayTo7SegmentArray module to convert number to 7-segment
    NumArrayTo7SegmentArray numArrToSegArr (
        .numberArray(num),
        .segArray(segValues)
    )

    // update 7 segment using d flip flop
     DFF #(28) segValuesDFF (.clk(clk), .in(segValues), .out(finalSegValues));

endmodule

module NumArrayTo7SegmentArray(
    input [15:0] numberArray,
    output reg [27:0] segArray
);

    wire [3:0] number1, number2, number3, number4;
    // number1 at the very left,
    // and number4 at the very right

    assign number1 = numberArray[15:12];
    assign number2 = numberArray[11:8];
    assign number3 = numberArray[7:4];
    assign number4 = numberArray[3:0];

    // the 7-segment encoding for each four numbers
    wire [6:0] seg1, seg2, seg3, seg4;

    // instantiate the NumTo7Segment module for each number
    NumTo7Segment u1 (.number(number1), .seg(seg1));
    NumTo7Segment u2 (.number(number2), .seg(seg2));
    NumTo7Segment u3 (.number(number3), .seg(seg3));
    NumTo7Segment u4 (.number(number4), .seg(seg4));

    assign segArray = {seg1, seg2, seg3, seg4}; 
    // seg1 is at the very left,
    // and  seg4 is at the very right

endmodule

module NumTo7Segment(
    input [3:0] number,
    output reg [6:0] seg
);

    always @(*) begin
        case (number)
            4'b0000: seg = 7'b0111111; // 0
            4'b0001: seg = 7'b0000110; // 1
            4'b0010: seg = 7'b1011011; // 2
            4'b0011: seg = 7'b1001111; // 3
            4'b0100: seg = 7'b1100110; // 4
            4'b0101: seg = 7'b1101101; // 5
            4'b0110: seg = 7'b1111101; // 6
            4'b0111: seg = 7'b0000111; // 7
            4'b1000: seg = 7'b1111111; // 8
            4'b1001: seg = 7'b1101111; // 9
            default: seg = 7'b0000000; // Blank for invalid input
        endcase
    end
    
endmodule