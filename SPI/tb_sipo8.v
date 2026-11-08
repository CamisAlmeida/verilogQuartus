`timescale 1ns/1ps

module tb_sipo8;

	reg        clk = 0;
	reg        clr_n;
	reg        sample;
	reg        last_bit;
	reg        serial_in;
	wire [7:0] parallel_out;
	wire       valid;

	sipo8 dut (
		.clk(clk),
		.clr_n(clr_n),
		.sample(sample),
		.last_bit(last_bit),
		.serial_in(serial_in),
		.parallel_out(parallel_out),
		.valid(valid)
	);

	// clock de 10 ns
	always #5 clk = ~clk;

	// conta quantos pulsos de valid ocorreram
	integer valid_count = 0;
	always @(posedge clk)
		if (valid) valid_count = valid_count + 1;

	// modelo de referencia
	reg [7:0] ref_sr  = 8'h00;   // shift_reg 
	reg [7:0] ref_out = 8'h00;   // saida esperada

	// envia uma palavra de 8 bits
	task envia_palavra(input [7:0] word);
		integer i;
		begin
			for (i = 7; i >= 0; i = i - 1) begin
				serial_in = word[i];
				sample    = 1;                  // 1 ciclo de clk
				last_bit  = (i == 0);           // so no oitavo bit
				@(negedge clk);
				sample    = 0;
				last_bit  = 0;

				// atualiza o modelo
				ref_sr = {ref_sr[6:0], word[i]};
				if (i == 0) ref_out = ref_sr;

				// confere registrador interno e saida
				if (dut.shift_reg === ref_sr)
					$display("OK   bit %0d: shift_reg = %b", i, dut.shift_reg);
				else
					$display("ERRO bit %0d: shift_reg = %b, esperado %b", i, dut.shift_reg, ref_sr);

				if (parallel_out !== ref_out)
					$display("ERRO bit %0d: parallel_out = %h, esperado %h", i, parallel_out, ref_out);

				// ciclo ocioso com serial_in "sujo": sem sample nada pode mudar
				if (i > 0) begin
					serial_in = 1'b1;
					@(negedge clk);
					if (dut.shift_reg !== ref_sr)
						$display("ERRO: shift_reg mudou sem sample");
				end
			end
		end
	endtask

	initial begin
		$dumpfile("tb_sipo8.vcd");
		$dumpvars(0, tb_sipo8);

		// estado inicial e reset
		clr_n = 0; sample = 0; last_bit = 0; serial_in = 0;
		#12;
		clr_n = 1;
		@(negedge clk);

		// Palavra 1: 00111100 -> 3C
		$display("Palavra 1: 8'b00111100");
		envia_palavra(8'b00111100);
		repeat (2) @(negedge clk);

		if (parallel_out === 8'h3C) $display("OK   parallel_out = %h", parallel_out);
		else $display("ERRO parallel_out = %h, esperado 3C", parallel_out);

		if (valid_count == 1) $display("OK   valid pulsou %0d vez", valid_count);
		else $display("ERRO valid pulsou %0d vezes, esperado 1", valid_count);

		// Palavra 2: A5 (parallel_out deve ficar em 3C ate o 8o bit)
		$display("--- Palavra 2: 8'hA5 ---");
		envia_palavra(8'hA5);
		repeat (2) @(negedge clk);

		if (parallel_out === 8'hA5) $display("OK   parallel_out = %h", parallel_out);
		else $display("ERRO parallel_out = %h, esperado A5", parallel_out);

		if (valid_count == 2) $display("OK   valid pulsou %0d vezes no total", valid_count);
		else $display("ERRO valid pulsou %0d vezes, esperado 2", valid_count);

		$stop;
	end

endmodule