`timescale 1 ns / 1ps
module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  logic [WIDTH-1:0] prev_d = '0;

  always_ff @(posedge clk) begin
    if (!hold) prev_d <= d;
  end

  always_comb begin
    if (!hold) q = d;
    else q = prev_d;
  end

endmodule
