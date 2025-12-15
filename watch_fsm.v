module watch_fsm (
    input  wire clk,
    input  wire rst,
    input  wire mode_btn,
    input  wire set_btn,

    output reg  [3:0] hh_t, hh_u, mm_t, mm_u,     // time
    output reg  [3:0] ah_t, ah_u, am_t, am_u,     // alarm

    output reg  en_sec_normal,
    output reg  en_sec_sw,

    output reg  save_split,

    output [7:0] set_mm, set_hh,

    output reg sel_hr,
    output reg sel_min,

    output reg sel_hr_sw,
    output reg sel_min_sw,

    output [1:0] state_out
);

/* Main states */
localparam NORMAL        = 3'd0;
localparam SET_TIME      = 3'd1;
localparam SET_ALARM     = 3'd2;
localparam STOPWATCH     = 3'd3;

/* Digit sub-states */
localparam D_HH_TENS     = 2'd0;
localparam D_HH_UNITS    = 2'd1;
localparam D_MM_TENS     = 2'd2;
localparam D_MM_UNITS    = 2'd3;

/* Stopwatch states */
localparam SW_IDLE       = 2'd0;
localparam SW_RUN        = 2'd1;
localparam SW_SPLIT      = 2'd2;
localparam SW_STOP       = 2'd3;

reg digit_sel;         // which digit is selected
reg [1:0] sw_state;    // stopwatch sub-FSM
reg [1:0] state;       // state FSM

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state     <= NORMAL;
        digit_sel <= D_HH_TENS;
        sw_state  <= SW_IDLE;
        sel_hr    <= 1;
        sel_min   <= 1;
        sel_hr_sw  <= 0;
        sel_min_sw <= 0;
        save_split <= 0;
    end else begin
        case (state)

        /* ================= NORMAL ================= */
        NORMAL: begin
            en_sec_normal <= 1;
            en_sec_sw <= 0;
            sel_min <= 1;
            sel_hr  <= 1;
            if (mode_btn) begin
                state   <= SET_TIME;
                sel_hr  <= 0;
                sel_min <= 0;
            end
        end

        /* ================= SET TIME ================= */
        SET_TIME: begin
            en_sec_normal <= 0;
            en_sec_sw <= 0;
            if (mode_btn) begin
                if (digit_sel == D_MM_UNITS) begin
                    digit_sel <= D_HH_TENS;
                    state     <= SET_ALARM;
                end else
                    digit_sel <= digit_sel + 1'b1;
            end
        end

        /* ================= SET ALARM ================= */
        SET_ALARM: begin
            en_sec_normal <= 1;
            en_sec_sw <= 0;
            sel_hr  <= 1;
            sel_min <= 1;
            if (mode_btn) begin
                if (digit_sel == D_MM_UNITS) begin
                    digit_sel <= D_HH_TENS;
                    state     <= STOPWATCH;
                end else begin
                    digit_sel <= digit_sel + 1'b1;
                end
            end
        end

        /* ================= STOPWATCH ================= */
        STOPWATCH: begin
            en_sec_normal = 1;
            en_sec_sw = 1;
            if (mode_btn)
                state <= NORMAL;
            else if (set_btn) begin
                case (sw_state)
                    SW_IDLE  : sw_state <= SW_RUN;
                    SW_RUN   : sw_state <= SW_SPLIT;
                    SW_SPLIT : sw_state <= SW_STOP;
                    SW_STOP  : sw_state <= SW_RUN;
                endcase
            end
        end

        endcase
    end
end


always @(posedge clk or posedge rst) begin
    if (rst) begin
        hh_t <= 0; hh_u <= 0;
        mm_t <= 0; mm_u <= 0;
    end else if (state == SET_TIME && set_btn) begin
        case (digit_sel)

        D_HH_TENS:
            hh_t <= (hh_t == 2) ? 0 : hh_t + 1;

        D_HH_UNITS:
            if (hh_t == 2)
                hh_u <= (hh_u == 3) ? 0 : hh_u + 1;
            else
                hh_u <= (hh_u == 9) ? 0 : hh_u + 1;

        D_MM_TENS:
            mm_t <= (mm_t == 5) ? 0 : mm_t + 1;

        D_MM_UNITS:
            mm_u <= (mm_u == 9) ? 0 : mm_u + 1;

        endcase
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ah_t <= 0; ah_u <= 0;
        am_t <= 0; am_u <= 0;
    end else if (state == SET_ALARM && set_btn) begin
        case (digit_sel)

        D_HH_TENS:
            ah_t <= (ah_t == 2) ? 0 : ah_t + 1;

        D_HH_UNITS:
            if (ah_t == 2)
                ah_u <= (ah_u == 3) ? 0 : ah_u + 1;
            else
                ah_u <= (ah_u == 9) ? 0 : ah_u + 1;

        D_MM_TENS:
            am_t <= (am_t == 5) ? 0 : am_t + 1;

        D_MM_UNITS:
            am_u <= (am_u == 9) ? 0 : am_u + 1;

        endcase
    end
end

always @(posedge clk or posedge rst) begin
    case(sw_state)

        SW_IDLE: begin
            sel_min_sw <= 0;
            sel_hr_sw  <= 0;
        end

        SW_RUN: begin
            sel_min_sw <= 1;
            sel_hr_sw  <= 1;
        end

        SW_SPLIT:
            save_split <= 1;

        SW_STOP: begin
            save_split <= 0;
            en_sec_sw  <= 0;
        end
    endcase
end

assign set_mm = mm_t*10 + mm_u;
assign set_hh = hh_t*10 + hh_u;
assign state_out = state;
endmodule