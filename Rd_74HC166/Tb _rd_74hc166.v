`timescale 1ns/1ps

module tb_Rd_74HC166;

	// Sinais
	reg        clk = 0;
	reg        clr_n = 1;
	reg        clk_inh = 0;
	reg        shift_load_n = 1;
	reg        serial_in = 0;
	reg  [7:0] parallel_in = 8'b00000000;
	wire       serial_out;

	// Dado
	localparam [7:0] DADO = 8'b10110010;

	integer    i;
	integer    erros = 0;
	reg  [7:0] lido;

	// DUT
	Rd_74HC166 dut (
		.clk(clk),
		.clr_n(clr_n),
		.clk_inh(clk_inh),
		.shift_load_n(shift_load_n),
		.parallel_in(parallel_in),
		.serial_in(serial_in),
		.serial_out(serial_out)
	);

	// Clock: periodo de 10 ns
	always #5 clk = ~clk;

	// Tarefas de verificacao
	task check_bit(input esperado, input [8*28:1] msg);
		begin
			if (serial_out !== esperado) begin
				erros = erros + 1;
				$display("[%0t] FAIL: %0s | serial_out=%b esperado=%b", $time, msg, serial_out, esperado);
			end else
				$display("[%0t] PASS: %0s | serial_out=%b", $time, msg, serial_out);
		end
	endtask

	task check_reg(input [7:0] esperado, input [8*28:1] msg);
		begin
			if (dut.shift_reg !== esperado) begin
				erros = erros + 1;
				$display("[%0t] FAIL: %0s | shift_reg=%b esperado=%b", $time, msg, dut.shift_reg, esperado);
			end else
				$display("[%0t] PASS: %0s | shift_reg=%b", $time, msg, dut.shift_reg);
		end
	endtask

	initial begin
		$dumpfile("tb_Rd_74HC166.vcd");
		$dumpvars(0, tb_Rd_74HC166);

		// reset assincrono inicial
		$display("\nTESTE 1: reset inicial ");
		@(negedge clk);
		clr_n = 0;
		#1;
		check_reg(8'b00000000, "reset inicial");
		@(negedge clk);
		clr_n = 1;

		// carga paralela de 10110010 e leitura serial
		$display("\nTESTE 2: carga paralela e leitura serial ");
		@(negedge clk);
		parallel_in  = DADO;
		shift_load_n = 0;            // carga paralela
		@(negedge clk);              // borda de subida ocorreu -> carregou
		check_reg(DADO, "apos carga paralela");
		shift_load_n = 1;            // modo deslocamento
		serial_in    = 0;

		// Le os 8 bits: bit7 primeiro (ja disponivel apos a carga)
		for (i = 7; i >= 0; i = i - 1) begin
			check_bit(DADO[i], "leitura serial");
			lido[i] = serial_out;
			@(negedge clk);          // 1 deslocamento
		end
		if (lido !== DADO) begin
			erros = erros + 1;
			$display("FAIL: byte lido=%b esperado=%b", lido, DADO);
		end else
			$display("PASS: byte lido serialmente = %b", lido);
		check_reg(8'b00000000, "apos 8 deslocamentos (zeros)");

		// bloqueio das operacoes (clk_inh)
		$display("\n TESTE 3: clk_inh bloqueia operacoes ");
		@(negedge clk);
		parallel_in  = DADO;
		shift_load_n = 0;
		@(negedge clk);              // carregou DADO
		check_reg(DADO, "carga antes do bloqueio");

		@(posedge clk); #1;
		clk_inh = 1;                 // altera clk_inh somente com clk = 1
		@(negedge clk);
		shift_load_n = 1;            // tenta deslocar
		serial_in    = 1;
		repeat (3) @(negedge clk);
		check_reg(DADO, "bloqueado: tentou deslocar");

		shift_load_n = 0;            // tenta carregar outro valor
		parallel_in  = 8'b11111111;
		repeat (2) @(negedge clk);
		check_reg(DADO, "bloqueado: tentou carregar");

		@(posedge clk); #1;
		clk_inh      = 0;            // libera com clk = 1
		shift_load_n = 1;
		serial_in    = 0;
		@(negedge clk);              // ainda nao houve borda
		check_reg(DADO, "liberado: antes da borda");
		@(negedge clk);              // houve 1 deslocamento
		check_reg({DADO[6:0], 1'b0}, "liberado: apos 1 deslocamento");

		// reset assincrono entre bordas de clock
		$display("\n TESTE 4: reset entre bordas");
		@(negedge clk);
		parallel_in  = DADO;
		shift_load_n = 0;
		@(negedge clk);
		check_reg(DADO, "carga antes do reset");
		shift_load_n = 1;

		#2;                          // meio do ciclo, sem borda
		clr_n = 0;
		#1;
		check_reg(8'b00000000, "reset entre bordas");
		check_bit(1'b0, "serial_out zerado");
		#1;
		clr_n = 1;                   // solta o reset antes da proxima borda
		@(negedge clk);
		check_reg(8'b00000000, "continua zero apos soltar reset");

		// reset tambem com clk_inh = 1 (independe dos demais sinais)
		@(negedge clk);
		parallel_in  = DADO;
		shift_load_n = 0;
		@(negedge clk);
		@(posedge clk); #1;
		clk_inh = 1;
		#1;
		clr_n = 0;
		#1;
		check_reg(8'b00000000, "reset com clk_inh=1");
		clr_n = 1;
		@(posedge clk); #1;
		clk_inh = 0;
		shift_load_n = 1;
		@(negedge clk);

		// insercao serial de 0s e 1s
		$display("\n TESTE 5: serial_in");
		@(negedge clk);
		clr_n = 0; #1; clr_n = 1;
		shift_load_n = 1;

		// Insere 10110010 (MSB primeiro): deve ficar igual a DADO
		for (i = 7; i >= 0; i = i - 1) begin
			serial_in = DADO[i];
			@(negedge clk);
		end
		check_reg(DADO, "inseriu 10110010 pela serial");

		// Insere oito 1s
		serial_in = 1;
		for (i = 0; i < 8; i = i + 1) @(negedge clk);
		check_reg(8'b11111111, "inseriu oito 1s");
		check_bit(1'b1, "serial_out = 1");

		// Insere oito 0s
		serial_in = 0;
		for (i = 0; i < 8; i = i + 1) @(negedge clk);
		check_reg(8'b00000000, "inseriu oito 0s");
		check_bit(1'b0, "serial_out = 0");

		$display("\n FIM: %0d erro(s)", erros);
		if (erros == 0) $display("TODOS OS TESTES PASSARAM");
		#20;
		$stop;
	end

endmodule