module hazard_unit(
    input logic JB_AttemptBranch,
    input logic JB_BranchTaken,
    input logic JB_PredictBranchTaken,
    input logic JB_Jump,
    input logic ID_AttemptBranch,
    input logic ID_IsJALR,
    //input logic EX_RegWrite,
    input logic EX_MemRead,
    input logic[4:0] EX_Rd,
    input logic[4:0] ID_Rs1,
    input logic[4:0] ID_Rs2,
    input logic clk,
    input logic rst,
    output logic flush,
    output logic mispredict,
    output logic JB_Stall //can stall for 1 or 2 cycles
);
logic [7:0] stall_amount;
logic [7:0] stall_count, next_stall_count;

//State machine to count down when a stall is initiated
typedef enum logic {
    IDLE,
    COUNT_DOWN
} state_t;
state_t state_r, next_state;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state_r <= IDLE;
        stall_count <= '0;
    end
    else begin
        state_r <= next_state;
        stall_count <= next_stall_count;
    end
end

always_comb begin
    next_state = state_r;
    next_stall_count = stall_count;
    case (state_r) 
        IDLE: begin
            if(stall_amount == 8'd0) JB_Stall = 0;
            else begin
                JB_Stall = 1;
                next_state = COUNT_DOWN;
                next_stall_count = stall_amount - 1;
            end
        end

        COUNT_DOWN: begin
            if(stall_count == 8'd0) begin
                JB_Stall = 0;
                next_state = IDLE;
            end
            else begin
                JB_Stall = 1;
                next_stall_count = stall_count - 1;
            end
        end
    endcase
end
//Stalls: get implemented by preventing the pc register adn the IF/ID register from changing
//You also gotta set all control signals to 0 into the ID/EX pipeline registers
always_comb begin
    //Hazard 1: load instruction saving to a register used by a branch the next cycle
    if(EX_MemRead && ID_AttemptBranch && (EX_Rd != 5'b0) && (EX_Rd == ID_Rs1 || EX_Rd == ID_Rs2)) stall_amount = 8'd1;
    //Hazard 2: load instruction saving to a register used by a jump the next cycle
    else if(EX_MemRead && ID_IsJALR && (EX_Rd != 5'b0) && (EX_Rd == ID_Rs1)) stall_amount = 8'd1;
    //Hazard 3: instruction tries to read a register following a load instruction that writes the same register
    else if(EX_MemRead && (EX_Rd != 5'b0) && (EX_Rd == ID_Rs1 || EX_Rd == ID_Rs2)) stall_amount = 8'd1;
    //Hazard 4: alu instruction in EX immediately preceding a branch produces an operand for the branch
    //else if(ID_AttemptBranch && EX_RegWrite && (EX_Rd != 5'b0) && (EX_Rd == ID_Rs1 || EX_Rd == ID_Rs2)) stall_amount = 8'd1;
    //Hazard 5: alu instruction in EX immediately preceding a jump produces an operand for the jump
    //else if(ID_IsJALR && EX_RegWrite && (EX_Rd != 5'b0) && (EX_Rd == ID_Rs1)) stall_amount = 8'd1;
    else stall_amount = 2'd0;

end
//Flushes: what stall does but also gets rid of the instruction in IF/ID pipeline
//mispredict seems redundant rn but when i introduce exceptions/interrupts it will differ from flushing
always_comb begin
    mispredict = 0;
    flush = 0;
    if(JB_AttemptBranch && (JB_BranchTaken != JB_PredictBranchTaken)) begin
        flush = 1;
        mispredict = 1;
    end
    //jump handling
    else if(JB_Jump) flush = 1;
end
endmodule