// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_brightness_wrapper #(
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

  // App blanking signals
  logic app_blank_h;
  logic app_blank_m;
  logic app_blank_s;

  user_top #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(app_blank_h),
      .blank_minutes(app_blank_m),
      .blank_seconds(app_blank_s)
  );


  // 1 ms PWM generator
  localparam int PwmPeriod = CYCLES_PER_SECOND / 1000;
  localparam int Width = $clog2(PwmPeriod);

  logic [Width-1:0] pwm_count;

  mod_n_counter #(
      .N(PwmPeriod),
      .WIDTH(Width)
  ) u_pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );

  // Duty cycle selection
  logic pwm_blank;

  always_comb begin
    case (sw[9:8])

      // 12.5%
      2'b00: pwm_blank = !(32'(pwm_count) < PwmPeriod / 8);

      // 25%
      2'b01: pwm_blank = !(32'(pwm_count) < PwmPeriod / 4);

      // 50%
      2'b11: pwm_blank = !(32'(pwm_count) < PwmPeriod / 2);

      // 100%
      2'b10: pwm_blank = 1'b0;

      default: pwm_blank = 1'b0;
    endcase
  end

  // Final blanking
  assign blank_hours   = app_blank_h || pwm_blank;
  assign blank_minutes = app_blank_m || pwm_blank;
  assign blank_seconds = app_blank_s || pwm_blank;

endmodule
