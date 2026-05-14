`timescale 1 ns / 1 ps
module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2-1:0] count2,
    output logic [W1-1:0] count1,
    output logic [W0-1:0] count0
);

  logic n1_enable;
  logic n2_enable;

  assign n1_enable = (count0 == W0'(N0 - 1) && enable) ? '1 : '0;
  assign n2_enable = (count1 == W1'(N1 - 1) && n1_enable) ? '1 : '0;

  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) mod_n0 (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count0)
  );

  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) mod_n1 (
      .clk(clk),
      .rst(rst),
      .enable(n1_enable),
      .count(count1)
  );

  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) mod_n2 (
      .clk(clk),
      .rst(rst),
      .enable(n2_enable),
      .count(count2)
  );
endmodule
