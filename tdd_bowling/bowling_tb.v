//bowling_tb.v self checking testbench for the bowling KATA
module bowling_tb;
reg clock;
reg reset;
reg roll;
reg calculate_score;
reg[3:0] pin_count;

wire [8:0]dut_score;

bowling dut(
      .clock(clock),
      .reset(reset),
      .calculate_score(calculate_score),
      .pin_count(pin_count),
      .roll(roll),
      .score(dut_score));

initial begin
      clock = 0;
      forever #50 clock = ~clock;
end

initial begin
   $monitor("%g:reset-%b,roll-%b,calc-%b,pins-%d,score-%d",$time,reset,roll,calculate_score, pin_count,dut_score);
   reset = 0;
   roll = 0;
   pin_count = 0;
   calculate_score = 0;
   #1 test_outputs_are_zero_on_reset();
   #1 test_score_single_throw();
   #1 test_score_single_spare();
   #1 test_score_single_strike();
   #1 test_perfect_game();
   #100 $finish;
end

task test_perfect_game;
   begin
      dut_reset();
      roll_many(12,10);
      get_score();
      if(dut_score != 300) begin
         $display("\nTest Failed: test_perfect_game\n");
         $finish;
      end   
   end
endtask

task test_score_single_strike;
   begin
      dut_reset();
      roll_once(10);
      roll_once(3);
      roll_once(4);
      roll_many(16,0);
      get_score();
      if(dut_score != 24) begin
         $display("\nTest Failed: test_score_single_strike\n");
         $finish;
      end
   end
endtask

task test_score_single_spare;
   begin
      dut_reset();
      roll_once(5);
      roll_once(5);
      roll_once(5);
      roll_many(17,0);
      get_score();
      if(dut_score != 20) begin
         $display("\nTest Failed: test_score_single_spare\n");
         $finish;
      end
   end
endtask

task test_score_single_throw;
   begin
      dut_reset();
      roll_once(8);
      roll_many(19,0);
      get_score();
      if(dut_score != 8) begin
         $display("\nTest Failed: test_score_single_throw\n");
         $finish;
      end
   end
endtask
      
task test_outputs_are_zero_on_reset;
   begin
      dut_reset();
      get_score();
      if(dut_score != 0) begin
         $display("\nTest Failed: test_outputs_are_zero_on_reset\n");
         $finish;
      end
   end
endtask

task get_score;
   integer x;   
   begin
      calculate_score = 1;
      for(x = 0; x < 10; x = x+1) begin
         @(negedge clock);
      end
      calculate_score = 0;
   end
endtask

task roll_many;
   input [4:0] throws;
   input [3:0] num_pins;
   integer x;
   begin
      for (x = 0; x < throws; x = x+1) begin
         roll_once(num_pins);
      end
   end
endtask

task roll_once;
   input [3:0] num_pins;
   begin
      pin_count = num_pins;
      roll = 0;
      @(negedge clock);
      roll = 1;
      @(negedge clock);
      pin_count = 0;
      roll = 0;
   end   
endtask
  
task dut_reset;
   begin
      reset = 0;
      @(negedge clock);
      reset = 1;
      @(negedge clock);
      reset = 0;      
   end
endtask

endmodule
