# 2024 2학기 논리설계 및 실험 프로젝트

## module 구성

- main module: 중앙 통제 역할
- 기능1 module: 시각 설정
- 기능2 module: 알람 시각 설정
- 기능3 module: 스톱워치
- 기능4 module: 알람 on/off + 알람 미니게임

## inputs / ouputs of each module

### main 모듈: `main.v` 파일

- inputs: reset, push[4:0], spdt[3:0]
- outputs: seg[27:0], led[9:0], clk_led

### 기능1 모듈: `service_1.v` 파일

- inputs: clk, resetn, spdt1, push_u, push_d, push_l, push_r
- outputs: finish1, seg[15:0]

### 기능2 모듈: `service_2.v` 파일

- inputs: clk, resetn, spdt2, push_u, push_d, push_l, push_r
- outputs: finish2, seg[15:0]

### 기능3 모듈: `service_3.v` 파일

- inputs: clk, resetn, spdt3, push_m
- outputs: finish3, led, s[7:0], ss[7:0]

### 기능4 모듈: `service_4.v` 파일
`Service_4_alarm_check`
- inputs
    input clk,
    input resetn, // reset
    input SPDT4, // input string (1bit)
    input [15:0] current, // currnet_time
    input [15:0] alarm, // alarm_time
    input push_m,
    input mini_game,
  
- outputs
    output [2:0] alarm_state

`Service_4_minigame`
- input
    input clk,
    input resetn,
    input [2:0] alarm_state,
    input [9:0] random_led,
    input [9:0] SPDTs,
  
- output
    output [15:0] count_state,
    output reg mini_game

`Service_4_random`
tbd
