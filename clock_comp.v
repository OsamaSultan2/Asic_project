module seconds_counter (
  input        clk,
  input        rst,
  input        en,
  output [3:0] sec_t, sec_u,
  output [7:0] carry_out
);
  wire      c;
  reg [7:0] count;
//======= sequential logic =======
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      count   <= 8'b0;
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
  assign carry_out = (c & en) ? 8'd1 : 8'd0;
  assign sec_t     = (count - (count % 10)) / 10;  //44
  assign sec_u    = count % 10;
endmodule


//=================== limited counter ===================
module  limited_counter #(parameter LIMIT = 60)(
  input        clk,
  input        rst,
  input  [7:0] in,    //Mux out
  input        sel,   //Mux selector
  output [3:0] mm_t, mm_u,  
  output [7:0] carry_out
);
  reg [7:0] count;
  wire c;
//======= sequential logic =======
always @(posedge clk or posedge rst) begin
  if (rst) begin
    count <= 0;
  end
  else begin
    if (sel) begin
      if (c && in == 1)       //59min:59sec | 23h:59min:59sec
        count <= 0;
      else
        count <= count + in;  //in = 1
    end else begin
      count <= in;            //load set value
    end
  end
end
//======= continuous assignments =======
  assign c         = (count == LIMIT - 1);
  assign carry_out = (c && in == 1 && sel) ? 8'd1 : 8'd0;
  assign mm_t      = (count - (count % 10)) / 10;
  assign mm_u      = count % 10;
endmodule
