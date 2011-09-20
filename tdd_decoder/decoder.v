//decoder.v

module decoder(clock, reset, A, B, is_cw, is_ccw, omega);
   input clock;
   input reset;
   input A;
   input B;

   output is_cw;
   output is_ccw;
   output [7:0] omega;
   
   reg is_cw;
   reg is_ccw;
   reg [7:0] omega;
   
   reg A_sync;
   reg B_sync;
   reg A_last;
   reg B_last;

   reg [7:0] cnt;

   always @(posedge clock)
   begin
      if(reset) begin
         is_cw <= 0;
         is_ccw <= 0;
         omega <= 0;
         
         A_sync <= 0;
         B_sync <= 0;
         A_last <= 0;
         B_last <= 0;
         cnt <= 0;
      end
      else begin
         if (A_sync & !A_last) begin
            if( B_sync) begin
               is_cw  <= 0;
               is_ccw <= 1;
            end
            else begin
               is_cw  <= 1;
               is_ccw <= 0;
            end
            omega <= cnt;
            cnt <= 0;
         end
         else begin
            cnt <= cnt + 1;
         end
         A_sync <= A;
         B_sync <= B;
         A_last <= A_sync;
         B_last <= B_sync;
      end      
   end
endmodule
