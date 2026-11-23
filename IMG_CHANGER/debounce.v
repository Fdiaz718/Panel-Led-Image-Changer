module debounce (
    input wire clk,
    input wire btn_in,
    output reg btn_pulse
);
    // Espera ~20ms para confirmar que la pulsación es real
    parameter DELAY = 500_000; 

    reg [18:0] counter;
    reg stable_state;
    reg btn_sync_0, btn_sync_1;

    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;

        if (btn_sync_1 != stable_state) begin
            counter <= counter + 1;
            if (counter == DELAY) begin
                stable_state <= btn_sync_1;
                counter <= 0;
            end
        end else begin
            counter <= 0;
        end
    end

    reg stable_old;
    always @(posedge clk) begin
        stable_old <= stable_state;
        // Detectar bajada (presionar botón)
        btn_pulse <= (stable_old == 1 && stable_state == 0);
    end
endmodule
