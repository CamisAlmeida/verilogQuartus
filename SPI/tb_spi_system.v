`timescale 1ns / 1ps

module tb_spi_system;

    localparam DIV = 4;

    reg         clk = 0;
    reg         clr_n;
    reg         start, sel;
    reg         c_load, p0_load, p1_load;
    reg  [7:0]  c_in, p0_in, p1_in;
    wire [7:0]  c_out, p0_out, p1_out;
    wire        busy, done, rx0, rx1;
    wire        sclk, copi, cipo;
    wire [1:0]  cs_n;

    spi_system #(.DIV(DIV)) dut (
        .clk(clk), .clr_n(clr_n),
        .start(start), .peripheral_sel(sel),
        .busy(busy), .done(done),
        .ctrl_load(c_load),  .ctrl_in(c_in),  .ctrl_out(c_out),
        .p0_load(p0_load),   .p0_in(p0_in),   .p0_out(p0_out), .p0_rx_valid(rx0),
        .p1_load(p1_load),   .p1_in(p1_in),   .p1_out(p1_out), .p1_rx_valid(rx1),
        .sclk(sclk), .copi(copi), .cipo(cipo), .cs_n(cs_n)
    );

    always #5 clk = ~clk;

    //  monitores 
    integer rise_cnt = 0, fall_cnt = 0;
    integer cs0_cnt = 0, cs1_cnt = 0;
    integer done_cnt = 0, rx0_cnt = 0, rx1_cnt = 0, cs_bad = 0;
    reg [7:0] copi_seen = 0, cipo_seen = 0;
    integer erros = 0;

    always @(posedge sclk) begin
        rise_cnt  = rise_cnt + 1;
        copi_seen = {copi_seen[6:0], copi};
        cipo_seen = {cipo_seen[6:0], cipo};
    end
    always @(negedge sclk) fall_cnt = fall_cnt + 1;
    always @(negedge cs_n[0]) if (clr_n) cs0_cnt = cs0_cnt + 1;
    always @(negedge cs_n[1]) if (clr_n) cs1_cnt = cs1_cnt + 1;
    always @(cs_n) if (clr_n && cs_n === 2'b00) cs_bad = cs_bad + 1;

    always @(posedge clk) begin
        if (done) done_cnt = done_cnt + 1;
        if (rx0)  rx0_cnt  = rx0_cnt + 1;
        if (rx1)  rx1_cnt  = rx1_cnt + 1;
    end

    // checagens 
    task check8(input [8*22:1] nome, input [7:0] got, input [7:0] exp);
        begin
            if (got === exp)
                $display("       [PASS] %0s = %h", nome, got);
            else begin
                $display("       [FAIL] %0s = %h, esperado %h", nome, got, exp);
                erros = erros + 1;
            end
        end
    endtask

    task checkint(input [8*22:1] nome, input integer got, input integer exp);
        begin
            if (got == exp)
                $display("       [PASS] %0s = %0d", nome, got);
            else begin
                $display("       [FAIL] %0s = %0d, esperado %0d", nome, got, exp);
                erros = erros + 1;
            end
        end
    endtask

    // pulso de load de 1 ciclo. who: 0 = controlador, 1 = per 0, 2 = per 1
    task load(input integer who, input [7:0] data);
        begin
            @(negedge clk);
            case (who)
                0: begin c_in  = data; c_load  = 1; end
                1: begin p0_in = data; p0_load = 1; end
                2: begin p1_in = data; p1_load = 1; end
            endcase
            @(negedge clk);
            c_load = 0; p0_load = 0; p1_load = 0;
        end
    endtask

    // uma transferencia completa
    // mode 0: normal | mode 1: start extra com busy = 1 | mode 2: troca sel no meio
    task xfer(input s, input [7:0] c_word, input integer mode);
        integer t, r0, f0, c0, c1, d0, x0, x1, d_err;
        reg [7:0] oc, o0, o1;
        begin
            oc = c_out; o0 = p0_out; o1 = p1_out;
            r0 = rise_cnt; f0 = fall_cnt; c0 = cs0_cnt; c1 = cs1_cnt;
            d0 = done_cnt; x0 = rx0_cnt;  x1 = rx1_cnt;
            d_err = 0;

            @(negedge clk);
            sel = s; start = 1;
            @(negedge clk);
            start = 0;

            t = 0;
            while (!done && t < 2000) begin
                if (mode == 1) start = (busy && t >= 8 && t <= 20);
                if (mode == 2 && t == 20) sel = ~s;
                @(negedge clk);
                t = t + 1;
                // Teste D: antes do 8o bit nenhuma saida paralela muda
                if ((rise_cnt - r0) < 8)
                    if (c_out !== oc || p0_out !== o0 || p1_out !== o1)
                        d_err = d_err + 1;
            end
            start = 0; sel = s;
            repeat (4) @(negedge clk);

            if (t >= 2000) begin
                $display("       [FAIL] timeout: done nunca ativou");
                erros = erros + 1;
            end

            checkint("pulsos SCLK subida",  rise_cnt - r0, 8);
            checkint("pulsos SCLK descida", fall_cnt - f0, 8);
            checkint("ativacoes cs_n[0]",   cs0_cnt - c0, (s == 0) ? 1 : 0);
            checkint("ativacoes cs_n[1]",   cs1_cnt - c1, (s == 1) ? 1 : 0);
            checkint("pulsos done",         done_cnt - d0, 1);
            checkint("pulsos rx_valid p0",  rx0_cnt - x0, (s == 0) ? 1 : 0);
            checkint("pulsos rx_valid p1",  rx1_cnt - x1, (s == 1) ? 1 : 0);
            checkint("mudanca antes do 8o", d_err, 0);
            check8("copi (enviado)",        copi_seen, c_word);
            check8("cs_n final (11)",       {6'b0, cs_n}, 8'h03);
            check8("sclk final (0)",        {7'b0, sclk}, 8'h00);
            check8("busy final (0)",        {7'b0, busy}, 8'h00);
        end
    endtask

    // sequencia 
    initial begin
        $dumpfile("tb_spi_system.vcd");
        $dumpvars(0, tb_spi_system);

        clr_n = 0; start = 0; sel = 0;
        c_load = 0; p0_load = 0; p1_load = 0;
        c_in = 0; p0_in = 0; p1_in = 0;
        repeat (4) @(negedge clk);
        clr_n = 1;
        repeat (2) @(negedge clk);

        $display("=== TB SPI System ===");

        // TESTE A: ocioso
        $display("\n[TESTE A] Sistema ocioso");
        repeat (40) @(negedge clk);
        check8("sclk (0)",   {7'b0, sclk}, 8'h00);
        check8("cs_n (11)",  {6'b0, cs_n}, 8'h03);
        check8("busy (0)",   {7'b0, busy}, 8'h00);
        checkint("pulsos SCLK", rise_cnt, 0);

        // EXPERIMENTO 1: per 0.  Ctrl A5, P0 3C, P1 A7
        $display("\n[EXP 1] sel = 0: ctrl A5, p0 3C, p1 A7");
        load(0, 8'hA5); load(1, 8'h3C); load(2, 8'hA7);
        xfer(1'b0, 8'hA5, 0);
        check8("cipo (visto)",     cipo_seen, 8'h3C);
        check8("ctrl parallel_out", c_out,  8'h3C);
        check8("p0 parallel_out",   p0_out, 8'hA5);
        check8("p1 parallel_out",   p1_out, 8'h00);   // inalterado (reset)

        // EXPERIMENTO 2: per 1. Ctrl 5A, P1 continua com A7 (sem recarregar)
        $display("\n[EXP 2] sel = 1: ctrl 5A, p1 ja tem A7");
        load(0, 8'h5A);
        xfer(1'b1, 8'h5A, 0);
        check8("cipo (visto)",     cipo_seen, 8'hA7);
        check8("ctrl parallel_out", c_out,  8'hA7);
        check8("p0 parallel_out",   p0_out, 8'hA5);   // preservado
        check8("p1 parallel_out",   p1_out, 8'h5A);

        // EXPERIMENTO 3: novas palavras
        $display("\n[EXP 3a] sel = 0: ctrl F0, p0 96");
        load(0, 8'hF0); load(1, 8'h96);
        xfer(1'b0, 8'hF0, 0);
        check8("ctrl parallel_out", c_out,  8'h96);
        check8("p0 parallel_out",   p0_out, 8'hF0);
        check8("p1 parallel_out",   p1_out, 8'h5A);   // preservado

        $display("\n[EXP 3b] sel = 1: ctrl 0F, p1 00");
        load(0, 8'h0F); load(2, 8'h00);
        xfer(1'b1, 8'h0F, 0);
        check8("ctrl parallel_out", c_out,  8'h00);
        check8("p0 parallel_out",   p0_out, 8'hF0);   // preservado
        check8("p1 parallel_out",   p1_out, 8'h0F);

        // TESTE B: start durante a transferencia
        $display("\n[TESTE B] start repetido com busy = 1");
        load(0, 8'hC3); load(1, 8'h7E);
        xfer(1'b0, 8'hC3, 1);
        check8("ctrl parallel_out", c_out,  8'h7E);
        check8("p0 parallel_out",   p0_out, 8'hC3);
        repeat (40) @(negedge clk);
        checkint("done total (5)",  done_cnt, 5);

        // TESTE C: troca de sel durante a transferencia
        $display("\n[TESTE C] sel muda no meio (comecou em 1)");
        load(0, 8'h81); load(2, 8'hE7);
        xfer(1'b1, 8'h81, 2);
        check8("ctrl parallel_out", c_out,  8'hE7);
        check8("p1 parallel_out",   p1_out, 8'h81);
        check8("p0 parallel_out",   p0_out, 8'hC3);   // preservado

        $display("\n[GERAL]");
        checkint("cs_n = 00 (vezes)", cs_bad, 0);

        $display("\n=== Fim: %0d erro(s) ===", erros);
        $stop;
    end

endmodule