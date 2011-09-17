//i2c_slave_tb.v - testbench for the i2c_slave module

module i2c_slave_tb;

reg clock;
reg dut_clock;
reg reset;

inout SDA;
inout SCL;

reg SDA_out;
reg SCL_out;

reg ack_from_dut;

i2c_slave dut(
         .clock(dut_clock),
         .reset(reset),
         .SDA(SDA),
         .SCL(SCL));

pullup(SDA);
pullup(SCL);

assign SDA = SDA_out ? 1'bz : 1'b0;
assign SCL = SCL_out ? 1'bz : 1'b0;
         
initial begin
   clock = 0;
   forever #50 clock = ~clock;
end

initial begin
   dut_clock = 0;
   forever #7 dut_clock = ~dut_clock;
end

initial begin
   $dumpfile("test.vcd");
   $dumpvars(0,i2c_slave_tb);
end        

initial begin
   reset_dut();
   #1 test_lines_idle_high();
   #1 test_ack_on_address();
   #1 test_read_byte();
   #50 $finish;
end   
   
task test_read_byte;
begin
   reset_dut();
   send_start();
   send_address_and_mode({7'h56,1'b1});   
   get_ack();
end
endtask   
   
task test_ack_on_address;
begin
   reset_dut();
   send_start();
   send_address_and_mode({7'h56,1'b0});
   get_ack();
   if(ack_from_dut != 0) begin
      $display("Test Failed: ack_on_address()-%g", $time);
      $finish;
   end
end
endtask

task test_lines_idle_high;
begin
   reset_dut();
   if(SCL == 0 || SDA == 0) begin
      $display("Test Failed: lines_idle_high() -%g",$time);
      $finish;
   end
end
endtask

task get_ack;
begin
   ack_from_dut = 1;
   SDA_out = 1;
   @(posedge clock);
   SCL_out = 1;
   ack_from_dut = SDA;
   @(negedge clock);
   SCL_out = 0;
end
endtask

task send_start;
begin
   @(posedge clock);
   SDA_out = 0;
   @(negedge clock);
   SCL_out = 0;   
end
endtask

task send_address_and_mode;
input [7:0] address_and_mode;
integer x;
begin
   for (x=0; x<8; x=x+1) begin
      send_bit(address_and_mode[7]);
      address_and_mode = address_and_mode << 1;
   end   
end
endtask

   
task send_bit;
input bit_to_send;
begin
   #20 SDA_out = bit_to_send;
   @(posedge clock);
   SCL_out = 1;
   @(negedge clock);
   SCL_out = 0;
end
endtask

task reset_dut;
begin
   SDA_out = 1;
   SCL_out = 1;
   reset = 0;
   @(posedge clock);
   reset = 1;
   @(posedge clock);
   reset = 0;
end
endtask

endmodule 
  
