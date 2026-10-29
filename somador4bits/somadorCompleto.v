/**
Somador completo em verilog
**/

// Declaração do modulo
module somadorCompleto(a,b,cin,s,cout);
	//declaração das portas
	input a,b,cin;
	output s,cout;
	
	//declaração dos fios intermediarios
	wire w1,w2,w3;
	
	//funciomamento do circuito abordagem estrutural'
	xor u0 (w1, a, b);
	xor u1 (s, w1, cin);
	and u2 (w2, cin, w1);
	and u3 (w3, a, b);
	or u4 (cout, w2, w3);

endmodule
