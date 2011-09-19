//decoder_tb.v  

module encoder_tb;
reg clock;
reg reset;

wire is_cw;
wire is_ccw;

encoder dut(
      .clock(clock),
      .reset(reset),
      .is_cw(is_cw),
      .is_ccw(is_ccw));


reg tb_clock;

initial begin
   tb_clock = 0;
   forever #50 tb_clock = ~tb_clock;
end

initial begin
   clock = 0;
   forever #9 clock = ~clock;
end

initial begin
   reset_dut();
   #1 test_outputs_zero_on_reset();
   #100 $finish;
end

task test_outputs_zero_on_reset;
begin
   reset_dut();
   if ( is_cw == 1 || is_ccw == 1) begin
      $display("Test Failed: outputs_zero_on_reset()");
      $finish;
   end
end
endtask

task reset_dut;
begin
   reset = 0;
   @(posedge tb_clock);
   reset = 1;
   @(posedge tb_clock);
   reset = 0;
end
endtask

endmodule
