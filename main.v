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
`define SERVICE1 = 4'b1000; // spdt switch1 on - service 1
`define SERVICE2 = 4'b0100; // spdt switch2 on - service 2
`define SERVICE3 = 4'b0010; // spdt switch3 on - service 3
`define SERVICE4 = 4'b0001; // spdt switch4 on - service 4

// D flip flop
module DFF(clk, in, out);
    parameter n = 1; //width
    input clk;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;
    always @(posedge clk)
        out = in;
endmodule

// Main module
module Main(
    input resetn, // reset
    input [4:0] push, // 5 push buttons
    input [13:0] spdt, 
    // 4 spdt switches for changing modes + 10 spdt switches for mini game
    input clk, // clock
    
    output [27:0] seg, // 4 7-segment control
    output [9:0] led, // 10 leds control
    output clk_led // clock led control
    );

    wire [3:0] spdt_service; // 4 spdt switches for changing modes
    wire [9:0] spdt_mini_game; // 10 spdt switches for mini game
    
    // assign service buttons
    assign spdt_service = spdt[13:10];
    wire SPDT1 = spdt_service[3];
    wire SPDT2 = spdt_service[2];
    wire SPDT3 = spdt_service[1];
    wire SPDT4 = spdt_service[0];

    // for mini game
    assign spdt_mini_game = spdt[9:0];

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

    // handle reset
    always @(resetn) begin
    end

endmodule
