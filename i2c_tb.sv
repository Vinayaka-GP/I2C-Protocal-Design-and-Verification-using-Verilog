module i2c_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [6:0] addr;
	reg [7:0] data_in;
	reg en;
	reg rw;

	// Outputs
	wire [7:0] data_out;
	wire ready;
	wire sda;
	wire scl;

	i2c_master master (
		.clk(clk), 
		.rst(rst), 
		.addr(addr), 
		.data_in(data_in), 
		.en(en), 
		.rw(rw), 
		.data_out(data_out), 
		.ready(ready), 
		.sda(sda), 
		.scl(scl)
	);
	
		
	i2c_slave slave (
    .sda(sda), 
    .scl(scl)
    );
	
  initial begin
  $dumpfile("i2c_protocal.vcd");
  $dumpvars(0,i2c_tb);
  end
  
  always #1 clk=~clk;
	
	initial begin
		clk = 0;
		rst = 1;
		#100;
        
		rst = 0;		
		addr = 7'b0101010;
		data_in = 8'b10101010;
		rw = 1;	
		en = 1;
      #10
      	
      
		en = 0;
				
		#500
		$finish;
    end
endmodule