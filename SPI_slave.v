module SPI_slave(
    input clk,
    input reset,
    input spi_clk,      
    input cs_n,        
    input mosi,        
    output reg miso,    
    output reg [3:0] led_out 
);

    reg [2:0] bit_cnt;
    reg [7:0] tx_reg;
    reg [7:0] rx_reg;
    reg [2:0] sclk_sync;
    localparam DATA = 8'hA5;
    
    always @(posedge clk) begin
        if (reset) sclk_sync <= 3'b000;
        else       sclk_sync <= {sclk_sync[1:0], spi_clk};
    end

    wire rising_edge  = (sclk_sync[1] && !sclk_sync[2]);
    wire falling_edge = (!sclk_sync[1] && sclk_sync[2]);

    always @(posedge clk) begin
        if (reset || cs_n) begin
            bit_cnt <= 3'd7;
            tx_reg  <=_DATA;
            miso    <=DATA[7];
        end else begin
          
            if (rising_edge) begin
                rx_reg <= {rx_reg[6:0], mosi};
                if (bit_cnt == 0) begin
                    led_out <= {rx_reg[2:0], mosi}; 
                end
            end
       
            if (falling_edge) begin
                if (bit_cnt == 0) begin
                    bit_cnt <= 3'd7;
                    tx_reg  <= DATA;
                    miso    <= DATA[7];
                end else begin
                    bit_cnt <= bit_cnt - 1'b1;
                    tx_reg  <= {tx_reg[6:0], 1'b0};
                    miso    <= tx_reg[6]; 
   end
           end
    end
    end
endmodule
