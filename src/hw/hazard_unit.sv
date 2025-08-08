module hazard_unit(
    input logic ID_AttemptBranch
    input logic EX_RegWrite,
    input logic EX_MemRead,
    input logic[4:0] EX_Rd,
    input logic[4:0] ID_Rs1,
    input logic[4:0] ID_Rs2,
    output logic flush,
    output logic[1:0] stall //can stall for 1 or 2 cycles
);
//Stalls: get implemented by preventing the pc register adn the IF/ID register from changing
//You also gotta set all control signals to 0 into the ID/EX pipeline registers
always_comb begin
    //Hazard 1: load instruction saving to a register used by a branch the next cycle
    if(EX_MemRead && ID_Branch && (EX_Rd != 5'b0) && (EX_Rd == ID_Rs1 || EX_Rd == ID_Rs2)) stall = 2'd2;
    //Hazard 2: instruction tries to read a register following a load instruction that writes the same register
    else if(EX_MemRead && (EX_Rd != 5'b0) && (EX_Rd == ID_Rs1 || EX_Rd == ID_Rs2)) stall = 2'd1;
    //Hazard 3: alu instruction in EX immediately preceding a branch produces an operand for the branch
    else if(ID_Branch && EX_RegWrite && (EX_Rd != 5'b0) && (EX_Rd == ID_Rs1 || EX_Rd == ID_Rs2)) stall = 2'd1;
    else stall = 2'd0;

end
//Flushes: what stall does but also gets rid of the instructions in IF stage

endmodule