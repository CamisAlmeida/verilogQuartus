module spi_peripheral (
input wire clk,
input wire clr_n,
input wire parallel_load,
input wire [7:0] parallel_in,
output wire [7:0] parallel_out,
output wire rx_valid,
input wire sclk,
input wire cs_n,
input wire copi,
output wire cipo
);

	reg sclk_d;
	
	always @(posedge clk or negedge clr_n) begin
		if (!clr_n) sclk_d <= 1'b0; 
		else sclk_d <= sclk;
	end
	
	wire sclk_rise = sclk & ~sclk_d; // subida
	wire sclk_fall = ~sclk & sclk_d; // descida

	wire selecao = ~cs_n; // cs_n == 0
	
	reg [2:0] bit_cnt; // contador de bordas de subida
	
	always @(posedge clk or negedge clr_n) begin
		if (!clr_n) bit_cnt <= 3'd0;
		else if  (cs_n) bit_cnt <= 3'd0; // desseleciono, reinicio a contagem
		else if (sclk_rise) bit_cnt <= bit_cnt + 3'd1;
 	end
	
	wire sample_en = sclk_rise & selecao;
	wire last_bit = (bit_cnt == 3'd7); 
	wire load_en = parallel_load & cs_n; // so carrga com o periferico inativo
	wire shift_en = sclk_fall & selecao & (bit_cnt != 3'd0);
	
	// transmisao 
	piso8 u_piso (
		 .clk(clk),
		 .clr_n(clr_n),
		 .load(load_en),
		 .shift(shift_en),
		 .parallel_in(parallel_in),
		 .serial_out(cipo)
	);
	
   // recepcao
   sipo8 u_sipo (
       .clk(clk),
       .clr_n(clr_n),
       .sample(sample_en),
       .last_bit(last_bit),
       .serial_in(copi),
       .parallel_out(parallel_out),
       .valid(rx_valid)
   );
	
endmodule

/*
Questão 3. Por que o registrador de transmissão deve ser atualizado em instantes diferentes daqueles utilizados
para amostrar os dados recebidos?
O dado transmitido e recebido não podem mudar no mesmo instante porque senão ele será alterado quando estiver sendo lido. O dado para ser amostrado precisa estar estável . Por isso são feitos em momentos diferentes, senão não na hora de amostrar não saberiamos se pegamos o dado antigo ou o atual. 
*/