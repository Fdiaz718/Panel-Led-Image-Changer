module top(
    input  wire clk,
    input  wire rst,
    input  wire btn,  // Botón en R7

    output wire r0, g0, b0,
    output wire r1, g1, b1,
    output wire [4:0] addr,
    output wire clk_out,
    output wire latch,
    output wire oe
);

    // Cables estándar
    wire [5:0] col;
    wire [4:0] scan_row;
    wire [4:0] display_row;
    wire [5:0] row_top;
    wire [5:0] row_bottom;
    wire [7:0] pwm_level; 
    
    // ==========================================
    // 1. LÓGICA DEL BOTÓN (Cambio de Imagen)
    // ==========================================
    wire btn_pulse;           // Señal limpia (un solo pulso)
    reg [1:0] image_selector; // Contador 0..3

    // Limpiador de ruido
    debounce BTN_DB (
        .clk(clk),
        .btn_in(btn),
        .btn_pulse(btn_pulse)
    );

    // Contador que cambia al pulsar
    always @(posedge clk) begin
        if (rst) begin
            image_selector <= 0;
        end else if (btn_pulse) begin
            image_selector <= image_selector + 1;
        end
    end

    // ==========================================
    // 2. MÓDULOS PRINCIPALES
    // ==========================================

    scan_counters SC(
        .clk(clk),
        .rst(rst),
        .col(col),
        .scan_row(scan_row),
        .addr_out(display_row),
        .pwm_level(pwm_level),
        .row_top(row_top),
        .row_bottom(row_bottom)
    );
    assign addr = display_row;

    // Conectamos la memoria con el selector
    wire [11:0] addr_top    = {row_top,    col};
    wire [11:0] addr_bottom = {row_bottom, col};
    wire [23:0] pix_top;
    wire [23:0] pix_bottom;

    panel_memory MEM(
        .clk(clk),
        .addr_top(addr_top),
        .addr_bottom(addr_bottom),
        .image_sel(image_selector), // <--- AQUÍ ENTRA TU BOTÓN
        .pix_top(pix_top),
        .pix_bottom(pix_bottom)
    );

    panel_pwm PWM(
        .pix_top(pix_top),
        .pix_bottom(pix_bottom),
        .pwm_level(pwm_level), 
        .r0(r0), .g0(g0), .b0(b0),
        .r1(r1), .g1(g1), .b1(b1)
    );

    delay_unit DU(
        .clk(clk),
        .rst(rst),
        .col(col),
        .clk_out(clk_out),
        .latch(latch),
        .oe(oe)
    );

endmodule
