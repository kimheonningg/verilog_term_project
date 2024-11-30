// Testbench for Service_3_StopWatch
module tb_Service_3_StopWatch;
    reg clk;
    reg resetn;
    reg SPDT3;
    reg push_m;
    wire [15:0] segments;
    wire led;
    wire finish3;

    // Instantiate the stopwatch module
    Service_3_StopWatch uut (
        .clk(clk),
        .resetn(resetn),
        .SPDT3(SPDT3),
        .push_m(push_m),
        .segments(segments),
        .led(led),
        .finish3(finish3)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        resetn = 0;
        SPDT3 = 0;
        push_m = 0;
        #20;

        // Release reset
        resetn = 1;
        #20;

        // Test SPDT3 ON and stopwatch initialization
        SPDT3 = 1;
        #20;
        if (led == 1 && segments == 16'b0000_0000_0000_0000) $display("[SUCCESS] SPDT3 ON: Stopwatch initialized correctly");
        else $display("[FAIL] SPDT3 ON: Stopwatch initialization failed");

        // Test push_m to start stopwatch
        push_m = 1;
        #10;
        push_m = 0;
        #100;
        if (uut.stopwatch_state == `S2 && led == 1) $display("[SUCCESS] push_m: Stopwatch started correctly");
        else $display("[FAIL] push_m: Stopwatch failed to start");

        // Test push_m to pause stopwatch
        push_m = 1;
        #10;
        push_m = 0;
        #20;
        if (uut.stopwatch_state == `S3 && led == 1) $display("[SUCCESS] push_m: Stopwatch paused correctly");
        else $display("[FAIL] push_m: Stopwatch failed to pause");

        // Test SPDT3 OFF to finish
        SPDT3 = 0;
        #20;
        if (finish3 == 1 && led == 0) $display("[SUCCESS] SPDT3 OFF: Stopwatch finished correctly");
        else $display("[FAIL] SPDT3 OFF: Stopwatch finish failed");

        $stop;
    end

endmodule
