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
    logic[21:0] u_type_immediate;
    logic[DATA_WIDTH-1:0] extended;
    always_comb begin
        u_type_immediate = '0;
        immediate = '0;
        if(inst[6:0] == 7'b1100011) //B-Type
            immediate = {inst[31], inst[7], inst[30:25], inst[11:8]};
        else if (inst[6:0] == 7'b0100011) //S-Type
            immediate = {inst[31:25], inst[11:7]};
        else if (inst[6:0] == 7'b0000011 || inst[6:0] == 7'b1110011 || inst[6:0] == 7'b0010011 || inst[6:0] == 7'b0001111) //I-type
            immediate = inst[31:20];
        else if (inst[4:2] == 3'b101) //U-Type
            u_type_immediate = inst[31:12];
        else if (inst[6:0] == 7'b1101111) //J-type
            u_type_immediate = {inst[31], inst[19:12], inst[20], inst[30:21]};

    end

    sign_extend #(
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_WIDTH(12)
    ) signextend (
        .in(immediate),
        .out(extended)
    );

    always_comb begin
        if(inst[4:2] == 3'b101) extended_immediate = {u_type_immediate, 12'd0};
        else if(inst[6:0] == 7'b1101111) extended_immediate = {11'd0, u_type_immediate, 1'd0};
        else if(inst[6:2] == 5'b11000) extended_immediate = extended <<< 1;
        else extended_immediate = extended;
    end
endmodule