`timescale 1ns / 1ps

module traffic_light_tb;

    reg clk;
    reg reset;
    wire [2:0] NL, SL, EL, WL;

    traffic_light_controller DUT (
        .clk(clk),
        .reset(reset),
        .NL(NL),
        .SL(SL),
        .EL(EL),
        .WL(WL)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #20;
        reset = 0;
    end

    initial begin
        $display("Time(ns)\t NL\t SL\t EL\t WL");
        $monitor("%0dns\t %b\t %b\t %b\t %b",
                  $time, NL, SL, EL, WL);
    end

    initial begin
        #2000;
        $finish;
    end

endmodule
