`timescale 1ns / 1ps
module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  localparam int CountMax = HOLD_CYCLES;
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;
  logic [CountWidth-1:0] count;

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) mod_n (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  logic held_reg = 1'b0;

  always_ff @(posedge clk) begin

    if (!button) begin
      held_reg <= 1'b0;
    end else if (count == CountWidth'(CountMax - 1)) begin
      held_reg <= 1'b1;
    end
  end

  assign held = held_reg;
  assign count_rst = !button;
  assign count_enable = button && !held_reg;

endmodule
