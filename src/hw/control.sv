module control (
    input logic[6:0] instruction,
    output logic AttemptBranch,
    output logic IsJALR,
    output logic Jump,
    output logic RegWrite,
    output logic MemToReg,
    output logic MemRead,
    output logic MemWrite,
    output logic[2:0] ALUOp,
    output logic Immediate,
    output logic Auipc
);
    localparam logic [6:0] nop =    7'b0000000;
    localparam logic [6:0] R_type = 7'b0110011;
    localparam logic [6:0] I_type = 7'b0010011;
    localparam logic [6:0] Branch = 7'b1100011;
    localparam logic [6:0] Loads =  7'b0000011;
    localparam logic [6:0] Stores = 7'b0100011;
    localparam logic [6:0] LUI =    7'b0110111;
    localparam logic [6:0] AUIPC =  7'b0010111;
    localparam logic [6:0] JAL =    7'b1101111;
    localparam logic [6:0] JALR =   7'b1100111;

always_comb begin
    AttemptBranch = '0;
    IsJALR = '0;
    Jump = '0;
    RegWrite = '0;
    MemToReg = '0;
    MemRead = '0;
    MemWrite = '0;
    ALUOp = '0;
    Immediate = '0;
    Auipc = '0;
    case(instruction[6:0]) 
        R_type: begin
            RegWrite = 1;
            ALUOp = 3'd0;
        end
        I_type: begin
            RegWrite = 1;
            Immediate = 1;
            ALUOp = 3'd1;
        end
        Branch: begin
            AttemptBranch = 1;
        end
        Loads: begin
            RegWrite = 1;
            ALUOp = 3'd3;
            MemToReg = 1;
            MemRead = 1;
            Immediate = 1;
        end
        Stores: begin
            ALUOp = 3'd3;
            MemWrite = 1;
            Immediate = 1;
        end
        LUI: begin
            RegWrite = 1;
            ALUOp = 3'd2;
            Immediate = 1;
        end
        AUIPC: begin
            RegWrite = 1;
            ALUOp = 3'd5;
            Immediate = 1;
            Auipc = 1;
        end
        JAL: begin
            RegWrite = 1;
            ALUOp = 3'd6;
            Jump = 1;
        end
        JALR: begin
            RegWrite = 1;
            ALUOp = 3'd6;
            Jump = 1;
            IsJALR = 1;
        end
        //had to add default cuz vivado was getting mad
        default: RegWrite = 0;
    endcase
end
endmodule