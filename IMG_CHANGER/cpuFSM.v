module cpuFSM (
    input clk,
    input wire rst_n,
    output r0,
    g0,
    b0,
    r1,
    g1,
    b1,
    clk_out,
    latch,
    oe,
    output [4:0] addr
);

  reg sel_hub75 = 0;
  reg wstrb = 0;
  reg [31:0] wdata = 0;
  reg [19:0] word_addr = 0;

  hub75 uut (
      .clk(clk),
      .rst(!rst_n),
      .sel_hub75(sel_hub75),
      .wstrb(wstrb),
      .wdata(wdata),
      .word_addr(word_addr),
      .r0(r0),
      .g0(g0),
      .b0(b0),
      .r1(r1),
      .g1(g1),
      .b1(b1),
      .addr(addr),
      .clk_out(clk_out),
      .latch(latch),
      .oe(oe)
  );

  // Simple state Machine
  reg [ 1:0] state = 0;
  reg [19:0] pixel_counter = 0;

  always @(posedge clk) begin
    case (state)
      0: begin
        sel_hub75 <= 1;
        wstrb <= 1;
        word_addr <= pixel_counter;
        wdata <= 32'h00FF0000;
        state <= 1;
      end
      1: begin
        wstrb <= 0;
        sel_hub75 <= 0;
        if (pixel_counter < 4096) begin
          pixel_counter <= pixel_counter + 1;
          state <= 0;
        end else begin
          state <= 2;
        end
      end
      2: begin
        sel_hub75 <= 0;
        wstrb <= 0;
      end
      default: state <= 2;
    endcase
  end

endmodule
