`timescale 1ns / 1ps
module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    parameter it  REPEAT_CYCLES = 5_000_000
) (
    input logic clk,
    input logic button,
    input logic pulse
);

  logic rise;
  logic held;
  logic pulse_train;

  assign pulse = rise | (button & pulse_train);

endmodule
