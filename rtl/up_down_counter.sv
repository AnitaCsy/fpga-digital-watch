`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,  // low -> count does not change
    input logic up,  // high -> count increments 0-MAX, low -> count decrements MAX-0
    output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk) if (enable) count <= next_count;

  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  logic [WIDTH-1:0] next_count;
  initial count = WIDTH'(0);

  always_comb begin
    if (up) next_count = count == Max ? '0 : count + WIDTH'(1);
    else next_count = count == 0 ? Max : count - WIDTH'(1);
  end

endmodule
