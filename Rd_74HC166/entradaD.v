// Parte do or com dois ands como entrada que se repete varias vezes


module entradaD(a,b,c,d,out);

	input wire a,b,c,d;
	output wire out;
	
	wire and1, and2;
	
	and a1 (and1, a, b);
	and a2 (and2, c, d);
	or o1 (out, and1, and2);
	

endmodule
