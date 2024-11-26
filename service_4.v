`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Seoul National University. ECE. Logic Design
// Engineer: Hyewoo Jeong
// 
// Create Date: 2024/11/10 17:49:08
// Design Name: Service_4_alarm_check
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
//////////////////////////////////////a////////////////////////////////////////////

// define state assignment - binary
`define SWIDTH 3 // State width
`define S0 3'b000
`define S1 3'b001
`define S2 3'b010
`define S3 3'b100

`define CWIDTH 16
`define C0 16'b0000000000000000
`define C1 16'b0000000000000001
`define C2 16'b0000000000000010
`define C3 16'b0000000000000011

`define RWIDTH 10

module DFF(clk, in, out);
    parameter n = 1; //width
    input clk;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;
    always @(posedge clk)
        out = in;
endmodule

module Service_4_alarm_check(
    input clk,
    input resetn, // reset
    input SPDT4, // input string (1bit)
    input [15:0] current, // currnet_time
    input [15:0] alarm, // alarm_time
    input push_m,
    input mini_game,
    
    output [2:0] alarm_state // state 1. alarm on, state 2. minigame, state 3. alarm off.
    );
    //000 => basic state , 001 => SPDT4 on, 010 => comparator = 1(alarm_on), 100 => minigame
    wire comparation;
    wire [2:0] next;
    reg [2:0] next_state;
    
    assign comparation = (current == alarm);
        
    // state register
    DFF #(`SWIDTH) state_reg(clk, next, alarm_state);
    
    // next state and output equations
    always @(*) begin // when time = alarm.
        if (SPDT4) begin
            case(alarm_state)
                `S0: next_state = `S1;
                `S1: next_state = (comparation ? `S2 : `S1);
                `S2: next_state = (push_m ? `S3 : `S2);
                `S3: next_state = (mini_game ? `S1 : `S3);
                default: next_state = `S1;
            endcase
        end
        else
            next_state = `S0;
    end
    
    // add reset
    assign next = resetn ? `S0 : next_state;
    
endmodule


module Service_4_minigame(
    input clk,
    input resetn,
    input [2:0] alarm_state,
    input [9:0] random_led,
    input [9:0] SPDTs,

    output [15:0] count_state,
    output reg mini_game
);
    // Ãß°¡µÈ º¯¼ö ¼±¾ð

    wire cmp_game;
    wire [15:0] next;
    reg [15:0] next_count;

    // random_led¿Í SPDTs ºñ±³
    assign cmp_game = (random_led == SPDTs);
    DFF #(`CWIDTH) state_reg(clk, next, count_state);
    
    // Combinational logic for next_count and next_mini_game
    always @(*) begin
        case (alarm_state)
            `S3: begin
                case (count_state)
                    `C0: begin
                        next_count = cmp_game ? `C1 : `C0;
                        mini_game = 1'b0;
                    end
                    `C1: begin
                        next_count = cmp_game ? `C2 : `C0;
                        mini_game = 1'b0;
                    end
                    `C2: begin
                        next_count = cmp_game ? `C3 : `C0;
                        mini_game = 1'b0;
                    end
                    `C3: begin
                        next_count = `C0;
                        mini_game = 1'b1;
                    end
                    default: begin
                        next_count = `C0;
                        mini_game = 1'b0;
                    end
                endcase
            end
            default: begin
                next_count = `C0;
                mini_game = 1'b0;
            end
       endcase
    end
    
    assign next = resetn ? `C0 : next_count;

endmodule
