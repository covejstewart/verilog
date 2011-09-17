//shift_reg_tb.v - test bench for shift_reg

module shift_reg_tb;
reg clock;
reg reset;
reg load;

reg [7:0] data_in;
wire [7:0] dut_data_out;

integer errors;

shift_reg dut(
         .clock(clock), 
         .reset(reset), 
         .load(load),
         .d_in(data_in),
         .d_out(dut_data_out));

//setup a free running clock
initial begin
   clock = 0;   
   forever #50 clock = ~clock;
end

initial begin
   $dumpfile("test.vcd");
   $dumpvars(0,shift_reg_tb);
end


//Execute the tests here
initial begin
//   $monitor("%g,din=%h,dout=%h,reset=%b,load=%b",$time,data_in,dut_data_out,reset,load);
   data_in = 8'h00;
   reset = 0;
   load = 0;
   #1 test_data_is_zero_on_reset();
   #1 test_data_loads_with_load(8'h55);
   #1 test_data_shifts_right(8'hcc);
   #1 test_data_shifts_to_zero(8'hff);
   #100 $finish;

end

task test_data_shifts_to_zero;
   input [7:0] test_val;
   begin
      dut_reset();
      dut_load_data(test_val);
      @(negedge clock);
      @(negedge clock);
      @(negedge clock);
      @(negedge clock);
      @(negedge clock);
      @(negedge clock);
      @(negedge clock);
      @(negedge clock);
      if(dut_data_out != 8'h00) begin
         $display("Test Failed: test_data_shifts_to_zero() -%g",$time);
         $finish;
      end
   end
endtask

task test_data_shifts_right;
   input [7:0] test_val;
   begin
      dut_reset();
      dut_load_data(test_val);
      @(negedge clock);
      if(dut_data_out != test_val>>1) begin
         $display("Test Failed: test_data_shifts_right() -%g",$time);
         $finish;
      end
   end
endtask

task test_data_loads_with_load;
   input [7:0] test_val;
   begin
      dut_reset();
      dut_load_data(test_val);
      if(dut_data_out != test_val) begin
         $display("Test Failed: test_data_loads_with_load()");
         $finish;         
      end
   end
endtask

task test_data_is_zero_on_reset;
   begin
      dut_reset();
      @(negedge clock);
      if (dut_data_out != 8'h00) begin
         $display("Test Failed: test_data_is_zero_on_reset()");
         $finish;
      end
   end
endtask

task dut_load_data;
   input [7:0] value_to_load;
   begin
      data_in = value_to_load;
      load = 0;
      @(negedge clock);
      load = 1;
      @(negedge clock);
      load = 0;
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

