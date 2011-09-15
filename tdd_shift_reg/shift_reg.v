//shift_reg.v - The most Basic shift register.  Only shifts right, synchronous loading.

module shift_reg (clock, reset, load, d_in, d_out);
   input clock;
   input reset;
   input load;
   input [7:0] d_in;
   output [7:0] d_out;

   reg [7:0] d_out;

   always @ (posedge clock)
   begin
      if (reset) begin
         d_out <= 8'h00;
      end
      else begin
         if (load) begin
            d_out <= d_in;
         end
         else begin
            d_out <= (d_out >> 1);
         end
      end
   end
endmodule


