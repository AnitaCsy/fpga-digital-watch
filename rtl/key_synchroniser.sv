`timescale 1 ns / 1 ps
module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,  // active_low, asychronous
    output logic [3:0] key_sync  // active_high, synchronous
);

  logic [3:0] ff_1, ff_2;
  logic [3:0] inv;

  initial ff_1 = '0;
  initial ff_2 = '0;

  assign inv = ~key_n;

  always_ff @(posedge clk) begin
    ff_1 <= inv;
    ff_2 <= ff_1;
  end

  assign key_sync = ff_2;

endmodule
