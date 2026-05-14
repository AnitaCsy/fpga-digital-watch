`timescale 1 ns / 1 ps
module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,  // takes priority over enable
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundredths of a second
);

  logic centiseconds_tick;
  logic centiseconds_enable;

  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),

      // output port widths
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_cascade_counter (
      .clk(clk),
      .rst(rst),
      .enable(centiseconds_enable),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

  assign centiseconds_enable = centiseconds_tick && enable;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_rate_generator (
      .clk (clk),
      .run (enable && !rst),
      .tick(centiseconds_tick)
  );

endmodule
