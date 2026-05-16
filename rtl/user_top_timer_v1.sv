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

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
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

  // Unused
  assign led = 10'b0;

  // ------------------
  // FSM
  // -------------------

  // state
  localparam logic [1:0] STOPPED = 2'b00;
  localparam logic [1:0] SET = 2'b01;
  localparam logic [1:0] RUNNING = 2'b10;

  logic [1:0] state, next_state;
  initial state = STOPPED;

  logic start_stop_pulse;
  rising_edge_detector u_run_stop_detector (
      .clk(clk),
      .sig_in(button[0]),
      .rise(start_stop_pulse)
  );

  wire time_is_zero = (hours == '0 && minutes == '0 && seconds == '0);
  wire edit_active = (mode_enable != 3'b000);
  wire timer_done = seconds_borrow_out && minutes_borrow_out && hours_borrow_out;

  always_comb begin
    next_state = state;

    if (time_is_zero) next_state = STOPPED;
    else begin
      case (state)
        STOPPED: begin
          if (edit_active) next_state = SET;
          else if (start_stop_pulse) next_state = RUNNING;
        end

        RUNNING: begin
          if (edit_active || start_stop_pulse || timer_done) next_state = STOPPED;
        end

        SET: begin
          if (!edit_active) next_state = STOPPED;
        end

        default: begin
          next_state = STOPPED;
        end
      endcase
    end
  end

  always_ff @(posedge clk) begin
    state <= next_state;
  end

  // Flag
  logic running;
  assign running = (state == RUNNING);

  // ------------------
  // Counter
  // -------------------

  // Seconds
  logic seconds_rst;
  logic seconds_borrow_out;
  assign seconds_rst = 1'b0;

  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds_count (
      .clk(clk),
      .clr(seconds_rst),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(seconds_borrow_out)
  );

  // Minutes
  logic minutes_rst;
  logic minutes_borrow_out;
  assign minutes_rst = 1'b0;

  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes_count (
      .clk(clk),
      .clr(minutes_rst),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(minutes_borrow_out)
  );

  // Hours
  logic hours_rst;
  logic hours_borrow_out;
  assign hours_rst = 1'b0;

  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours_count (
      .clk(clk),
      .clr(hours_rst),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      .borrow_out(hours_borrow_out)
  );

  logic run;
  assign run = running;

  // fist decrement occurs not snooer than one second after pressed
  logic seconds_tick_raw;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (run),
      .tick(seconds_tick_raw)
  );

  assign seconds_tick = seconds_tick_raw && run;
  assign minutes_tick = seconds_borrow_out ? '1 : '0;
  assign hours_tick   = minutes_borrow_out ? '1 : '0;

  // Zero-extend counter values to display outputs
  assign hours_disp   = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

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

`ifdef FORMAL
  assign probe_running = run;
  assign probe_mode_enable = mode_enable;
`endif
endmodule
