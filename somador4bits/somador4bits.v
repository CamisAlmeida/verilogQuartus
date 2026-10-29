/*
Somador de 4 bits
a = a3 a2 a1 a0
b = b3 b2 b1 b0
s = s3 s2 s1 s0

*/

module somador4bits(a, b, cin, s, cout);
	//Declaração de variaveis 
	input [3:0] a,b;
	input cin;
	output [3:0] s;
	output cout;
	
	//Declaração dos dados intermediarios 
	wire c1,c2,c3;
	
	//Declaração do funcionamento do circuito
	somadorCompleto fa0(.a(a[0]), .b(b[0]), .cin(cin), .s(s[0]),.cout(c1));
	somadorCompleto fa1(.a(a[1]), .b(b[1]), .cin(c1), .s(s[1]), .cout(c2));
	somadorCompleto fa2(.a(a[2]), .b(b[2]), .cin(c2), .s(s[2]), .cout(c3));
	somadorCompleto fa3(.a(a[3]), .b(b[3]), .cin(c3), .s(s[3]), .cout(cout));
	
	
endmodule
