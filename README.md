# 2024 2학기 논리설계 및 실험 프로젝트

## module 구성

- main module: 중앙 통제 역할
- 기능1 module: 시각 설정
- 기능2 module: 알람 시각 설정
- 기능3 module: 스톱워치
- 기능4 module: 알람 on/off + 알람 미니게임

## inputs / ouputs of each module

### main 모듈: `main.v` 파일

`Main`

      input [4:0] push, // 5 push buttons
      input [14:0] spdt,
      // 4 spdt switches for changing modes + 10 spdt switches for mini game + 1 spdt switch for reset
      input clk, // clock
      
      output [27:0] seg, // 4 7-segment control
      output [9:0] led, // 10 leds control
      output clk_led // clock led control

`NumArrayTo7SegmentArray`

`NumTo7Segment`

### 기능1 모듈: `service_1.v` 파일

    input clk,
    input resetn,
    input spdt1,
    input push_u,
    input push_d,
    input push_l,
    input push_r,

    output [3:0] an, // active low. segment trigger. msb(left) to lsb(right)
    output reg finish1, // service1 done
    output reg [15:0] num // segment number. msb(left) to lsb(right)

### 기능2 모듈: `service_2.v` 파일

    input clk,
    input resetn,
    input spdt2,
    input push_u,
    input push_d,
    input push_l,
    input push_r,
    input [15:0] set_time, // time set from service_1. displayed after done.

    output [3:0] an,
    output reg finish2,
    output reg [15:0] num, // segment number. msb(left) to lsb(right)
    output reg [15:0] alarm // alarm time. not displayed, but passed to top module.

### 기능3 모듈: `service_3.v` 파일

    input clk,        // Main clock
    input resetn,     // Reset signal (active low)
    input SPDT3,      // SPDT switch 3
    input push_m,     // Push button
    
    output reg [3:0] num1, // 7-segment digit 1 (tens of seconds)
    output reg [3:0] num2, // 7-segment digit 2 (units of seconds)
    output reg [3:0] num3, // 7-segment digit 3 (tens of hundredths)
    output reg [3:0] num4, // 7-segment digit 4 (units of hundredths)
    output reg led   // LED for SPDT3

### 기능4 모듈: `service_4.v` 파일
(단일화 하는 경우)

    input clk,
    input resetn,     // Reset signal (active low)
    input SPDT4,      // SPDT switch 3
    input push_m,     // Push button
    input [15:0] current, // current_time  <br/>
    input [15:0] alarm, // alarm_time  <br/>
    input push_m,
    input [9:0] SPDTs

    output [15:0] num //Seg LEDs
    output [15:0] ? //SPDT LEDs
    output finish4
