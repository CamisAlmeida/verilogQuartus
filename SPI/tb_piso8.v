`timescale 1ns/1ps

module tb_piso8;

	reg clk = 0;
	reg clr_n;
	reg load;
	reg shift;
	reg[7:0] parallel_in;
	wire serial_out;
	
	piso8 dut (
	.clk(clk),
	.clr_n(clr_n),
	.load(load),
	.shift(shift),
	.parallel_in(parallel_in),
	.serial_out(serial_out)
	);

	// clock ns == 100Mhz
	always #5 clk = ~clk;
	
	reg [7:0] carga;
	integer i;
	
	initial begin 
	
	$dumpfile ("tb_piso8.vcd");
	$dumpvars (0, tb_piso8);
	
	// estado inicial e reset
	
	clr_n = 0; 
	load = 0;
	shift = 0;
	parallel_in = 8'h00;
	
	
	#12;
	clr_n = 1;   // libera o reset
	
	// Carregar entrada
	carga = 8'hA5;
	
	@(negedge clk);
	parallel_in = carga;
	load = 1;
	@(negedge clk);
	load = 0;
	
	// le o bit e aplica shift
	for (i = 7; i>= 0; i = i - 1) begin
		if(serial_out === carga[i])
			$display("OK   bit %0d = %b", i, serial_out);
		else 
			$display("Erro bit %0d: obtido %b, carga %b", i, serial_out, carga[i]);
			
		if(i > 0) begin
			shift = 1; // ciclo de clock
			@(negedge clk);
			shift = 0;
		end
	end
	
	// teste sem load e shift - nao deve fazer nada
	
	repeat (3) @(negedge clk);
	$display("Mantido: serial_out = %b (esperado 1, resetou 10000000)", serial_out);
	
	$stop;
end
endmodule