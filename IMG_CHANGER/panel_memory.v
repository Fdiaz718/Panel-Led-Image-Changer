module panel_memory (
    input  wire        clk,
    input  wire [11:0] addr_top,
    input  wire [11:0] addr_bottom,
    output reg  [23:0] pix_top,
    output reg  [23:0] pix_bottom
);

    reg [23:0] BACKGROUND_MEM [4095];
    reg [23:0] SPRITE_MEM     [4095];
    reg [23:0] TEXT_MEM       [4095];

    reg [23:0] background_top;
    reg [23:0] background_bottom;
    reg [23:0] sprite_top;
    reg [23:0] sprite_bottom;
    reg [23:0] text_top;
    reg [23:0] text_bottom;

    initial begin
        $readmemh("./images/waitingScreen.hex", BACKGROUND_MEM);
        $readmemh("./images/Truck.hex", SPRITE_MEM);
        $readmemh("./images/text.hex", TEXT_MEM);
    end

    always @(posedge clk) begin
        background_top    <= BACKGROUND_MEM[addr_top];
        background_bottom <= BACKGROUND_MEM[addr_bottom];
        sprite_top        <= SPRITE_MEM[addr_top];
        sprite_bottom     <= SPRITE_MEM[addr_bottom];
        text_top          <= TEXT_MEM[addr_top];
        text_bottom       <= TEXT_MEM[addr_bottom];
    end

    // Priority conditional
    always @* begin
        if (text_top != 24'h000000)
            pix_top = text_top;
        else if (sprite_top != 24'h000000)
            pix_top = sprite_top;
        else
            pix_top = background_top;

        if (text_bottom != 24'h000000)
            pix_bottom = text_bottom;
        else if (sprite_bottom != 24'h000000)
            pix_bottom = sprite_bottom;
        else
            pix_bottom = background_bottom;
    end

endmodule
