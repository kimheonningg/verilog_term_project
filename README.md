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
- **inputs:** <br>
      input [4:0] push, // 5 push buttons <br>
      input [14:0] spdt, <br>
      // 4 spdt switches for changing modes + 10 spdt switches for mini game + 1 spdt switch for reset <br>
      input clk, // clock

- **outputs:** <br>
      output [27:0] seg, // 4 7-segment control <br>
      output [9:0] led, // 10 leds control <br>
      output clk_led // clock led control <br>

`NumArrayTo7SegmentArray`

`NumTo7Segment`

### 기능1 모듈: `service_1.v` 파일

- inputs: clk, resetn, spdt1, push_u, push_d, push_l, push_r
- outputs: finish1, num[15:0]

### 기능2 모듈: `service_2.v` 파일

- inputs: clk, resetn, spdt2, push_u, push_d, push_l, push_r
- outputs: finish2, num[15:0]

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

    output [15:0] ? //Seg LEDs
    output [15:0] ? //SPDT LEDs
