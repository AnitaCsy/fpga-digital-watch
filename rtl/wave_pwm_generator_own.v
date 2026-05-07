`timescale 1ns / 1ps
module wave_pwm_generator_own;
  reg  clk = 0;
  reg  rst = 0;
  wire pwm_out;

  pwm_generator #(
      .PERIOD_CYCLES(4),
      .DUTY_CYCLES  (4)
  ) dut (
      .clk    (clk),
      .rst    (rst),
      .pwm_out(pwm_out)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_pwm_generator_own.vcd");
    $dumpvars(0, wave_pwm_generator_own);

    // Run freely for two full periods (2 * 10 cycles * 10 ns = 200 ns)
    #200;
    // Assert rst mid-period to demonstrate synchronous reset
    rst = 1;
    #10;
    rst = 0;
    // Run for two more full periods then finish
    #200 $finish;
  end
endmodule
