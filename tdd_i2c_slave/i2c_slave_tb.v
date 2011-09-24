//i2c_slave_tb.v - testbench for the i2c_slave module

module i2c_slave_tb;

reg clock;
reg dut_clock;
reg reset;

inout SDA;
inout SCL;

reg SDA_out;
reg SCL_out;
reg [7:0] data_from_dut;
reg ack_from_dut;

parameter [6:0] dut_address = 7'h56;
parameter [7:0] dut_buffer_init = 8'hA5;
parameter [7:0] data_to_send = 8'h37;
parameter WRITE = 1'b0, READ = 1'b1;

i2c_slave dut(
         .clock(dut_clock),
         .reset(reset),
         .SDA(SDA),
         .SCL(SCL));

defparam dut.my_address = dut_address;
defparam dut.data_buffer_init = dut_buffer_init;

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
   #1 test_read_single_byte();
   #1 test_write_single_byte();
   #1 test_write_stop_read_byte();   
   #50 $finish;
end   

task test_write_stop_read_byte;
begin
   reset_dut();
   send_start();
   send_address_and_mode({dut_address, WRITE});
   get_ack();
   send_data_byte(data_to_send);
   get_ack();
   if(ack_from_dut != 0) begin
      $display("Test Failed: write_read_byte-ack()-%g", $time);
      $finish;
   end
   send_stop();
   send_start();
   send_address_and_mode({dut_address, READ});   
   get_ack();
   get_data_byte();
   if(data_from_dut != dut_buffer_init) begin
      $display("Test Failed: write_stop_read_byte-data()-%g", $time);
      $finish;
   end   
end
endtask


task test_write_single_byte;
begin
   reset_dut();
   send_start();
   send_address_and_mode({dut_address, WRITE});
   get_ack();
   send_data_byte(data_to_send);
   get_ack();
   if(ack_from_dut != 0) begin
      $display("Test Failed: write_single_byte()-%g", $time);
      $finish;
   end
end
endtask

task test_read_single_byte;
begin
   data_from_dut = 0;
   reset_dut();
   send_start();
   send_address_and_mode({dut_address, READ});   
   get_ack();
   get_data_byte();
   if(data_from_dut != dut_buffer_init) begin
      $display("Test Failed: read_single_byte()-%g", $time);
      $finish;
   end
end
endtask   

task test_ack_on_address;
begin
   reset_dut();
   send_start();
   send_address_and_mode({dut_address, WRITE});
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

task get_data_byte;
integer idx;
begin
   data_from_dut = 0;
   for(idx=0;idx<8;idx=idx+1) begin
      @(posedge clock);
      SCL_out = 1;
      data_from_dut = data_from_dut << 1;
      data_from_dut[0] = SDA;
      @(negedge clock);
      SCL_out = 0;
   end
end
endtask

task send_stop;
begin
   SDA_out = 0;
   @(posedge clock);
   SCL_out = 1;
   @(posedge clock);
   SDA_out = 1;
end
endtask

task send_ack;
begin
   SDA_out = 0;
   @(posedge clock);
   SCL_out = 1;
   @(negedge clock);
   SCL_out = 0;
   SDA_out = 1;
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

task send_data_byte;
input [7:0] data;
integer x;
begin
   for (x=0; x<8; x=x+1) begin
      send_bit(data[7]);
      data = data << 1;
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
   reset = 1;
   @(posedge clock);
   @(posedge clock);
   reset = 0;
end
endtask

endmodule 
  
