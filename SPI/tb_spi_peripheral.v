`timescale 1ns / 1ps

module tb_spi_peripheral;

    parameter CLK_PERIOD = 10;
    parameter HALF       = 5;    // ciclos de clk por semiciclo de SCLK

    reg         clk;
    reg         clr_n;
    reg         parallel_load;
    reg  [7:0]  parallel_in;
    wire [7:0]  parallel_out;
    wire        rx_valid;
    reg         sclk;
    reg         cs_n;
    reg         copi;
    wire        cipo;

    spi_peripheral dut (
        .clk           (clk),
        .clr_n         (clr_n),
        .parallel_load (parallel_load),
        .parallel_in   (parallel_in),
        .parallel_out  (parallel_out),
        .rx_valid      (rx_valid),
        .sclk          (sclk),
        .cs_n          (cs_n),
        .copi          (copi),
        .cipo          (cipo)
    );

    // clock do sistema
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // contador de pulsos de rx_valid
    integer rx_pulses = 0;
    always @(posedge clk)
        if (rx_valid) rx_pulses = rx_pulses + 1;

    integer erros = 0;
    reg [7:0] tx_seen;      // byte capturado em cipo
    reg [7:0] antes;
    integer   pulsos_antes;
    reg       cipo_antes;

    // confere um valor de 8 bits
    task check8(input [8*18:1] nome, input [7:0] got, input [7:0] exp);
        begin
            if (got === exp)
                $display("       [PASS] %0s = %h", nome, got);
            else begin
                $display("       [FAIL] %0s = %h, esperado %h", nome, got, exp);
                erros = erros + 1;
            end
        end
    endtask

    // confere um inteiro
    task checkint(input [8*18:1] nome, input integer got, input integer exp);
        begin
            if (got == exp)
                $display("       [PASS] %0s = %0d", nome, got);
            else begin
                $display("       [FAIL] %0s = %0d, esperado %0d", nome, got, exp);
                erros = erros + 1;
            end
        end
    endtask

    // pulso de parallel_load de 1 ciclo (com cs_n = 1)
    task load_tx(input [7:0] data);
        begin
            @(negedge clk);
            parallel_in   = data;
            parallel_load = 1;
            @(negedge clk);
            parallel_load = 0;
        end
    endtask

    // transferencia SPI modo 0, MSB-first, como se fosse o controlador.
    // envia nbits de rx_word pelo copi e captura o cipo antes de cada subida
    task transfer(input [7:0] rx_word, input integer nbits);
        integer i;
        begin
            tx_seen = 8'h00;
            @(negedge clk);
            cs_n = 0;                          // seleciona
            repeat (HALF) @(negedge clk);

            for (i = 7; i >= 8 - nbits; i = i - 1) begin
                copi = rx_word[i];             // dado muda com sclk em 0
                repeat (2) @(negedge clk);
                tx_seen[i] = cipo;             // cipo estavel antes da subida
                sclk = 1;                      // subida: periferico amostra copi
                repeat (HALF) @(negedge clk);
                sclk = 0;                      // descida: periferico desloca o PISO
                repeat (HALF) @(negedge clk);
            end

            cs_n = 1;                          // desseleciona
            repeat (3) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_spi_peripheral.vcd");
        $dumpvars(0, tb_spi_peripheral);

        // estado inicial e reset
        clr_n = 0; cs_n = 1; sclk = 0; copi = 0;
        parallel_in = 8'h00; parallel_load = 0;
        repeat (4) @(negedge clk);
        clr_n = 1;
        repeat (2) @(negedge clk);

        $display("=== TB SPI Peripheral ===");

        // TESTE 1: periferico envia 3C, recebe A5
        $display("\n[TESTE 1] TX = 3C, RX = A5");
        load_tx(8'h3C);
        transfer(8'hA5, 8);
        check8("cipo (tx_seen)", tx_seen, 8'h3C);
        check8("parallel_out",   parallel_out, 8'hA5);
        checkint("pulsos rx_valid", rx_pulses, 1);

        // TESTE 2: envia 5A, recebe 3C
        $display("\n[TESTE 2] TX = 5A, RX = 3C");
        load_tx(8'h5A);
        transfer(8'h3C, 8);
        check8("cipo (tx_seen)", tx_seen, 8'h5A);
        check8("parallel_out",   parallel_out, 8'h3C);
        checkint("pulsos rx_valid", rx_pulses, 2);

        // TESTE 3: recebe FF (todos os bits em 1)
        $display("\n[TESTE 3] TX = 00, RX = FF");
        load_tx(8'h00);
        transfer(8'hFF, 8);
        check8("cipo (tx_seen)", tx_seen, 8'h00);
        check8("parallel_out",   parallel_out, 8'hFF);
        checkint("pulsos rx_valid", rx_pulses, 3);

        // TESTE 4: recebe 01 (so o ultimo bit, o LSB, vale 1)
        $display("\n[TESTE 4] TX = FF, RX = 01");
        load_tx(8'hFF);
        transfer(8'h01, 8);
        check8("cipo (tx_seen)", tx_seen, 8'hFF);
        check8("parallel_out",   parallel_out, 8'h01);
        checkint("pulsos rx_valid", rx_pulses, 4);

        // TESTE 5: palavra parcial (4 bits) e cs_n sobe
        $display("\n[TESTE 5] Palavra parcial: so 4 bits, depois cs_n = 1");
        load_tx(8'h96);
        antes = parallel_out;
        pulsos_antes = rx_pulses;
        transfer(8'hF0, 4);
        check8("parallel_out (igual)", parallel_out, antes);
        checkint("pulsos rx_valid", rx_pulses, pulsos_antes);
        check8("4 bits de cipo (96)", {4'h0, tx_seen[7:4]}, 8'h09);

        // TESTE 6: nova transferencia completa depois da parcial
        // (a contagem de bits deve ter reiniciado)
        $display("\n[TESTE 6] Apos a parcial: TX = C3, RX = 5A");
        load_tx(8'hC3);
        transfer(8'h5A, 8);
        check8("cipo (tx_seen)", tx_seen, 8'hC3);
        check8("parallel_out",   parallel_out, 8'h5A);
        checkint("pulsos rx_valid", rx_pulses, pulsos_antes + 1);

        // TESTE 7: cs_n = 1 e sclk oscilando: nada pode mudar
        $display("\n[TESTE 7] cs_n = 1 com sclk oscilando");
        antes = parallel_out;
        pulsos_antes = rx_pulses;
        cipo_antes = cipo;
        copi = 1;
        repeat (16) begin
            sclk = ~sclk;
            repeat (HALF) @(negedge clk);
        end
        sclk = 0;
        repeat (3) @(negedge clk);
        check8("parallel_out (igual)", parallel_out, antes);
        checkint("pulsos rx_valid", rx_pulses, pulsos_antes);
        check8("cipo (igual)", {7'b0, cipo}, {7'b0, cipo_antes});

        $display("\n=== Fim: %0d erro(s) ===", erros);
        $stop;
    end

endmodule