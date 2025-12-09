module panel_memory(
    input  wire        clk,
    input  wire [11:0] addr_top,    // 0..4095
    input  wire [11:0] addr_bottom, // 0..4095
    
    // NUEVO: Selector (0, 1, 2, 3)
    input  wire [1:0]  image_sel,   
    
    output reg  [23:0] pix_top,
    output reg  [23:0] pix_bottom
);

    // Memoria expandida: 16,384 espacios (4 imágenes de 4096 píxeles)
    reg [23:0] MEM [0:16383]; 

    initial begin
        // Asegúrate de que este archivo exista (lo crearemos con Python)
        $readmemh("multi_image.hex", MEM); 
    end

    // Truco de dirección:
    // Ponemos los 2 bits del selector AL PRINCIPIO de la dirección.
    // Sel=0 -> Direcciones 0     a 4095
    // Sel=1 -> Direcciones 4096  a 8191 ...
    wire [13:0] final_addr_top    = {image_sel, addr_top};
    wire [13:0] final_addr_bottom = {image_sel, addr_bottom};

    always @(posedge clk) begin
        pix_top    <= MEM[final_addr_top];
        pix_bottom <= MEM[final_addr_bottom];
    end

endmodule
