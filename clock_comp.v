module seconds_counter (
  input        clk,
  input        rst,
  input        en,
  output [7:0] seconds,
  output       carry_out
);
  wire      c;
  reg [7:0] count;
//======= sequential logic =======
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      count     <= 8'b0;
    end
    else if (en) begin
      if (c) begin
        count <= 8'b0;
      end
      else begin
        count <= count + 1'b1;
      end
    end
  end
//======= continuous assignments =======
  assign c         = count == 8'd59;
  assign carry_out = (c & en);
  assign seconds   = count;
endmodule
//=================== limited couunter ===================
module  limited_counter #(parameter LIMIT =60)(
  input        clk,
  input        rst,
  input        in,
  input        sel,
  output [7:0] dout,
  output       carry_out
);
  reg [7:0] count;
  wire c;
//======= sequential logic =======
always @(posedge clk or posedge rst) begin
  if (rst) begin
    count <= 0;
  end
  else begin
    if (c) 
      count <=0;
    else
      count <= count +in;
  end
end
//======= continuous assignments =======
  assign c         = (count == LIMIT);
  assign carry_out = (c & sel);
  assign dout      = count;
endmodule