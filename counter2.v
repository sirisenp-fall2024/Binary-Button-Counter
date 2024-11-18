module top(
    input clk,
    input wire resetn,
    input wire btn1,
    output reg [5:0] led
);
reg [5:0] ledCounter = 6'b0;
reg btn1_sync0, btn1_sync1;
reg btn1_last;
reg [19:0] btn_debounce_counter = 20'b0;
reg btn_stable = 1'b0;  

reg [9:0] clk_div = 10'd0;
wire clk_slow;

always @(posedge clk or negedge resetn) begin
    if (!resetn)
        clk_div <= 10'd0;
    else
        clk_div <= clk_div + 1;
end

assign clk_slow = clk_div[9];

 // Combined logic for synchronization, edge detection, and counter update
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
            // Reset all registers to their default state
        btn1_sync0 <= 1'b0;
        btn1_sync1 <= 1'b0;
        btn1_last <= 1'b0;
        btn_debounce_counter <= 20'b0;
        btn_stable <= 1'b0;
        ledCounter <= 6'b0;
        led <= 6'b0;
    end else begin
            // Synchronize button signal
        btn1_sync0 <= btn1;
        btn1_sync1 <= btn1_sync0;

        if (btn1_sync1 != btn_stable) begin
            btn_debounce_counter <= btn_debounce_counter + 1;
            if (btn_debounce_counter == 20'hFFFF) begin
                btn_stable <= btn1_sync1;
            end
        end else begin
            btn_debounce_counter <= 20'b0;
        end

            // Rising edge detection for button press
        if (btn_stable && !btn1_last) begin
            ledCounter <= ledCounter + 1;
        end

            // Store the last button state
        btn1_last <= btn_stable;

            // Update LED output with inverted counter
        led <= ~ledCounter;
    end
end

endmodule