//shift_reg.v - Basic shift register 

module shift_reg (clock, reset, status);
   input clock;
   input reset;

   output status;
   reg status;

   always @ (posedge clock)
   begin
      if (reset) begin
         status <= 1;
      end
      else begin
         status <= 1;
      end
   end
endmodule

/*
module counter(out, clk, reset);

  parameter WIDTH = 8;

  output [WIDTH-1 : 0] out;
  input 	       clk, reset;

  reg [WIDTH-1 : 0]   out;
  wire 	       clk, reset;

  always @(posedge clk)
    out <= out + 1;

  always @reset
    if (reset)
      assign out = 0;
    else
      deassign out;

endmodule*/
