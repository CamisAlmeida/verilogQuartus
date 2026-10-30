// Fazer flip flop D
// Parte do circuito de 74HC166

module flipFlopD(Q, D, clk, reset);
	input wire D, clk, reset;
	output reg Q;
	
	always @(posedge clk or negedge reset)
	begin 
		if (reset == 1'b0)
		Q <= 1'b0;
		else
		Q <= D;
	end

endmodule