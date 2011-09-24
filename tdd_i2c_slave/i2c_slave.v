//module i2c_slave.v

module i2c_slave(clock, reset, SDA, SCL);
   input clock;
   input reset;

   inout SDA;
   inout SCL;

   reg SDA_out;
   reg SCL_out;

   parameter [6:0] my_address = 7'h11;
   parameter [7:0] data_buffer_init = 8'h33;

   parameter size = 4;
   parameter [size:0]
         IDLE      = 0,
         START     = 1,
         ADDRESS   = 2,
         MODE      = 3,
         START_ACK = 4,
         END_ACK   = 5,
         TX_DATA   = 6,
         GET_ACK   = 7,
         RX_DATA   = 8;
   
   reg [size:0] state;
   reg [7:0] data_buffer;
   reg [7:0] shift_reg;   
   reg SDA_sync;
   reg SCL_sync;
   reg SDA_last;
   reg SCL_last;
   reg [7:0] address;
   reg [4:0] cnt;
   reg start_detect;
   reg stop_detect;

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
         start_detect <= 0;
         stop_detect <= 0;
         data_buffer <= data_buffer_init;
         address = 0;
         cnt = 0;
      end
      else begin
         if(SCL_sync && SCL_last) begin
            if(SDA_sync && !SDA_last) begin
               stop_detect <= 1;            
            end
            else if(!SDA_sync && SDA_last) begin
               start_detect <= 1;
            end         
         end
         else begin
            start_detect <= 0;
            stop_detect <= 0;
         end
         case(state)
            IDLE: begin
               //look for a falling SDA while SCL is high
               if(start_detect) begin
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
                     state <= START_ACK;
                  end
                  else begin
                     cnt = cnt + 1;
                  end
               end
            end
            START_ACK: begin
               //on falling edge of SCL, ACK/NACK
               //refactor: pull address match up into ADDRESS
               if(!SCL_sync && SCL_last) begin
                  if(address[7:1] == my_address) begin
                     SDA_out <= 0;  //ACK
                     state <= END_ACK;
                  end
                  else begin
                     SDA_out <= 1;  //NACK
                     state <= IDLE;
                  end
               end   
            end
            END_ACK: begin
               //we have acked or rx'd an ack and now need to branch to read or write
               if(!SCL_sync && SCL_last) begin
                  cnt = 0;
                  if(address[0] == 1) begin
                     //This needs to be changed to supply meaningful data.
                     data_buffer <= data_buffer_init;
                     state <= TX_DATA;
                  end
                  else begin
                     state <= RX_DATA;
                  end
               end
            end
            TX_DATA: begin
               //send the data from the data buffer
               SDA_out <= data_buffer[7];
               if(!SCL_sync && SCL_last) begin
                  if(cnt == 7) begin
                     cnt = 0;
                     SDA_out <= 1;
                     state <= GET_ACK;
                  end
                  else begin
                     data_buffer <= data_buffer << 1;
                     cnt = cnt + 1;
                  end
               end
            end
            RX_DATA: begin
               //load data into the data buffer
               SDA_out <= 1;
               if(SCL_sync && !SCL_last) begin
                  data_buffer <= data_buffer << 1;
                  data_buffer[0] <= SDA_sync;
                  if(cnt == 7) begin
                     cnt = 0;
                     state <= START_ACK;   
                  end
                  else begin
                     cnt = cnt + 1;
                  end
               end
               if(stop_detect) begin
                  state <= IDLE;
               end          
            end
            GET_ACK: begin
               if(SCL_sync && !SCL_last) begin
                  if(SDA_sync) begin
                     state <= IDLE;
                  end
                  else begin
                     state <= END_ACK;
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
