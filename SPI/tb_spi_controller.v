`timescale 1ns / 1ps

module tb_spi_controller;

    localparam DIV = 4;       // semiciclo de SCLK = 4 ciclos de clk (DIV >= 3)

    reg         clk = 0;
    reg         clr_n;

    // controlador
    reg         c_load;
    reg  [7:0]  c_in;
    wire [7:0]  c_out;
    reg         start;
    reg         sel;
    wire        sclk, copi, cipo;
    wire [1:0]  cs_n;
    wire        busy, done;

    // periferico
    reg         p_load;
    reg  [7:0]  p_in;
    wire [7:0]  p_out;
    wire        rx_valid;
    wire        cipo_p;

    // mux de CIPO (igual ao spi_system)
    assign cipo = (!cs_n[0]) ? cipo_p : 1'b0;

    spi_controller #(.DIV(DIV)) u_ctrl (
        .clk(clk), .clr_n(clr_n),
        .parallel_load(c_load), .parallel_in(c_in), .parallel_out(c_out),
        .start(start), .peripheral_sel(sel),
        .sclk(sclk), .copi(copi), .cipo(cipo),
        .cs_n(cs_n), .busy(busy), .done(done)
    );

    spi_peripheral u_per (
        .clk(clk), .clr_n(clr_n),
        .parallel_load(p_load), .parallel_in(p_in), .parallel_out(p_out),
        .rx_valid(rx_valid),
        .sclk(sclk), .cs_n(cs_n[0]), .copi(copi), .cipo(cipo_p)
    );

    // clock de 10 ns
    always #5 clk = ~clk;

    //  monitores 
    integer sclk_rise_cnt = 0, sclk_fall_cnt = 0;
    integer cs0_cnt = 0, cs1_cnt = 0;
    integer done_cnt = 0, rx_cnt = 0, cs_bad = 0;
    reg [7:0] copi_seen = 8'h00;
    reg [7:0] cipo_seen = 8'h00;
    integer erros = 0;

    // copi e cipo sao capturados em cada subida de SCLK (so mudam na descida)
    always @(posedge sclk) begin
        sclk_rise_cnt = sclk_rise_cnt + 1;
        copi_seen = {copi_seen[6:0], copi};
        cipo_seen = {cipo_seen[6:0], cipo};
    end
    always @(negedge sclk) sclk_fall_cnt = sclk_fall_cnt + 1;

    // quantas vezes cada CS foi ativado
    always @(negedge cs_n[0]) if (clr_n) cs0_cnt = cs0_cnt + 1;
    always @(negedge cs_n[1]) if (clr_n) cs1_cnt = cs1_cnt + 1;

    // cs_n nunca pode ser 2'b00 (dois periféricos ao mesmo tempo)
    always @(cs_n) if (clr_n && cs_n === 2'b00) cs_bad = cs_bad + 1;

    always @(posedge clk) begin
        if (done)     done_cnt = done_cnt + 1;
        if (rx_valid) rx_cnt   = rx_cnt + 1;
    end

    // ---------------- checagens ----------------
    task check8(input [8*20:1] nome, input [7:0] got, input [7:0] exp);
        begin
            if (got === exp)
                $display("       [PASS] %0s = %h", nome, got);
            else begin
                $display("       [FAIL] %0s = %h, esperado %h", nome, got, exp);
                erros = erros + 1;
            end
        end
    endtask

    task checkint(input [8*20:1] nome, input integer got, input integer exp);
        begin
            if (got == exp)
                $display("       [PASS] %0s = %0d", nome, got);
            else begin
                $display("       [FAIL] %0s = %0d, esperado %0d", nome, got, exp);
                erros = erros + 1;
            end
        end
    endtask

    // uma transferencia completa 
    // mode 0: normal
    // mode 1: pulsos extras de start com busy = 1       (Teste B)
    // mode 2: troca peripheral_sel durante a operacao   (Teste C)
    task run_transfer(input s, input [7:0] cw, input [7:0] pw, input integer mode);
        integer t, r0, f0, c0, c1, d0, x0, d_err;
        reg [7:0] old_c, old_p;
        begin
            // carrega os dois PISO (1 ciclo, com cs_n = 11)
            @(negedge clk);
            c_in = cw;  c_load = 1;
            p_in = pw;  p_load = 1;
            @(negedge clk);
            c_load = 0; p_load = 0;

            // guarda o estado antes da transferencia
            old_c = c_out;  old_p = p_out;
            r0 = sclk_rise_cnt; f0 = sclk_fall_cnt;
            c0 = cs0_cnt;       c1 = cs1_cnt;
            d0 = done_cnt;      x0 = rx_cnt;
            d_err = 0;

            // start de 1 ciclo
            sel   = s;
            start = 1;
            @(negedge clk);
            start = 0;

            t = 0;
            while (!done && t < 1000) begin
                if (mode == 1) start = (busy && t >= 8 && t <= 20);
                if (mode == 2 && t == 20) sel = ~s;

                @(negedge clk);
                t = t + 1;

                // Teste D: antes do 8o bit as saidas paralelas nao mudam
                if ((sclk_rise_cnt - r0) < 8)
                    if (c_out !== old_c || p_out !== old_p) d_err = d_err + 1;
            end
            start = 0;
            sel   = s;
            repeat (4) @(negedge clk);   // deixa tudo assentar

            if (t >= 1000) begin
                $display("       [FAIL] timeout: done nunca ativou");
                erros = erros + 1;
            end

            checkint("pulsos SCLK (subida)", sclk_rise_cnt - r0, 8);
            checkint("pulsos SCLK (descida)", sclk_fall_cnt - f0, 8);
            checkint("ativacoes cs_n[0]",   cs0_cnt - c0, (s == 0) ? 1 : 0);
            checkint("ativacoes cs_n[1]",   cs1_cnt - c1, (s == 1) ? 1 : 0);
            checkint("pulsos de done",      done_cnt - d0, 1);
            checkint("pulsos rx_valid",     rx_cnt - x0, (s == 0) ? 1 : 0);
            checkint("alteracao antes 8o",  d_err, 0);
            check8("copi (enviado)",        copi_seen, cw);
            check8("cs_n final (11)",       {6'b0, cs_n}, 8'h03);
            check8("sclk final (0)",        {7'b0, sclk}, 8'h00);
            check8("busy final (0)",        {7'b0, busy}, 8'h00);
        end
    endtask

    //  sequencia de testes 
    initial begin
        $dumpfile("tb_spi_controller.vcd");
        $dumpvars(0, tb_spi_controller);

        clr_n = 0; start = 0; sel = 0;
        c_load = 0; p_load = 0; c_in = 8'h00; p_in = 8'h00;
        repeat (4) @(negedge clk);
        clr_n = 1;
        repeat (2) @(negedge clk);

        $display("=== TB SPI Controller + Peripheral ===");

        // TESTE A: sistema ocioso
        $display("\n[TESTE A] Sistema ocioso");
        repeat (40) @(negedge clk);
        check8("sclk (0)",       {7'b0, sclk}, 8'h00);
        check8("cs_n (11)",      {6'b0, cs_n}, 8'h03);
        check8("busy (0)",       {7'b0, busy}, 8'h00);
        checkint("pulsos SCLK",  sclk_rise_cnt, 0);

        // EXPERIMENTO 1: periferico 0, A5 <-> 3C
        $display("\n[EXP 1] sel = 0, ctrl envia A5, periferico envia 3C");
        run_transfer(1'b0, 8'hA5, 8'h3C, 0);
        check8("cipo (recebido)",    cipo_seen, 8'h3C);
        check8("parallel_out ctrl",  c_out, 8'h3C);
        check8("parallel_out per",   p_out, 8'hA5);

        // EXPERIMENTO 2 (adaptado): sel = 1, o unico periferico NAO e selecionado
        $display("\n[EXP 2] sel = 1: periferico 0 deve ficar inativo");
        run_transfer(1'b1, 8'h5A, 8'h99, 0);
        check8("parallel_out per (igual)", p_out, 8'hA5);
        check8("parallel_out ctrl (cipo=0)", c_out, 8'h00);

        // EXPERIMENTO 3: novas palavras
        $display("\n[EXP 3a] sel = 0, ctrl envia F0, periferico envia 96");
        run_transfer(1'b0, 8'hF0, 8'h96, 0);
        check8("cipo (recebido)",    cipo_seen, 8'h96);
        check8("parallel_out ctrl",  c_out, 8'h96);
        check8("parallel_out per",   p_out, 8'hF0);

        $display("\n[EXP 3b] sel = 0, ctrl envia 0F, periferico envia 00");
        run_transfer(1'b0, 8'h0F, 8'h00, 0);
        check8("cipo (recebido)",    cipo_seen, 8'h00);
        check8("parallel_out ctrl",  c_out, 8'h00);
        check8("parallel_out per",   p_out, 8'h0F);

        // TESTE B: start durante a transferencia
        $display("\n[TESTE B] start repetido com busy = 1");
        run_transfer(1'b0, 8'hC3, 8'h7E, 1);
        check8("cipo (recebido)",    cipo_seen, 8'h7E);
        check8("parallel_out ctrl",  c_out, 8'h7E);
        check8("parallel_out per",   p_out, 8'hC3);
        repeat (30) @(negedge clk);
        checkint("pulsos de done (total)", done_cnt, 5);   // nenhuma transferencia extra

        // TESTE C: troca de peripheral_sel durante a transferencia
        $display("\n[TESTE C] peripheral_sel muda no meio da transferencia");
        run_transfer(1'b0, 8'h81, 8'hE7, 2);
        check8("cipo (recebido)",    cipo_seen, 8'hE7);
        check8("parallel_out ctrl",  c_out, 8'hE7);
        check8("parallel_out per",   p_out, 8'h81);

        // cs_n nunca ficou 00
        $display("\n[GERAL]");
        checkint("cs_n = 00 (vezes)", cs_bad, 0);

        $display("\n Fim: %0d erro(s) ", erros);
        $stop;
    end

endmodule