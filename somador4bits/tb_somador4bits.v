
`timescale 1ns/1ps

module tb_somador4bits;

    // Entradas do circuito
    reg [3:0] a, b;
    reg cin;

    // Saídas do circuito
    wire [3:0] s;
    wire cout;

    // Instância do somador que será testado
    somador4bits uut (
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    // Testes
    initial begin

        $monitor("Tempo=%0t | A=%d | B=%d | Cin=%b | S=%d | Cout=%b",
                  $time, a, b, cin, s, cout);

        // Teste 1
        a = 4'd0; b = 4'd0; cin = 0;
        #10;

        // Teste 2
        a = 4'd3; b = 4'd2; cin = 0;
        #10;

        // Teste 3
        a = 4'd7; b = 4'd8; cin = 0;
        #10;

        // Teste 4
        a = 4'd15; b = 4'd1; cin = 0;
        #10;

        // Teste 5
        a = 4'd15; b = 4'd15; cin = 1;
        #10;

        // Teste 6
        a = 4'd5; b = 4'd3; cin = 1;
        #10;

        $finish;
    end

endmodule
