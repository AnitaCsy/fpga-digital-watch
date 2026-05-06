`timescale 1ns / 1ps
module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);
  localparam logic [WIDTH-1:0] N_1 = WIDTH'(N - 1);
  initial count = WIDTH'(0);
  logic [WIDTH-1:0] next_count;

  always_ff @(posedge clk)
    if (rst) count <= '0;
    else if (enable) count <= next_count;

  always_comb begin
    if (enable) next_count = count == N_1 ? '0 : count + WIDTH'(1);
    else next_count = count;
  end

endmodule
