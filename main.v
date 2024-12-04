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
`define SERVICERESET 4'b0000 // reset
`define SERVICE1 4'b1000 // spdt switch1 on - service 1
`define SERVICE2 4'b0100 // spdt switch2 on - service 2
`define SERVICE3 4'b0010 // spdt switch3 on - service 3
`define SERVICE4 4'b0001 // spdt switch4 on - service 4

// Main module
module Main(
    input [4:0] push, // 5 push buttons
    input [14:0] spdt, 
    // 4 spdt switches for changing modes + 
    // 10 spdt switches for mini game +
    // 1 spdt switch for reset
    input clk_osc, 
    
    output wire [7:0] eSeg, // 7-segment control
    output reg [3:0] anode, // 7-segment control
    output [13:0] led, // 4 spdt leds + 10 mini game leds control
    output clk_led // clock led control
    );

    // interpret spdt switches
    wire [3:0] spdt_service = spdt[14:11]; // 4 spdt switches for changing modes
    wire [9:0] spdt_mini_game = spdt[10:1]; // 10 spdt switches for mini game
    wire reset = spdt[0]; // 1 spdt switch for reset
    wire resetn;
    wire clk;

    // make sClk
    wire sClk;
    wire [1:0] iter; // wire for anode handling
    reg [17:0] counter = 18'd0;
    assign iter = counter[17:16];
    always @(posedge clk_osc) begin
        counter <= counter + 1;
    end

    assign sClk = counter[15];

    // connect with make_clk module
    make_clk make_clk_(
        .clk_osc(clk_osc),
        .reset(reset), 
        .clk(clk),
        .resetn(resetn)
    );

    // interpret leds
    reg [3:0] spdt_led; // 4 leds above spdt switches
    assign led[13:10] = spdt_led;
    reg [9:0] mini_game_led; // 10 leds above mini game switches
    assign led[9:0] = mini_game_led;

    // assign service buttons 
    wire SPDT1, SPDT2, SPDT3, SPDT4;
    assign SPDT1 = resetn ? 0 : spdt_service[3];
    assign SPDT2 = resetn ? 0 : spdt_service[2];
    assign SPDT3 = resetn ? 0 : spdt_service[1];
    assign SPDT4 = resetn ? 0 : spdt_service[0];

    // assign push buttons
    wire push_u = push[0]; // is push up button pressed
    wire push_d = push[1]; // is push down button pressed
    wire push_l = push[2]; // is push left button pressed
    wire push_r = push[3]; // is push right button pressed
    wire push_m = push[4]; // is push middle button pressed

    // finish wires
    wire finish1;
    wire finish2;
    wire finish3;
    wire finish4;

    // turn on spdt_leds
    always @(spdt_service) begin
        case(spdt_service)
            `SERVICERESET: spdt_led = 4'b0000;
            `SERVICE1: spdt_led = 4'b1000;
            `SERVICE2: spdt_led = 4'b0100;
            `SERVICE3: spdt_led = 4'b0010;
            `SERVICE4: spdt_led = 4'b0001;
            default: spdt_led = 4'b0000;
        endcase
    end

    // turn off spdt_leds when it is finished
    always @(finish1, finish2, finish3, finish4) begin
        if (finish1 || finish2 || finish3 || finish4) begin
            spdt_led = 4'b0000; // Finish �긽�깭�뿉�꽌 �걫
        end else begin
            case(spdt_service)
                `SERVICERESET: spdt_led = 4'b0000;
                `SERVICE1: spdt_led = 4'b1000;
                `SERVICE2: spdt_led = 4'b0100;
                `SERVICE3: spdt_led = 4'b0010;
                `SERVICE4: spdt_led = 4'b0001;
                default: spdt_led = 4'b0000;
            endcase
        end
    end

    // store current time and alarm time
    reg [15:0] current_time; // current time
    wire [15:0] alarm_time; // alarm time

    wire [2:0] alarm_state; // state 1. alarm on, state 2. minigame, state 3. alarm off.

    wire [3:0] which_seg_on; // one-hot style, tells which location segment is on

    // clock tick indicator led signal
    assign clk_led = clk;

    // wire for the output number array for the 7-segment
    wire [15:0] num;

    // wire for each number of the number array
    wire [3:0] eachNum;

    // TODO: add initial state 0000, with resetn

    // instantiate modules
    Service_1_time_set service_1(
        .clk(clk),
        .resetn(resetn),
        .spdt1(SPDT1),
        .push_u(push_u),
        .push_d(push_d),
        .push_l(push_l),
        .push_r(push_r),
        .sel(which_seg_on),
        .finish1(finish1),
        .num(num)
    );
    Service_2_alarm_set service_2(
        .clk(clk),
        .resetn(resetn),
        .spdt2(SPDT2),
        .push_u(push_u),
        .push_d(push_d),
        .push_l(push_l),
        .push_r(push_r),
        .sel(which_seg_on),
        .finish2(finish2),
        .alarm(alarm_time)
    );
    Service_3_StopWatch service_3(
        .clk(clk_osc),
        .resetn(resetn),
        .SPDT3(SPDT3),
        .push_m(push_m),
        .segments(num),
        .finish3(finish3)
    );
    // Service_4_alarm_check service_4(
    //     .clk(clk), 
    //     .resetn(resetn), 
    //     .SPDT4(SPDT4), 
    //     .current(current_time),
    //     .alarm(alarm_time),
    //     .push_m(push_m),
    //     .mini_game(),
    //     .alarm_state(alarm_state)
    // );

    wire [3:0] currentNum;

    // update segments
    always @(posedge sClk) begin
        case (iter)
            2'd0: begin // right-est segment
                anode <= 4'b1110;
                currentNum <= num[3:0];
            end
            2'd1: begin
                anode <= 4'b1101;
                currentNum <= num[7:4];
            end
            2'd2: begin
                anode <= 4'b1011;
                currentNum <= num[11:8];
            end
            2'd3: begin // left-est segment
                anode <= 4'b0111;
                currentNum <= num[15:12];
            end
            default: begin
                anode <= 4'b1111;
                eSeg <= 7'b0111111; // 0 for default
            end
        endcase
        if(which_seg_on == anode) anode <= (!(which_seg_on) & clk);
    end
    
    // use the NumTo7Segment module to convert number to 7-segment
    NumTo7Segment numTo7Seg (
        .number(currentNum),
        .seg(eSeg)
    );

    // update current_time
    always @(posedge clk or negedge resetn) begin
        // if current_time is not undefined, update current_time
       if (!resetn) begin
            current_time <= 16'd0;
       end
        if (current_time == 16'd5959) begin
            // Reset to 0000 when current_time is 5959 (59:59)
            current_time <= 16'd0;
        end else if (current_time[7:0] == 8'd59) begin
            // If the lower 8 bits of current_time are 59, 
            // current_time[15:8] + 1 and current_time[7:0] = 0
            current_time[15:8] <= current_time[15:8] + 1;
            current_time[7:0] <= 8'd0;
        end else begin
            // Otherwise, just do + 1
            current_time <= current_time + 1;
        end
    end
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

    always @(*) begin
        segArray[27:21] = seg1;
        segArray[20:14] = seg2;
        segArray[13:7]  = seg3;
        segArray[6:0]   = seg4;
    end
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
