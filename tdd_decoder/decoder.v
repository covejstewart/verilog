//decoder.v

module encoder(clock, reset, is_cw, is_ccw);
   input clock;
   input reset;

   output is_cw;
   output is_ccw;

   reg is_cw;
   reg is_ccw;

   always @(posedge clock)
   begin
      if(reset) begin
         is_cw <= 0;
         is_ccw <= 0;
      end
      begin
      
      end      
   end
endmodule
