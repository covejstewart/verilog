//module i2c_slave.v

module i2c_slave(clock, reset, SDA, SCL);
   input clock;
   input reset;

   inout SDA;
   inout SCL;

   reg SDA_out;
   reg SCL_out;

   parameter size = 4;
   parameter [size:0]
         IDLE     = 0,
         START    = 1,
         ADDRESS  = 2,
         MODE     = 3,
         ACK      = 4;
   
   parameter [6:0] my_address = 7'h56;
   
   reg [size:0] state;   
   reg SDA_sync;
   reg SCL_sync;
   reg SDA_last;
   reg SCL_last;
   reg [7:0] address;
   reg [4:0] cnt;
   assign SDA = SDA_out ? 1'bz : 1'b0;
   assign SCL = SCL_out ? 1'bz : 1'b0;

   always @ (posedge clock) 
   begin
      if(reset) begin
         state <= IDLE;
         SDA_out <= 1;
         SCL_out <= 1;
         SDA_last <= 1;
         SCL_last <= 1;
         SCL_sync <= 1;
         SDA_sync <= 1;
         address = 0;
         cnt = 0;
      end
      else begin
         case(state)
            IDLE: begin
               //look for a falling SDA while SCL is high
               if(!SDA_sync && SDA_last && SCL_sync) begin
                  state <= START;
               end
               address = 0;
               cnt = 0;
               SDA_out <= 1;
               SCL_out <= 1;
            end
            START: begin
               //wait unti the falling edge of SCL to begin looking for addr bits
               if(!SCL_sync && SCL_last) begin
                  state <= ADDRESS;
               end
            end
            ADDRESS: begin
               //shift in the six address bits plus r/w bit
               if(SCL_sync && !SCL_last) begin
                  address = (address << 1);
                  address[0] = SDA_sync;
                  if(cnt == 7) begin
                     state <= ACK;
                  end
                  else begin
                     cnt = cnt + 1;
                  end
               end
            end
            ACK: begin
               //on falling edge of SCL, ACK/NACK
               if(address[7:1] == my_address) begin
               end
               else begin
                  state <= IDLE;
               end
               if(!SCL_sync && SCL_last) begin
                  if(address[7:1] == my_address) begin
                     SDA_out <= 0;  //ACK
                  end
                  else begin
                     SDA_out <= 1;  //NACK
                  end
               end 
            end
            default : state <= IDLE;
         endcase
         
         SDA_sync <= SDA;
         SCL_sync <= SCL;
         SDA_last <= SDA_sync;
         SCL_last <= SCL_sync;
      end
   end
endmodule
