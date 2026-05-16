`timescale 1 ns / 1ps
module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  initial counter_rst = '0;
  initial counter_enable = '0;
  initial lap_hold = '0;

  logic next_counter_rst;
  logic next_counter_enable;
  logic next_lap_hold;

  wire  ss_only = rise_start_stop && !rise_lap;
  wire  lap_only = !rise_start_stop && rise_lap;

  assign next_counter_enable = ss_only ? ~counter_enable : counter_enable;

  assign next_lap_hold = (lap_only && counter_enable) ? ~lap_hold : lap_hold;

  assign next_counter_rst = lap_only && !counter_enable && !lap_hold;

  always_ff @(posedge clk) begin
    counter_rst    <= next_counter_rst;
    counter_enable <= next_counter_enable;
    lap_hold       <= next_lap_hold;
  end

endmodule
