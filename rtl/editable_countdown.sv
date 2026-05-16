`timescale 1 ns / 1 ps
module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out
);

  logic up;
  logic enable;
  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_up_down_counter (
      .clk(clk),
      .rst(clr),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec && !clr;
  wire dec_event = edit_mode && dec && !inc && !clr;
  wire tick_event = !edit_mode && tick && !clr;

  assign up = inc_event;
  assign enable = tick_event || inc_event || dec_event;

  assign borrow_out = tick_event && (count == 0);

endmodule
