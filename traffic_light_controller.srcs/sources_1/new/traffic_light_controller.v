`timescale 1ns / 1ps

module traffic_light_controller (
    input wire clk,
    input wire reset,
    output reg [2:0] NL,
    output reg [2:0] SL,
    output reg [2:0] EL,
    output reg [2:0] WL
);

    // Light encodings
    localparam GREEN  = 3'b001;
    localparam YELLOW = 3'b010;
    localparam RED    = 3'b100;

    // FSM state encodings
    localparam N_G = 3'd0;
    localparam N_Y = 3'd1;
    localparam S_G = 3'd2;
    localparam S_Y = 3'd3;
    localparam E_G = 3'd4;
    localparam E_Y = 3'd5;
    localparam W_G = 3'd6;
    localparam W_Y = 3'd7;

    reg [2:0] current_state, next_state;

    // Timer
    reg [3:0] timer_count;
    wire timer_done;

    localparam COUNT_GREEN  = 4'd8;
    localparam COUNT_YELLOW = 4'd4;

    assign timer_done = (timer_count == 4'd0);

    // ---------------- TIMER ----------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            timer_count <= COUNT_GREEN;
        end else begin
            if (timer_count > 0)
                timer_count <= timer_count - 1;
            else begin
                case (next_state)
                    N_G, S_G, E_G, W_G: timer_count <= COUNT_GREEN;
                    N_Y, S_Y, E_Y, W_Y: timer_count <= COUNT_YELLOW;
                    default: timer_count <= COUNT_GREEN;
                endcase
            end
        end
    end

    // ---------------- STATE REGISTER ----------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= N_G;
        else
            current_state <= next_state;
    end

    // ---------------- NEXT STATE LOGIC ----------------
    always @(*) begin
        next_state = current_state;

        if (timer_done) begin
            case (current_state)
                N_G: next_state = N_Y;
                N_Y: next_state = S_G;

                S_G: next_state = S_Y;
                S_Y: next_state = E_G;

                E_G: next_state = E_Y;
                E_Y: next_state = W_G;

                W_G: next_state = W_Y;
                W_Y: next_state = N_G;

                default: next_state = N_G;
            endcase
        end
    end

    // ---------------- OUTPUT LOGIC ----------------
    always @(*) begin
        NL = RED; SL = RED; EL = RED; WL = RED;

        case (current_state)
            N_G: NL = GREEN;
            N_Y: NL = YELLOW;

            S_G: SL = GREEN;
            S_Y: SL = YELLOW;

            E_G: EL = GREEN;
            E_Y: EL = YELLOW;

            W_G: WL = GREEN;
            W_Y: WL = YELLOW;
        endcase
    end

endmodule
