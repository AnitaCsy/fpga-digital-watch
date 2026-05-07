`timescale 1ns / 1ps
module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  localparam int Width = $clog2(PERIOD_CYCLES);
  localparam logic [Width:0] DutyCycles = (Width + 1)'(DUTY_CYCLES);
  logic [Width-1:0] count;

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(Width)
  ) mod_n (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

  assign pwm_out = ((Width + 1)'(count) < DutyCycles);

endmodule
