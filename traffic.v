module traffic_controller (
    input clk,
    input rst,
    output reg [2:0] main_st, // Main street traffic light state
    output reg [2:0] cross_st, // Cross street traffic light state
    output reg [4:0] light_count // Counter for traffic light timing
);
    // State encoding
    parameter g_to_r = 2'b00,
              y_to_r = 2'b01,
              r_to_g = 2'b10,
              r_to_y = 2'b11;

    // State register
    reg [1:0] state_reg;

    initial begin
        light_count = 0;
    end

    // Traffic light timing
    // main green   = 15 sec
    // main yellow  = 3 sec
    // cross green  = 10 sec
    // cross yellow = 3 sec

    // Light count timing logic
    always @ (posedge clk or posedge rst) begin
        if (rst)
            light_count = 4'b0000;
        else if (light_count == 31)
            light_count <= 0;
        else
            light_count <= light_count + 1;
    end

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            state_reg <= g_to_r;
        else
            case (state_reg)
                g_to_r: if (light_count == 15) state_reg <= y_to_r;
                y_to_r: if (light_count == 18) state_reg <= r_to_g;
                r_to_g: if (light_count == 28) state_reg <= r_to_y;
                r_to_y: if (light_count == 31) state_reg <= g_to_r;
            endcase
    end

    // Traffic light state logic
    always @(posedge clk) begin
        case (state_reg)
            g_to_r: begin
                main_st <= 3'b001;  // Main street green
                cross_st <= 3'b100; // Cross street red
            end
            y_to_r: begin
                main_st = 3'b010;   // Main street yellow
                cross_st = 3'b100;  // Cross street red
            end
            r_to_g: begin
                main_st <= 3'b100;  // Main street red
                cross_st <= 3'b001; // Cross street green
            end
            r_to_y: begin
                main_st <= 3'b100;  // Main street red
                cross_st = 3'b010;  // Cross street yellow
            end
        endcase
    end
endmodule
