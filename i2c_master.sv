module i2c_master(clk,rst,addr,data_in,en,rw,data_out,ready,sda,scl);
	input  clk,rst,en,rw;
    input  [6:0] addr;
    input  [7:0] data_in;
    output reg [7:0] data_out;
	output reg ready;
	inout sda;
	inout wire scl;

	parameter IDLE = 0,
	START = 1,
	ADDRESS = 2,
	READ_ACK = 3,
	WRITE_DATA = 4,
	WRITE_ACK = 5,
	READ_DATA = 6,
	READ_ACK2 = 7,
	STOP = 8,
	CYCLES = 4;

	reg [7:0] state;
	reg [7:0] saved_addr;
	reg [7:0] saved_data;
    reg [7:0] counter;
    reg [7:0] counter_clk = 0;
	reg wr_enable;
	reg sda_out;
	reg scl_enable = 0;
	reg scl_clk = 1;

	assign ready = ((rst == 0) && (state == IDLE)) ? 1 : 0;
  assign scl = (scl_enable == 0 ) ? 1 : scl_clk;
	assign sda = (wr_enable == 1) ? sda_out : 'bz;
	
	always @(posedge clk) begin
      if (counter_clk == (CYCLES/2) - 1) begin
			scl_clk <= ~scl_clk;
			counter_clk <= 0;
		end
		else 
          counter_clk <= counter_clk + 1;
	end 
	
  always @(negedge scl_clk, posedge rst) begin
		if(rst == 1) begin
			scl_enable <= 0;
		end else begin
			if ((state == IDLE) || (state == START) || (state == STOP)) begin
				scl_enable <= 0;
			end else begin
				scl_enable <= 1;
			end
		end
	
	end


  always @(posedge scl_clk, posedge rst) begin
		if(rst == 1) begin
			state <= IDLE;
		end		
		else begin
			case(state)
			
				IDLE: begin
                  if (en) begin
						state <= START;
						saved_addr <= {addr, rw};
						saved_data <= data_in;
					end
					else state <= IDLE;
				end

				START: begin
					counter <= 7;
					state <= ADDRESS;
				end

				ADDRESS: begin
					if (counter == 0) begin 
						state <= READ_ACK;
					end else counter <= counter - 1;
				end

				READ_ACK: begin
					if (sda == 0) begin
						counter <= 7;
						if(saved_addr[0] == 0) state <= WRITE_DATA;
						else state <= READ_DATA;
					end else state <= STOP;
				end

				WRITE_DATA: begin
					if(counter == 0) begin
						state <= READ_ACK2;
					end else counter <= counter - 1;
				end
				
				READ_ACK2: begin
					if ((sda == 0) && (en == 1)) state <= IDLE;
					else state <= STOP;
				end

				READ_DATA: begin
					data_out[counter] <= sda;
					if (counter == 0) state <= WRITE_ACK;
					else counter <= counter - 1;
				end
				
				WRITE_ACK: begin
					state <= STOP;
				end

				STOP: begin
					state <= IDLE;
				end
			endcase
		end
	end
	
  always @(negedge scl_clk, posedge rst) begin
		if(rst == 1) begin
			wr_enable <= 1;
			sda_out <= 1;
		end else begin
			case(state)
				
				START: begin
					wr_enable <= 1;
					sda_out <= 0;
				end
				
				ADDRESS: begin
					sda_out <= saved_addr[counter];
				end
				
				READ_ACK: begin
					wr_enable <= 0;
				end
				
				WRITE_DATA: begin 
					wr_enable <= 1;
					sda_out <= saved_data[counter];
				end
				
				WRITE_ACK: begin
					wr_enable <= 1;
					sda_out <= 0;
				end
				
				READ_DATA: begin
					wr_enable <= 0;				
				end
				
				STOP: begin
					wr_enable <= 1;
					sda_out <= 1;
				end
			endcase
		end
	end

endmodule