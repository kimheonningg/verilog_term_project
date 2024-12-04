`timescale 1ns / 1ps

/* tb for service_1
author: Huiwone Kim
date: 2024/12/04
*/

module Main_tb;

    // Inputs
    reg [4:0] push;
    reg [14:0] spdt;
    reg clk;

    // Outputs
    wire [27:0] seg;
    wire [13:0] led;
    wire clk_led;

    // Instantiate
    Main uut (
        .push(push),
        .spdt(spdt),
        .clk(clk),
        .seg(seg),
        .led(led),
        .clk_led(clk_led)
    );

    // Clock generation
    always #100 clk = ~clk;

    integer i;

    // Initialize inputs and run test cases
    initial begin
        // Initialize clock and inputs
        clk = 0;
        push = 5'b00000;
        spdt = 15'b000_0000_0000_0000;

        // 1. Reset Test
        $display("Test 1: Reset");
        spdt[0] = 1; // Reset on
        #1000;      // Wait for reset to propagate
        spdt[0] = 0; // Reset off
        #1000;
        if (seg !== 28'b0) $display("Error: Reset failed!");

        // 2. Time Setting Test
        $display("Test 2: Time Setting");
        spdt[14] = 1; // SPDT1 on
        for (i = 0; i < 10; i = i + 1) begin
            push = 5'b00001; // Push up to increment
            #100;
            push = 5'b00000; // Release
            #100;
        end
        spdt[14] = 0; // SPDT1 off
        #1000;

        // 3. Alarm Setting Test
        $display("Test 3: Alarm Setting");
        spdt[13] = 1; // SPDT2 on
        for (i = 0; i < 5; i = i + 1) begin
            push = 5'b00010; // Push down to decrement
            #100;
            push = 5'b00000; // Release
            #100;
        end
        spdt[13] = 0; // SPDT2 off
        #1000;

        // 4. Stopwatch Test
        $display("Test 4: Stopwatch");
        spdt[12] = 1; // SPDT3 on
        push = 5'b10000; // Start stopwatch
        #100;
        push = 5'b00000; // Release
        #1000;
        push = 5'b10000; // Pause stopwatch
        #100;
        push = 5'b00000; // Release
        #1000;
        spdt[12] = 0; // SPDT3 off
        #1000;

        // 5. Alarm On/Off Test
        $display("Test 5: Alarm On/Off");
        spdt[11] = 1; // SPDT4 on
        #1000;
        spdt[11] = 0; // SPDT4 off
        #1000;

        // 6. Mini Game Test
        $display("Test 6: Mini Game");
        spdt[11] = 1; // Alarm on
        #1000;
        for (i = 0; i < 3; i = i + 1) begin
            spdt[10 - i] = 1; // Random SPDT for mini game
            #1000;
            spdt[10 - i] = 0;
            #1000;
        end
        spdt[11] = 0; // Alarm off
        #1000;

        $display("Done!");
        $finish;
    end
endmodule
