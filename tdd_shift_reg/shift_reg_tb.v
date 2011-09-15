//tb_shift_reg.v - test bench for shift_reg

module tb_shift_reg;
   reg clock;
   reg reset;
   reg status;

   integer errors;

   shift_reg dut(
            .clock(clock), 
            .reset(reset), 
            .status(status));

   task status_is_zero_on_reset;
      
      @(posedge clk);   
      reset <= 1;
      @(posedge clk);
      if status != 0 begin
         $display("%g Error: status_is_zero_on_reset()",$time);
      end
   endtask

   //setup a free running clock
   inital begin
      clock = 0;   
      forever #50 clock = ~clock;
   end

   //Execute the tests here
   initial begin
      #50;
      status_is_zero_on_reset();
   end
endmodule

