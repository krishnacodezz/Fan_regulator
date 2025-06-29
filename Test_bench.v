module TB_Fan_Regulator;
    reg clk;
    reg reset_n;
    reg up_tb;
    reg down_tb;
    wire [1:0] fan_speed_out_tb;

    // Instantiate the Unit Under Test (UUT)
    // Make sure this matches your actual module name (e.g., Fan_Regulator_Mealy or Fan_Regulator_Mealy_Simple)
    Fan_Regulator DUT (.clk(clk), .reset_n(reset_n), .up_in(up_tb), .down_in(down_tb), .fan_speed_out(fan_speed_out_tb));

    // Clock generation 
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initial Reset
        reset_n = 0; // Assert reset
        up_tb   = 0;
        down_tb = 0;
        #25;         // Hold reset for some time

        // Release Reset - Should go to OFF (00)
        reset_n = 1;
        #10;

        //  Go UP: OFF -> LOW -> MED -> HIGH
        up_tb = 1; down_tb = 0; #10; // UP -> LOW (output changes immediately)
        up_tb = 0; down_tb = 0; #10; // Stabilize in LOW state
        up_tb = 1; down_tb = 0; #10; // UP -> MED
        up_tb = 0; down_tb = 0; #10; // Stabilize in MED state
        up_tb = 1; down_tb = 0; #10; // UP -> HIGH
        up_tb = 0; down_tb = 0; #10; // Stabilize in HIGH state
        up_tb = 1; down_tb = 0; #10; // Giving UP input at high state, should be in high state only
        up_tb = 0; down_tb = 0; #10; // HIGH (output 11)

        //  Go DOWN: HIGH -> MED -> LOW -> OFF
        up_tb = 0; down_tb = 1; #10; // DOWN -> MED
        up_tb = 0; down_tb = 0; #10; // Stabilize in MED state
        up_tb = 0; down_tb = 1; #10; // DOWN -> LOW
        up_tb = 0; down_tb = 0; #10; // Stabilize in LOW state
        up_tb = 0; down_tb = 1; #10; // DOWN -> OFF
        up_tb = 0; down_tb = 0; #10; // Stabilize in OFF state
        up_tb = 0; down_tb = 1; #10; // Giving DOWN input at off state, should be in off state only
        up_tb = 0; down_tb = 0; #10; // OFF (output 00)
        
      
        #20; 
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t, Reset=%b, UP=%b, DOWN=%b, Fan_Speed=%b",
                 $time, reset_n, up_tb, down_tb, fan_speed_out_tb);
    end

endmodule
