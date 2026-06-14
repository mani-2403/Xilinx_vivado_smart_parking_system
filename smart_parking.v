`timescale 1ns / 1ps

module smart_parking_system (
    input wire clk,           // 100 MHz clock
    input wire rst_n,         // Active-low reset
    input wire sensor_entry,  // HIGH when car is at the entry gate
    input wire sensor_exit,   // HIGH when car is at the exit gate
    output wire gate_entry,   // HIGH to open entry gate
    output wire gate_exit,    // HIGH to open exit gate
    output wire [6:0] seg,    // 7-segment display segments (CG to CA)
    output wire [3:0] an      // 7-segment display anodes
);

    // --- Parameters ---
    parameter MAX_CARS = 4'd9;
    
    // --- Internal Registers ---
    reg [3:0] available_slots;
    reg s_entry_d, s_exit_d;
    reg [16:0] refresh_counter; // For 7-segment multiplexing (~762 Hz)
    reg [6:0] seg_reg;
    reg [3:0] an_reg;

    // --- 1. Sensor Edge Detection (Prevent Over-counting) ---
    // We register the sensor inputs to detect when a car LEAVES the sensor (falling edge).
    // This ensures we only count the car once it has fully passed the gate.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_entry_d <= 0;
            s_exit_d <= 0;
        end else begin
            s_entry_d <= sensor_entry;
            s_exit_d <= sensor_exit;
        end
    end

    wire car_entered = ~sensor_entry & s_entry_d; // Falling edge
    wire car_exited = ~sensor_exit & s_exit_d;    // Falling edge

    // --- 2. Slot Counter FSM ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            available_slots <= MAX_CARS;
        end else begin
            // If car enters and lot is not full
            if (car_entered && !car_exited && available_slots > 0)
                available_slots <= available_slots - 1;
            // If car exits and lot is not empty
            else if (car_exited && !car_entered && available_slots < MAX_CARS)
                available_slots <= available_slots + 1;
            // If a car enters and exits exactly simultaneously, the count stays the same.
        end
    end

    // --- 3. Automatic Gate Control ---
    // Entry gate opens if a car is there AND there is space.
    // Exit gate opens if a car is there AND the lot isn't somehow already completely empty.
    assign gate_entry = sensor_entry && (available_slots > 0);
    assign gate_exit  = sensor_exit && (available_slots < MAX_CARS);

    // --- 4. 7-Segment Display Multiplexer ---
    // Generate a slower clock for multiplexing the 4 digits
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end
    
    wire [1:0] led_activating_counter = refresh_counter[16:15];

    // Active-Low segment mapping: seg[6]=CG, seg[0]=CA
    always @(*) begin
        if (available_slots == 0) begin
            // Display "FULL"
            case(led_activating_counter)
                2'b00: begin an_reg = 4'b0111; seg_reg = 7'b0001110; end // F
                2'b01: begin an_reg = 4'b1011; seg_reg = 7'b1000001; end // U
                2'b10: begin an_reg = 4'b1101; seg_reg = 7'b1000111; end // L
                2'b11: begin an_reg = 4'b1110; seg_reg = 7'b1000111; end // L
            endcase
        end else begin
            // Display "[blank] [blank] [blank] [Number]"
            case(led_activating_counter)
                2'b00: begin an_reg = 4'b0111; seg_reg = 7'b1111111; end // Blank
                2'b01: begin an_reg = 4'b1011; seg_reg = 7'b1111111; end // Blank
                2'b10: begin an_reg = 4'b1101; seg_reg = 7'b1111111; end // Blank
                2'b11: begin
                    an_reg = 4'b1110; // Rightmost digit active
                    case(available_slots)
                        4'd1: seg_reg = 7'b1111001; // 1
                        4'd2: seg_reg = 7'b0100100; // 2
                        4'd3: seg_reg = 7'b0110000; // 3
                        4'd4: seg_reg = 7'b0011001; // 4
                        4'd5: seg_reg = 7'b0010010; // 5
                        4'd6: seg_reg = 7'b0000010; // 6
                        4'd7: seg_reg = 7'b1111000; // 7
                        4'd8: seg_reg = 7'b0000000; // 8
                        4'd9: seg_reg = 7'b0010000; // 9
                        default: seg_reg = 7'b1000000; // 0
                    endcase
                end
            endcase
        end
    end

    assign seg = seg_reg;
    assign an  = an_reg;

endmodule
