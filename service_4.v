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

module Service_4(
	input clk,
	input resetn,
	input SPDT4,
	input [15:0] current,
	input push_m,
	input mini_game,
	input [9:0] SPDTs,

	output [2:0] alarm_state
	output [15:0] count_state,
	output reg mini_game,
	output [9:0] hot
);

	Service_4_alarm_check(
		.clk(clk),
		.resetn(resetn),
		.SPDT4(SPDT4),
		.current(current),
		.alarm(alarm),
		.push_m(push_m).
		.mini_game(mini_game),
		.alarm_state(alarm_state)
	);
	Service_4_minigame(
		.clk(clk),
		.resetn(resetn),
		.alarm_state(alarm_state),
		.random_led(random_led),
		.SPDTs(SPDTs),

		.count
		
endmodule

module Service_4_alarm_check(
    input clk,
    input resetn, // reset
    input SPDT4, // input string (1bit)
    input [15:0] current, // current_time
    input [15:0] alarm, // alarm_time
    input push_m,
    input mini_game,
    
    output reg [2:0] alarm_state // state 1. alarm on, state 2. minigame, state 3. alarm off.
    );
    //000 => basic state , 001 => SPDT4 on, 010 => comparator = 1(alarm_on), 100 => minigame

    always @(posedge clk) begin 
		if (!resetn) 
		    alarm_state <= `S0;    
	    else begin
			if (SPDT4) begin// when time = alarm.
		            case(alarm_state)
		                `S0: alarm_state <= `S1;
		                `S1: alarm_state <= ((current == alarm) ? `S2 : `S1);
		                `S2: alarm_state <= (push_m ? `S3 : `S2);
		                `S3: alarm_state <= (mini_game ? `S1 : `S3);
		                default: alarm_state <= `S1;
		            endcase
		        end
	        else
	            alarm_state = `S0;
    end
endmodule

module Service_4_minigame(
    input clk,
    input resetn,
    input [2:0] alarm_state,
    input [9:0] random_led,
    input [9:0] SPDTs,

    output reg [15:0] count_state,
    output reg mini_game
);
    // 추가된 변수 선언
    wire cmp_game;

    // random_led와 SPDTs 비교
    assign cmp_game = (random_led == SPDTs);
    
    // Combinational logic for next_count and next_mini_game
    always @(*) begin
		if (!resetn) begin
			count_state = `C0;
			mini_game = 1'b0;
		else begin
	        case (alarm_state)
	            `S3: begin
	                case (count_state)
	                    `C0: begin
	                        count_state = cmp_game ? `C1 : `C0;
	                        mini_game = 1'b0;
	                    end
	                    `C1: begin
	                        count_state = cmp_game ? `C2 : `C0;
	                        mini_game = 1'b0;
	                    end
	                    `C2: begin
	                        count_state <= cmp_game ? `C3 : `C0;
	                        mini_game <= 1'b0;
	                    end
	                    `C3: begin
	                        count_state <= `C0;
	                        mini_game <= 1'b1;
	                    end
	                    default: begin
	                        count_state <= `C0;
	                        mini_game <= 1'b0;
	                    end
	                endcase
	            end
	            default: begin
	                count_state = `C0;
	                mini_game = 1'b0;
	            end
	       endcase
		end
    end

endmodule


module Service_4_random
(
	input clk,
	input resetn,
	output [9:0] hot //output
);
    reg  [3:0]	r_reg = 4'b1011; // LFSR의 초기값
    wire feedback_value;
	wire q;
    
	always @(posedge clk) begin
		if (!resetn)
			r_reg = 4'b1011;
		else	
			r_reg <= {r_reg[2:0], feedback_value}; // shift & feedback
    end
    
    assign feedback_value = r_reg[3] ^ r_reg[2]; // feedback value를 assign
    assign q = (r_reg >= 4'b1001 ? r_reg-4'b1001: r_reg); // 4개의 Register 값을 출력으로 내보낸다.

	always @(*) begin
		hot = 10'b0000000001 << q;
	end
endmodule




