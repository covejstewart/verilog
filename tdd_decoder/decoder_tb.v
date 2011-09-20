//decoder_tb.v  

module decoder_tb;
reg clock;
reg reset;
reg A;
reg B;

wire is_cw;
wire is_ccw;
wire [7:0] omega;

decoder dut(
      .clock(clock),
      .reset(reset),
      .A(A),
      .B(B),
      .is_cw(is_cw),
      .is_ccw(is_ccw),
      .omega(omega));

reg tb_clock;

parameter TB_CLOCK = 100;
parameter DUT_CLOCK = 5;
 
initial begin
   $dumpfile("test.vcd");
   $dumpvars(0,decoder_tb);
end        

initial begin
   tb_clock = 0;
   forever #TB_CLOCK tb_clock = ~tb_clock;
end

initial begin
   clock = 0;
   forever #DUT_CLOCK clock = ~clock;
end

initial begin
   reset_dut();
   #1 test_outputs_zero_on_reset();
   #1 test_clockwise_input();
   #1 test_counter_clockwise_input();
   #1 test_calculate_velocity();
   #1 test_switch_directions();
   #100 $finish;
end

task test_switch_directions;
begin
   reset_dut();
   drive_inputs_counter_clockwise();
   drive_inputs_counter_clockwise();
   drive_inputs_clockwise();
   drive_inputs_clockwise();
   if( !is_cw || is_ccw) begin
      $display("Test Failed: switch_directions()");
      $finish;
   end
end
endtask   

task test_calculate_velocity;
integer compare;
begin
   compare = (4 * 2 * TB_CLOCK) / (2 * DUT_CLOCK) - 1;
   reset_dut();
   drive_inputs_counter_clockwise();
   drive_inputs_counter_clockwise();
   drive_inputs_counter_clockwise();
   drive_inputs_counter_clockwise();
   if(omega <= compare - 1 || omega >= compare + 1) begin
      $display("Test Failed: calculate_velocity()");
      $finish;
   end
end
endtask

task test_counter_clockwise_input;
begin
   reset_dut();
   drive_inputs_counter_clockwise();
   drive_inputs_counter_clockwise();
   if( is_cw || !is_ccw) begin
      $display("Test Failed: counter_clockwise_input()");
      $finish;
   end
end
endtask   

task test_clockwise_input;
begin
   reset_dut();
   drive_inputs_clockwise();
   drive_inputs_clockwise();
   if( !is_cw || is_ccw) begin
      $display("Test Failed: clockwise_input()");
      $finish;
   end
end
endtask

task test_outputs_zero_on_reset;
begin
   reset_dut();
   if ( is_cw !== 0 || is_ccw !== 0 ) begin
      $display("Test Failed: outputs_zero_on_reset()");
      $finish;
   end
end
endtask

task drive_inputs_counter_clockwise;
begin
   @(posedge tb_clock);
   A = 0;
   B = 0;
   @(posedge tb_clock);
   A = 0;
   B = 1;
   @(posedge tb_clock);
   A = 1;
   B = 1;
   @(posedge tb_clock);
   A = 1;
   B = 0;
end
endtask

task drive_inputs_clockwise;
begin
   @(posedge tb_clock);
   A = 0;
   B = 0;
   @(posedge tb_clock);
   A = 1;
   B = 0;
   @(posedge tb_clock);
   A = 1;
   B = 1;
   @(posedge tb_clock);
   A = 0;
   B = 1;
end
endtask

task reset_dut;
begin
   A = 0;
   B = 0;
   reset = 0;
   @(posedge tb_clock);
   reset = 1;
   @(posedge tb_clock);
   reset = 0;
end
endtask

endmodule
