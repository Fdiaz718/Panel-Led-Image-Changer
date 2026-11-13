`timescale 1ns / 1ps

module tb;

    reg clk;
    reg rst_n;

    wire       r0, g0, b0;
    wire       r1, g1, b1;
    wire [4:0] addr;
    wire       clk_out;
    wire       latch;
    wire       oe;

    cpuFSM uut (
        .clk     (clk),
        .rst_n   (rst_n),
        .r0      (r0),
        .g0      (g0),
        .b0      (b0),
        .r1      (r1),
        .g1      (g1),
        .b1      (b1),
        .addr    (addr),
        .clk_out (clk_out),
        .latch   (latch),
        .oe      (oe)
    );

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("./build/tb.vcd");
        $dumpvars(0, tb);

        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;

        #600000;

        $display("Simulación finalizada correctamente.");
        $finish;
    end

endmodule
