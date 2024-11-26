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
`define RN0 

module DFF(clk, in, out);
    parameter n = 1; //width
    input clk;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;
    always @(posedge clk)
        out = in;
endmodule

// String Pattern Recognizer module
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
    // 추가된 변수 선언

    wire cmp_game;
    wire [15:0] next;
    reg [15:0] next_count;

    // random_led와 SPDTs 비교
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


module Service_4_random
(
	input clk, // clock
	output [3:0] q, // output
	output [9:0] hot
);
    
    reg  [3:0]	r_reg = 4'b1011; // LFSR의 초기값
    wire 		feedback_value; 
    
    always @(posedge clk) begin
        r_reg <= {r_reg[3:0], feedback_value}; // shift & feedback
        r_reg = r_reg+1;
    end
    
    assign feedback_value = r_reg[3] ^ r_reg[2]; // feedback value를 assign
    assign q = (r_reg >= 4'b1001 ? r_reg-4'b1001: r_reg); // 4개의 Register 값을 출력으로 내보낸다.
    assign hot = 10'b0000000001 << q;
    

endmodule




