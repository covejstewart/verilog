//bowling.v module for the bowling KATA

module bowling(clock, reset, calculate_score, pin_count, roll, score);
input clock;
input reset;
input calculate_score;
input[3:0] pin_count;
input roll;

output[8:0] score;

reg [8:0] score;
reg [3:0] rolls [0:21];
reg [4:0] frames [0:9];
reg [4:0] roll_index;
reg [4:0] idx;

always @ (posedge clock) begin
   if(reset) begin
      score <= 0;   
      roll_index <= 0;
      idx <= 0;
   end
   else begin
      if(roll) begin
         rolls[roll_index] <= pin_count;
         roll_index <= roll_index + 1;      
      end
      else if (calculate_score) begin
         if(rolls[idx] == 10) begin
            score <= score + 10 + rolls[idx+1] + rolls[idx+2];
            idx <= idx + 1;
         end
         else if(rolls[idx] + rolls[idx+1] == 10) begin
            score <= score + 10 + rolls[idx+2];
            idx <= idx + 2;
         end
         else begin
            score <= score + rolls[idx] + rolls[idx+1];
            idx <= idx + 2;
         end
      end
      else begin
         score <= score;
      end       
   end
end
endmodule
