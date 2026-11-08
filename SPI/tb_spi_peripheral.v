`timescale 1ns / 1ps

module tb_spi_peripheral;

    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;

    reg         clk;
    reg         rst_n;
    reg         cs_n;
    reg         sclk;
    reg         mosi;
    wire        miso;
    wire [DATA_WIDTH-1:0] data_out;
    reg  [DATA_WIDTH-1:0] data_in;

    // Instância DUT
	 spi_peripheral dut (
		 .clk      (clk),
		 .rst_n    (rst_n),
		 .cs_n     (cs_n),
		 .sclk     (sclk),
		 .mosi     (mosi),
		 .miso     (miso),
		 .data_out (data_out),
		 .data_in  (data_in)
	);   

    // Clock
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Tarefa: enviar um byte (renomeado de "byte" -> "data")
    task send_byte(input [DATA_WIDTH-1:0] data);
        integer i;
        begin
            cs_n = 0;
            repeat (2) @(posedge clk);
            for (i = DATA_WIDTH-1; i >= 0; i = i - 1) begin
                mosi = data[i];
                @(posedge clk);
            end
            repeat (2) @(posedge clk);
            cs_n = 1;
        end
    endtask

    // Tarefa: verificar byte (sem "string")
    task check_byte(input [DATA_WIDTH-1:0] expected, input [DATA_WIDTH-1:0] actual);
        begin
            if (actual === expected)
                $display("[PASS] 0x%02h", actual);
            else
                $display("[FAIL] esperado 0x%02h, obtido 0x%02h", expected, actual);
        end
    endtask

    // Teste principal
    initial begin
        rst_n   = 0;
        cs_n    = 1;
        sclk    = 0;
        mosi    = 0;
        data_in = 8'h00;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        $display("  TB SPI Peripheral - Início dos testes");

        $display("\n[TEST 1] Enviando 0xFF");
        data_in = 8'hFF;
        send_byte(8'hFF);
        check_byte(8'hFF, data_out);

        $display("\n[TEST 2] Enviando 0xA5");
        data_in = 8'hA5;
        send_byte(8'hA5);
        check_byte(8'hA5, data_out);

        $display("\n[TEST 3] Enviando 0x00");
        data_in = 8'h00;
        send_byte(8'h00);
        check_byte(8'h00, data_out);

        $display("\n[TEST 4] Enviando 0x5A");
        data_in = 8'h5A;
        send_byte(8'h5A);
        check_byte(8'h5A, data_out);

        $display("\n[TEST 5] Sequência de bytes");
        data_in = 8'h12;
        send_byte(8'h12);
        check_byte(8'h12, data_out);

        data_in = 8'h34;
        send_byte(8'h34);
        check_byte(8'h34, data_out);

        data_in = 8'h56;
        send_byte(8'h56);
        check_byte(8'h56, data_out);

        $display("\n[TEST 6] CS desabilitado");
        cs_n = 0;
        repeat (2) @(posedge clk);
        cs_n = 1;
        repeat (4) @(posedge clk);
        $display("       data_out = 0x%02h", data_out);

        $display("  Fim dos testes");
        #100;
        $finish;
    end

    initial begin
        $dumpfile("tb_spi_peripheral.vcd");
        $dumpvars(0, tb_spi_peripheral);
    end

endmodule   