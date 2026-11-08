module spi_system #(
    parameter integer DIV = 10
)(
    input  wire       clk,
    input  wire       clr_n,

    // controle da transferência
    input  wire       start,
    input  wire       peripheral_sel,
    output wire       busy,
    output wire       done,

    // controlador
    input  wire       ctrl_load,
    input  wire [7:0] ctrl_in,
    output wire [7:0] ctrl_out,

    // periférico 0
    input  wire       p0_load,
    input  wire [7:0] p0_in,
    output wire [7:0] p0_out,
    output wire       p0_rx_valid,

    // periférico 1
    input  wire       p1_load,
    input  wire [7:0] p1_in,
    output wire [7:0] p1_out,
    output wire       p1_rx_valid,

    // sinais SPI expostos para observação na waveform
    output wire       sclk,
    output wire       copi,
    output wire       cipo,
    output wire [1:0] cs_n
);

    wire cipo0, cipo1;

    // multiplexador de CIPO
    assign cipo = (!cs_n[0]) ? cipo0 :
                  (!cs_n[1]) ? cipo1 :
                  1'b0;

    // controlador 
    spi_controller #(.DIV(DIV)) u_ctrl (
        .clk(clk),
        .clr_n(clr_n),
        .parallel_load(ctrl_load),
        .parallel_in(ctrl_in),
        .parallel_out(ctrl_out),
        .start(start),
        .peripheral_sel(peripheral_sel),
        .sclk(sclk),
        .copi(copi),
        .cipo(cipo),
        .cs_n(cs_n),
        .busy(busy),
        .done(done)
    );

    // periferico 0
    spi_peripheral u_per0 (
        .clk(clk),
        .clr_n(clr_n),
        .parallel_load(p0_load),
        .parallel_in(p0_in),
        .parallel_out(p0_out),
        .rx_valid(p0_rx_valid),
        .sclk(sclk),
        .cs_n(cs_n[0]),
        .copi(copi),
        .cipo(cipo0)
    );

	 // periferico 1
    spi_peripheral u_per1 (
        .clk(clk),
        .clr_n(clr_n),
        .parallel_load(p1_load),
        .parallel_in(p1_in),
        .parallel_out(p1_out),
        .rx_valid(p1_rx_valid),
        .sclk(sclk),
        .cs_n(cs_n[1]),
        .copi(copi),
        .cipo(cipo1)
    );

endmodule