//tb_shift_reg.v - test bench for shift_reg

module shift_reg_tb;
reg clock;
reg reset;

wire status;

integer errors;

shift_reg dut(
         .clock(clock), 
         .reset(reset), 
         .status(status));

//setup a free running clock
initial begin
   clock = 0;   
   forever #50 clock = ~clock;
end

//Execute the tests here
initial begin
   reset = 0;
   #1 status_is_zero_on_reset();
   #100 $finish;
end

task status_is_zero_on_reset;
   begin
      @(posedge clock);   
      reset = 1;
      @(posedge clock);
      if (status != 0) begin
         $display("%g Test Failed: status_is_zero_on_reset()",$time);
         $finish;
      end
   end
endtask
endmodule

