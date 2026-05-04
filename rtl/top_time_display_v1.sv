`timescale 1ns / 1ps
module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  logic tick_50M, tick_1k, tick_25, tick_1, tick;
  logic [4:0] hours;
  logic [5:0] minutes, seconds;
  logic [3:0] seconds_tens, seconds_ones, minutes_tens, minutes_ones, hours_tens, hours_ones;

  always_comb begin
    case (SW[1:0])
      2'b00:   tick = tick_1;
      2'b01:   tick = tick_25;
      2'b10:   tick = tick_1k;
      2'b11:   tick = tick_50M;
      default: tick = tick_1;
    endcase
  end

  // initiasion
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / CYCLES_PER_SECOND)
  ) tk_50M (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_50M)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1_000)
  ) tk_1k (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1k)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) tk_25 (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_25)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) tk_1 (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1)
  );

  hms_counter #(
      .N_HOURS  (24),
      .N_MINUTES(60),
      .N_SECONDS(60),

      .W_HOURS  (5),
      .W_MINUTES(6),
      .W_SECONDS(6)
  ) hms_counter (
      .clk(CLOCK_50),
      .enable(tick),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  binary_to_bcd bcd_second (
      .bin({1'b0, seconds}),  // binary input, 0-99
      .tens(seconds_tens),  // decimal tens digit
      .ones(seconds_ones)  // decimal ones digit
  );

  binary_to_bcd bcd_minute (
      .bin({1'b0, minutes}),  // binary input, 0-99
      .tens(minutes_tens),  // decimal tens digit
      .ones(minutes_ones)  // decimal ones digit
  );

  binary_to_bcd bcd_hour (
      .bin({2'b0, hours}),  // binary input, 0-99
      .tens(hours_tens),  // decimal tens digit
      .ones(hours_ones)  // decimal ones digit
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) sec_ones (
      .digit(seconds_ones),  // Hexadecimal digit to display
      .blank(1'b0),
      .segments(HEX0)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) sec_tens (
      .digit(seconds_tens),  // Hexadecimal digit to display
      .blank(1'b0),
      .segments(HEX1)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) min_ones (
      .digit(minutes_ones),  // Hexadecimal digit to display
      .blank(1'b0),
      .segments(HEX2)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) min_tens (
      .digit(minutes_tens),  // Hexadecimal digit to display
      .blank(1'b0),
      .segments(HEX3)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) hr_ones (
      .digit(hours_ones),  // Hexadecimal digit to display
      .blank(1'b0),
      .segments(HEX4)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) hr_tens (
      .digit(hours_tens),  // Hexadecimal digit to display
      .blank(1'b0),
      .segments(HEX5)
  );

endmodule
