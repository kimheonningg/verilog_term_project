`timescale 1ns / 1ps

/* tb for service_2
author: HyoJeong Yu
date: 2024/11/30
*/

module tb;

  `define expected1 16'b0000_1001_0011_1000 // alarm
  `define expected2 16'b0001_0110_0011_0000 // set time
  reg clk;
  reg resetn;
  reg spdt2;
  reg u, d, l, r;
  reg [15:0] set_time;
  wire [15:0] set_time_in;
  wire [3:0] an;
  wire finish2;
  reg finish;
  wire [15:0] num;
  wire [15:0] alarm;

  initial begin
    clk = 0;
    forever #(5) clk = ~clk;
  end

  initial begin
    resetn = 0;
    spdt2 = 0;
    u = 0;
    d = 0;
    r = 0;
    l = 0;
    set_time = 16'b0001_0110_0011_0000; // 16:30
  end
  
  initial begin
    #10;
    resetn = 1;

    #20;
    spdt2 = 1;

    $display("set time is 16:30. setting alarm to 09:38\n");

    // Sequence for setting 09:38

    //9
    repeat (2) @(posedge clk);
    r = 1;
    @(posedge clk);
    r = 0;

    @(posedge clk);
    d = 1;
    @(posedge clk);
    d = 0;
    
    //3
    repeat (3) @(posedge clk);
    r = 1;
    @(posedge clk);
    r = 0;

    repeat (2) @(posedge clk);
    repeat (3) begin
      u = 1;
      @(posedge clk);
      u = 0;
    end

    //8
    repeat (5) @(posedge clk);
    r = 1;
    @(posedge clk);
    r = 0;

    repeat (2) @(posedge clk);
    repeat (2) begin
      d = 1;
      @(posedge clk);
      d = 0;
    end

    repeat (5) @(posedge clk);
    spdt2 = 0;
  end

  always @(posedge clk) begin
    finish <= finish2;
    if (finish) begin
      if (alarm == `expected1) $display("alarm is correct!\n");
      else begin
        $display("result is different.\n");
        $display("your result:%b", alarm);
      end

      if (num == `expected2) $display("displayed set time is correct!\n");
      else begin
        $display("result is different.\n");
        $display("your result:%b", num);
      end

      $display("test done\n");
      $finish;
    end
  end
  
  assign set_time_in = set_time;
  
  Service_2_alarm_set u_alarm_set (
    .clk(clk),
    .resetn(resetn),
    .spdt2(spdt2),
    .push_u(u),
    .push_d(d),
    .push_l(l),
    .push_r(r),
    .set_time(set_time_in),

    .an(an),
    .finish2(finish2),
    .num(num),
    .alarm(alarm)
  );
endmodule
