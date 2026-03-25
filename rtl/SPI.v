module SPI(
input clk,
input reset,
input data_valid,
input  [7:0] data,
output reg spi_clk,
output reg mosi,
input  miso,
output reg [7:0] data_reci,
output reg done
);
reg [3:0] counter;
reg spi_clk_p;
reg busy;
reg[2:0] bit_counter;
reg [7:0] shift_reg;
reg [1:0] state;
reg cs_n;
localparam IDLE  = 2'd0;
localparam LOAD  = 2'd1;
localparam SHIFT = 2'd2;
localparam DONE  = 2'd3;
wire falling_edge = (spi_clk==0 && spi_clk_p==1);
wire rising_edge = (spi_clk==1 && spi_clk_p==0);
always@(posedge clk)begin
  if(reset)begin 
            state       <= IDLE;
            spi_clk     <= 1'b0;
            spi_clk_p   <= 1'b0;
            counter     <= 4'd0;
            bit_counter <= 3'd0;
            shift_reg   <= 8'd0;
            data_reci   <= 8'd0;
            mosi        <= 1'b0;
            done        <= 1'b0;
            busy        <= 1'b0;
            cs_n        <= 1'b1;
end else begin
    spi_clk_p <= spi_clk;

if (busy) begin
    if (counter == 4'd4) begin
        counter <= 4'd0;
        spi_clk <= ~spi_clk;
    end else begin
        counter <= counter + 1'b1;
    end
end else begin
    spi_clk <= 1'b0;
    counter <= 1'b0;
end

case(state)
IDLE: begin
   done<=1'b0;
   cs_n<=1'b1;
   if(data_valid) begin
   state<=LOAD;
   end
   end
   
LOAD: begin

   shift_reg<=data;
   bit_counter<=3'd7;
   mosi <=data[7];
   busy<=1'b1;
   done<=1'b0;
   cs_n<=1'b0;
   state<=SHIFT;
end

SHIFT: begin

if(falling_edge)begin
    if(bit_counter > 0) begin
        shift_reg <= {shift_reg[6:0], 1'b0}; // Shift left
        bit_counter <= bit_counter - 1'b1;
        mosi <= shift_reg[6]; 
    end else begin
    state<=DONE;
    end
    end
    if(rising_edge) begin
    data_reci<={data_reci[6:0], miso};     // MISO input
    end
    
end 

DONE: begin

      busy<=1'b0;
      done<=1'b1;
      cs_n<=1'b1;
      state<=IDLE;
  end
  default: state<=IDLE;
  endcase
  end
 end
endmodule