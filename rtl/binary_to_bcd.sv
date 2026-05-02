`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,   // binary input, 0-99
    output logic [3:0] tens,  // decimal tens digit
    output logic [3:0] ones   // decimal ones digit
);

  assign tens = 4'(bin / 7'd10);
  assign ones = 4'(bin - 7'(10) * 7'(tens));

endmodule
