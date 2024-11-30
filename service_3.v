`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Seoul National University. ECE. Logic Design
// Engineer: Junho PArk
// 
// Create Date: 2024/11/26 17:04:35
// Design Name: 
// Module Name: function3
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

// Define state assignments
`define SWIDTH 3 // State width
`define S0 3'b000 // default
`define S1 3'b001 // SPDT ON, waiting push_m
`define S2 3'b010 // Stopwatch running
`define S3 3'b100 // Stopwatch paused



// String Pattern Recognizer module
module Service_3_StopWatch(
    input clk,        // Main clock
    input resetn,     // Reset signal (active low)
    input SPDT3,      // SPDT switch 3
    input push_m,     // Push button
    output reg [3:0] seg1, // 7-segment digit 1 (tens of seconds)
    output reg [3:0] seg2, // 7-segment digit 2 (units of seconds)
    output reg [3:0] seg3, // 7-segment digit 3 (tens of hundredths)
    output reg [3:0] seg4, // 7-segment digit 4 (units of hundredths)
    output reg led,   // LED for SPDT3
    output reg finish3
);

    // Parameters for timing
    parameter CLOCK_FREQ = 100_000_000; // Clock frequency (100MHz)
    parameter HUNDREDTH_TICK = CLOCK_FREQ / 100; // 1/100 second tick
    
    reg [26:0] clk_count;  // Clock counter for timing
    reg [5:0] seconds;     // Seconds (SS)
    reg [6:0] hundredths;  // 1/100 seconds (ss)
    reg [2:0] stopwatch_state, next_state; // State registers
    reg running;           // Stopwatch running flag

    // State definitions
    `define SWIDTH 3
    `define S0 3'b000 // Idle
    `define S1 3'b001 // Stopwatch initialized
    `define S2 3'b010 // Stopwatch running
    `define S3 3'b100 // Stopwatch paused

    // State transitions and control logic
    always @(posedge clk) begin
        if (!resetn) begin
            // Reset all state-related signals
            stopwatch_state <= `S0;
            clk_count <= 0;
            seconds <= 0;
            hundredths <= 0;
            running <= 0;
            led <= 0;
        end else begin
            stopwatch_state <= next_state;  
            
            // Stopwatch functionality
            if (SPDT3) begin
                led <= 1; // Turn on LED for SPDT3
                case (stopwatch_state)
                    `S0: begin
                        // Idle: Reset stopwatch values
                        seconds <= 0;
                        hundredths <= 0;
                        running <= 0;
                    end
                    `S1: begin
                        // Initialized: Wait for push_m to start
                        running <= 0;
                    end
                    `S2: begin
                        // Running: Increment counters
                        running <= 1;
                        if (clk_count == HUNDREDTH_TICK - 1) begin
                            clk_count <= 0;
                            if (hundredths == 99) begin
                                hundredths <= 0;
                                if (seconds == 99) begin
                                    seconds <= 0;
                                end else begin
                                    seconds <= seconds + 1;
                                end
                            end else begin
                                hundredths <= hundredths + 1;
                            end
                        end else begin
                            clk_count <= clk_count + 1;
                        end
                    end
                    `S3: begin
                        // Paused: Hold current time
                        running <= 0;
                    end
                endcase
            end else begin
                // SPDT3 OFF: Reset LED and stop counters
                led <= 0;
                running <= 0;
            end
        end
    end

    // Next state logic
    always @(*) begin
        case (stopwatch_state)
            `S0: next_state = (SPDT3 ? `S1 : `S0); // Idle -> Initialized if SPDT3 ON
            `S1: next_state = (push_m ? `S2 : `S1); // Initialized -> Running if push_m
            `S2: next_state = (push_m ? `S3 : `S2); // Running -> Paused if push_m
            `S3: next_state = (push_m ? `S2 : `S3); // Paused -> Running if push_m
            default: next_state = `S0;
        endcase
    end

    // Convert time to 7-segment display values
    always @(*) begin
        // Seconds
        seg1 = seconds / 10; // Tens of seconds
        seg2 = seconds % 10; // Units of seconds

        // Hundredths of a second
        seg3 = hundredths / 10; // Tens of hundredths
        seg4 = hundredths % 10; // Units of hundredths
    end
    always @(posedge clk) begin // is the case division good?????
    if (!resetn) begin
        finish3 <= 0; // Reset the finish flag
    end else if (!SPDT3) begin
        finish3 <= 1; // Set finish flag when SPDT3 is turned off
    end else begin
        finish3 <= 0; // Clear the finish flag when SPDT3 is on
    end
end

endmodule

