module Fan_Regulator(
    input wire clk,
    input wire reset_n,    // Asynchronous active-low reset
    input wire up_in,      
    input wire down_in,    
    output wire [1:0] fan_speed_out // 2-bit output for fan speed (00=OFF, 01=LOW, 10=MED, 11=HIGH)
);

    // State definitions using parameter
    parameter S_OFF  = 2'b00, S_LOW  = 2'b01, S_MED  = 2'b10, S_HIGH = 2'b11

    // Internal state registers
    reg [1:0] current_state; 
    reg [1:0] next_state;    

    // Internal output register (for Mealy output logic)
    reg [1:0] fan_speed_reg; // Output is combinational, but held in a reg for assignment

    // State Register Logic (Synchronous Sequential Logic)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin 
            current_state <= S_OFF; 
        end else begin
            current_state <= next_state; 
        end
    end

   
    // Next State Logic and Output Logic (Combinational Logic)
    always @(*) begin
        next_state = current_state; // Default: stay in current state if no valid input
        fan_speed_reg = S_OFF;      // Default: output OFF (will be overridden by case statement)

        // Priority for inputs: UP > DOWN if both are asserted
        if (up_in && !down_in) begin // Only UP asserted
            case (current_state)
                S_OFF  : next_state = S_LOW;
                S_LOW  : next_state = S_MED;
                S_MED  : next_state = S_HIGH;
                S_HIGH : next_state = S_HIGH; // Stays at max speed
            endcase
        end else if (down_in && !up_in) begin // Only DOWN asserted
            case (current_state)
                S_OFF  : next_state = S_OFF; // Stays at min speed
                S_LOW  : next_state = S_OFF;
                S_MED  : next_state = S_LOW;
                S_HIGH : next_state = S_MED;
            endcase
        end
        // else if (!up_in && !down_in) or (up_in && down_in) : next_state remains current_state (no change)

        case (current_state)
            S_OFF: begin
                if (up_in && !down_in) fan_speed_reg = S_LOW; 
                else fan_speed_reg = S_OFF;
            end
            S_LOW: begin
                if (up_in && !down_in) fan_speed_reg = S_MED;   
                else if (down_in && !up_in) fan_speed_reg = S_OFF;
                else fan_speed_reg = S_LOW;
            end
            S_MED: begin
                if (up_in && !down_in) fan_speed_reg = S_HIGH;
                else if (down_in && !up_in) fan_speed_reg = S_LOW;
                else fan_speed_reg = S_MED;
            end
            S_HIGH: begin
                if (down_in && !up_in) fan_speed_reg = S_MED;
                else fan_speed_reg = S_HIGH;
            end
            default: fan_speed_reg = S_OFF; // Should not happen
        endcase
    end

    assign fan_speed_out = fan_speed_reg;

endmodule
