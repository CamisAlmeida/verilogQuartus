// Registrador de deslocamento 74HC166
// Versao replicando hardware

/*
module Rd_74HC166(clk, clr_n, clk_inh, shift_load_n, parallel_in, serial_in, serial_out);

	input        clk, clr_n, clk_inh, shift_load_n, serial_in;
	input  [7:0] parallel_in;   // A corresponde ao bit 0 e H ao bit 7
	output       serial_out;

	wire [7:0] o;    // entradas D
	wire [7:0] q;    // saídas dos flip-flops
	wire       c;    // clock
	wire       sh, ld;

	// Clock final
	or g_clk (c, clk, clk_inh);

	// inversores
	not g_ld (ld, shift_load_n);   // ld = 1 quando carga
	buf g_sh (sh, shift_load_n);   // sh = 1 quando deslocamento

	// Estágio A (bit 0): recebe serial_in
	entradaD d0 (.a(serial_in), .b(sh), .c(ld), .d(parallel_in[0]), .out(o[0]));
	flipFlopD f0 (.Q(q[0]), .D(o[0]), .clk(c), .reset(clr_n));

	// Estágios B..H: recebem o bit do estágio anterior
	entradaD d1 (.a(q[0]), .b(sh), .c(ld), .d(parallel_in[1]), .out(o[1]));
	flipFlopD f1 (.Q(q[1]), .D(o[1]), .clk(c), .reset(clr_n));

	entradaD d2 (.a(q[1]), .b(sh), .c(ld), .d(parallel_in[2]), .out(o[2]));
	flipFlopD f2 (.Q(q[2]), .D(o[2]), .clk(c), .reset(clr_n));

	entradaD d3 (.a(q[2]), .b(sh), .c(ld), .d(parallel_in[3]), .out(o[3]));
	flipFlopD f3 (.Q(q[3]), .D(o[3]), .clk(c), .reset(clr_n));

	entradaD d4 (.a(q[3]), .b(sh), .c(ld), .d(parallel_in[4]), .out(o[4]));
	flipFlopD f4 (.Q(q[4]), .D(o[4]), .clk(c), .reset(clr_n));

	entradaD d5 (.a(q[4]), .b(sh), .c(ld), .d(parallel_in[5]), .out(o[5]));
	flipFlopD f5 (.Q(q[5]), .D(o[5]), .clk(c), .reset(clr_n));

	entradaD d6 (.a(q[5]), .b(sh), .c(ld), .d(parallel_in[6]), .out(o[6]));
	flipFlopD f6 (.Q(q[6]), .D(o[6]), .clk(c), .reset(clr_n));

	entradaD d7 (.a(q[6]), .b(sh), .c(ld), .d(parallel_in[7]), .out(o[7]));
	flipFlopD f7 (.Q(q[7]), .D(o[7]), .clk(c), .reset(clr_n));

	assign serial_out = q[7];

endmodule

*/

// versao replicando o funcionamento
module Rd_74HC166(clk, clr_n, clk_inh, shift_load_n, parallel_in, serial_in, serial_out);

	input        clk, clr_n, clk_inh, shift_load_n, serial_in;
	input  [7:0] parallel_in;   // A corresponde ao bit 0 e H ao bit 7
	output       serial_out;
	
	reg [7:0] shift_reg = 8'b0;
	
	always @(posedge clk or negedge clr_n) begin
		
		if(clr_n == 0)
			shift_reg <= 8'b0;
		else if (clk_inh == 0) begin
			if (shift_load_n == 0)
				shift_reg <= parallel_in;
			else
				shift_reg <= {shift_reg[6:0],serial_in};
		end
	end
	
	assign serial_out = shift_reg[7];
endmodule