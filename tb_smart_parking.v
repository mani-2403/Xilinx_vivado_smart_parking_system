`timescale 1ns / 1ps

module tb_smart_parking();

    // Inputs
    reg clk;
    reg rst_n;
    reg sensor_entry;
    reg sensor_exit;

    // Outputs
    wire gate_entry;
    wire gate_exit;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate the Unit Under Test (UUT)
    smart_parking_system uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .sensor_entry(sensor_entry), 
        .sensor_exit(sensor_exit), 
        .gate_entry(gate_entry), 
        .gate_exit(gate_exit), 
        .seg(seg), 
        .an(an)
    );

    // Clock Generation (100 MHz)
    always #5 clk = ~clk;

    // Task to simulate a car entering
    task simulate_car_entry;
        begin
            $display("Simulating Car Entry...");
            sensor_entry = 1; 
            #50; // Car sits at the gate (gate should open)
            sensor_entry = 0; 
            #50; // Car passes (count should decrement)
        end
    endtask

    // Task to simulate a car exiting
    task simulate_car_exit;
        begin
            $display("Simulating Car Exit...");
            sensor_exit = 1; 
            #50; // Car sits at the gate (gate should open)
            sensor_exit = 0; 
            #50; // Car passes (count should increment)
        end
    endtask

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        sensor_entry = 0;
        sensor_exit = 0;

        // Apply Reset
        #20;
        rst_n = 1;
        #20;

        $display("--- Starting Parking Simulation ---");

        // 1. Simulate 9 cars entering to fill the lot
        repeat(9) begin
            simulate_car_entry();
        end

        // Wait to observe FULL state
        $display("Lot should now be FULL.");
        #100;

        // 2. Try to add a 10th car (Gate should NOT open, count shouldn't change)
        $display("Attempting to enter while FULL...");
        sensor_entry = 1;
        #50;
        if (gate_entry == 0) $display("SUCCESS: Gate stayed closed.");
        sensor_entry = 0;
        #100;

        // 3. Simulate 2 cars exiting (Frees up slots)
        simulate_car_exit();
        simulate_car_exit();

        // 4. End Simulation
        #200;
        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule
