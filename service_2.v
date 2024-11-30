//////////////////////////////////////////////////////////////////////////////////
// Company: Seoul National University. ECE. Logic Design
// Engineer: HyoJeong Yu
// 
// Create Date: 2024/11/30
// Design Name: Service_2_alarm_set
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

module Service_2_alarm_set (
    input clk,
    input resetn,
    input spdt2,
    input push_u,
    input push_d,
    input push_l,
    input push_r,
    input [15:0] set_time,

    output [3:0] an,
    output reg finish2,
    output reg [15:0] num, // 15:12 11:8 7:4 3:0 = min min sec sec, each 4bit 0-9
    output reg [15:0] alarm
);

  reg [1:0] seg; // 3 2 1 0 left to right
  reg [3:0] rev_an;

  // select segment
  always @(posedge clk) begin
    if (!resetn) begin
      seg <= 0;
      rev_an <= 0;
    end
    else begin
      if (spdt2) begin
        if (rev_an == 0) begin
          rev_an <= 4'b1000; // init
          seg <= 3;
        end
        else begin
          if (push_l) begin
            seg <= seg + 1;
            rev_an <= (rev_an == 4'b1000) ? 4'b0001 : rev_an << 1;
          end
          else if (push_r) begin
            seg <= seg - 1;
            rev_an <= (rev_an == 4'b0001) ? 4'b1000 : rev_an >> 1;
          end
        end
      end
      if (finish2) rev_an <= 4'b1111;
    end
  end

  // set time
  always @(posedge clk) begin
    if (!resetn) begin
      num <= 0;
      alarm <= 0;
    end
    else begin
      if (spdt2) begin
        if (push_d) begin
          num[4*seg+:4] = (num[4*seg+:4] == 0) ? 9 : num[4*seg+:4] - 1;
        end else if (push_u) begin
          num[4*seg+:4] = num[4*seg+:4] == 9 ? 0 : num[4*seg+:4] + 1;
        end
      end

      if (finish2) begin
        alarm <= num;
        num <= set_time;
      end
    end
  end

  // finish
  always @(posedge clk) begin
    if (!resetn) finish2 <= 0;
    else if (!spdt2 & rev_an) finish2 <= 1;
  end

  assign an = (rev_an == 0) ? 0 : ~rev_an;

endmodule

