//This file contains the module that decides on what bits to sign extend based on the instruction
module immgen 
#(
    parameter int DATA_WIDTH = 32
)
(
    input logic[31:0] inst,
    output logic[DATA_WIDTH-1:0] extended_immediate
);
    logic[11:0] immediate;
    logic[19:0] u_type_immediate;
    logic[19:0] jal_immediate;
    logic[DATA_WIDTH-1:0] extended;
    logic[DATA_WIDTH-1:0] jal_extended;
    always_comb begin
        u_type_immediate = '0;
        immediate = '0;
        jal_immediate = '0;
        if(inst[6:0] == 7'b1100011) //B-Type
            immediate = {inst[31], inst[7], inst[30:25], inst[11:8]};
        else if (inst[6:0] == 7'b0100011) //S-Type
            immediate = {inst[31:25], inst[11:7]};
        else if (inst[6:0] == 7'b0000011 || inst[6:0] == 7'b1110011 || inst[6:0] == 7'b0010011 || inst[6:0] == 7'b0001111) //I-type
            immediate = inst[31:20];
        else if (inst[6:0] == 7'b0110111 || inst[6:0] == 7'b0010111) //U-Type
            u_type_immediate = inst[31:12];
        else if (inst[6:0] == 7'b1101111) //JAL
            jal_immediate = {inst[31], inst[19:12], inst[20], inst[30:21]};
        
    end

    sign_extend #(
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_WIDTH(12)
    ) signextend (
        .in(immediate),
        .out(extended)
    );
    sign_extend #(
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_WIDTH(20)
    ) signextend_jal (
        .in(jal_immediate),
        .out(jal_extended)
    );
    always_comb begin
        //For LUI and AUIPC
        if(inst[6:0] == 7'b0110111 || inst[6:0] == 7'b0010111) extended_immediate = {u_type_immediate, 12'd0};
        //For JAL
        else if(inst[6:0] == 7'b1101111) extended_immediate = jal_extended <<< 1;
        //For branch instructions
        else if(inst[6:0] == 7'b1100011) extended_immediate = extended <<< 1;
        //for SLLI, SRLI, and SRAI
        else if(inst[14:12] == 3'b001 || inst[14:12] == 3'b101) extended_immediate = {27'd0, extended[4:0]};
        //for the remaining I type instructions
        else extended_immediate = extended;
    end
endmodule