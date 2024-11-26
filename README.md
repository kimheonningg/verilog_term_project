# 2024 2학기 논리설계 및 실험 프로젝트

## module 구성

- main module: 중앙 통제 역할
- 기능1 module: 시각 설정
- 기능2 module: 알람 시각 설정
- 기능3 module: 스톱워치
- 기능4 module: 알람 on/off + 알람 미니게임

## inputs / ouputs of each module

### 기능1 모듈:

- inputs: clk, resetn, spdt1, push_u, push_d, push_l, push_r
- outputs: finish1, seg[15:0]

### 기능2 모듈:

- inputs: clk, resetn, spdt2, push_u, push_d, push_l, push_r
- outputs: finish2, seg[15:0]

### 기능3 모듈:

- inputs: clk, resetn, spdt3, push_m
- outputs: finish3, led, s[7:0], ss[7:0]

### 기능4 모듈:
