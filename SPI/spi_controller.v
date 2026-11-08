module spi_controller #(
parameter integer DIV = 10
	)(
	input wire clk,
	input wire clr_n,
	input wire parallel_load,
	input wire [7:0] parallel_in,
	output wire [7:0] parallel_out,
	input wire start,
	input wire peripheral_sel,
	output wire sclk,
	output wire copi,
	input wire cipo,
	output wire [1:0] cs_n,
	output wire busy,
	output wire done
);

    // estados 
    localparam [1:0] IDLE     = 2'd0,
                     SETUP    = 2'd1,
                     TRANSFER = 2'd2,
                     DONE     = 2'd3;

    reg [1:0]  state;
    reg        sclk_r;
    reg [31:0] div_cnt;      // conta ciclos de clk dentro de cada semiciclo
    reg [3:0]  bit_cnt;      // conta subidas de SCLK
    reg        sel_r;        // periferico registrado no start

    // divisor e habilitacoes 
    wire in_xfer  = (state == TRANSFER);
    wire tick     = (div_cnt == DIV - 1);          // fim de um semiciclo

    wire rise_en  = in_xfer & tick & ~sclk_r;      // SCLK vai de 0 para 1
    wire fall_en  = in_xfer & tick &  sclk_r;      // SCLK vai de 1 para 0
    wire last_bit = (bit_cnt == 4'd7);             // junto com rise_en = 8 bit
    wire shift_en = fall_en & (bit_cnt != 4'd8);   // sem shift após o ultimo bit
    wire load_en  = parallel_load & (state == IDLE);

    // maquina de estados 
    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            state   <= IDLE;
            sclk_r  <= 1'b0;
            div_cnt <= 32'd0;
            bit_cnt <= 4'd0;
            sel_r   <= 1'b0;
        end 
		  else begin
            case (state)
                IDLE: begin
                    sclk_r  <= 1'b0;
                    div_cnt <= 32'd0;
                    bit_cnt <= 4'd0;
                    if (start) begin
                        sel_r <= peripheral_sel;  // passa para seleçao
                        state <= SETUP; 
                    end
                end

                SETUP: begin // cs_n ativo, SCLK = 0
                    if (div_cnt == DIV - 1) begin
                        div_cnt <= 32'd0;
                        state   <= TRANSFER;
                    end 
						  else
                        div_cnt <= div_cnt + 1;
                end

                TRANSFER: begin
                    if (tick) begin
                        div_cnt <= 32'd0;
                        sclk_r  <= ~sclk_r;
                        if (!sclk_r)
                            bit_cnt <= bit_cnt + 4'd1;   // subida: conta o bit
                        else if (bit_cnt == 4'd8)
                            state <= DONE;               // 8 descida: acabou
                    end 
						  else
                        div_cnt <= div_cnt + 1;
                end

                DONE: state <= IDLE;
            endcase
        end
    end

    // saidas 
    assign sclk = sclk_r;
    assign cs_n = (state == IDLE || state == DONE) ? 2'b11 :
                  (sel_r ? 2'b01 : 2'b10);
    assign busy = (state != IDLE);
    assign done = (state == DONE);

    // transmissao - piso
    piso8 u_piso (
        .clk(clk),
        .clr_n(clr_n),
        .load(load_en),
        .shift(shift_en),
        .parallel_in(parallel_in),
        .serial_out(copi)
    );

    // recepção - sipo
    sipo8 u_sipo (
        .clk(clk),
        .clr_n(clr_n),
        .sample(rise_en),
        .last_bit(last_bit),
        .serial_in(cipo),
        .parallel_out(parallel_out),
        .valid() // não usado no controlador
    );

endmodule

/*
Questão 4. Por que é necessário manter o sinal CS ativo durante todos os oito ciclos de SCLK?
o cs define quem está participando da transferência. Então manter ele ativo até o final dos oito ciclos garante que a transferência seja feita de forma completa. Se ele subisse antes os dados seriam perdidos, pois zeraria o contador de bits . Evita também que outros periféricos interpretem os pulsos de SCLK como se fossem deles .

Questão 5. Qual seria o efeito de utilizar o mesmo instante de clock para modificar o bit transmitido e amostrar o bit recebido?
Essa questão é parecida com a terceira. Se o mesmo instante for utilizado para modificar o bit e amostrar o bit recebido ao mesmo estaríamos modificando o bit no mesmo instante que estaria sendo lido. O bit amostrado poderia ser o antigo, o novo ou um valor indefinido, e a palavra recebida ficaria duplicada, deslocada ou incorreta. Por isso o bit muda na descida e é amostrado na subida, meio período depois.


*/