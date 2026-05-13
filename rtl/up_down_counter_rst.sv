`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);

  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  logic [WIDTH-1:0] next_count;
  initial count = '0;

  always_ff @(posedge clk) begin
    if (rst) count <= '0;
    else if (enable) count <= next_count;
  end

  always_comb begin
    if (up) next_count = count == Max ? '0 : count + WIDTH'(1);
    else next_count = count == 0 ? Max : count - WIDTH'(1);
  end

endmodule
