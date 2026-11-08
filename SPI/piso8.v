module piso8 (
input wire clk,
input wire clr_n,
input wire load,
input wire shift,
input wire [7:0] parallel_in,
output wire serial_out
);

	reg [7:0] shift_reg = 8'b0;
	
	always @(posedge clk or negedge clr_n) begin
		
		if(clr_n == 0)
			shift_reg <= 8'b0;
		else if (load == 1)
			shift_reg <= parallel_in;
		else if (shift == 1)
			shift_reg <= {shift_reg[6:0], 1'b0};
		end
	
	assign serial_out = shift_reg[7];

endmodule