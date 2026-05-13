`timescale 1ns / 1ps

module user_top_watch_v3 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  // ------------------
  // Core Functionality
  // -------------------

  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),  // count increments on tick when edit_mode is low
      .edit_mode(seconds_edit),
      .inc(seconds_inc),  // count increments by one when edit_mode is high
      .dec(seconds_dec),  // count decrements by one when edit_mode is high
      .count(seconds)
  );

  // Minutes
  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),  // count increments on tick when edit_mode is low
      .edit_mode(minutes_edit),
      .inc(minutes_inc),  // count increments by one when edit_mode is high
      .dec(minutes_dec),  // count decrements by one when edit_mode is high
      .count(minutes)
  );

  // Hours
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;
  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),  // count increments on tick when edit_mode is low
      .edit_mode(hours_edit),
      .inc(hours_inc),  // count increments by one when edit_mode is high
      .dec(hours_dec),  // count decrements by one when edit_mode is high
      .count(hours)
  );

  // Derive 1 Hz tick from system clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (1'b1),
      .tick(seconds_tick)
  );

  assign minutes_tick = (seconds == 'd59 && seconds_tick) ? '1 : '0;
  assign hours_tick = (minutes == 'd59 && minutes_tick) ? '1 : '0;

  // Zero-extend counter values to display outputs
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // Unused
  assign led = 10'b0;

  // ------------------
  // Mode Selection
  // -------------------

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 10)
  ) u_pwm (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );

  logic dec;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec (
      .clk(clk),
      .button(button[0]),
      .pulse(dec)
  );

  logic inc;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc (
      .clk(clk),
      .button(button[1]),
      .pulse(inc)
  );

  // edit function
  assign seconds_edit = (mode_enable == 3'b001);
  assign minutes_edit = (mode_enable == 3'b010);
  assign hours_edit = (mode_enable == 3'b100);
  assign seconds_inc = (seconds_edit && inc);
  assign seconds_dec = (seconds_edit && dec);
  assign minutes_inc = (minutes_edit && inc);
  assign minutes_dec = (minutes_edit && dec);
  assign hours_inc = (hours_edit && inc);
  assign hours_dec = (hours_edit && dec);

  //flash
  assign blank_seconds = (seconds_edit && pwm_out);
  assign blank_minutes = (minutes_edit && pwm_out);
  assign blank_hours = (hours_edit && pwm_out);

endmodule
