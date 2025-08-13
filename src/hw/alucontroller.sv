module alucontroller
(
    input logic[2:0] ALUOp,
    input logic[6:0] Funct7,
    input logic[2:0] Funct3,
    
    output logic[3:0] aluselect
);
    localparam logic [2:0] R_type = 3'd0;
    localparam logic [2:0] Immediate = 3'd1;
    localparam logic [2:0] LUI = 3'd2;
    localparam logic [2:0] loads_stores = 3'd3;
    //localparam logic [2:0] branches = 3'd4;
    localparam logic [2:0] AUIPC = 3'd5;
    localparam logic [2:0] jumps = 3'd6;

    localparam logic [3:0] Add = 4'd0;
    localparam logic [3:0] Sub = 4'd1;
    localparam logic [3:0] Shift_Left = 4'd2;
    localparam logic [3:0] Shift_Right_Logical = 4'd3;
    localparam logic [3:0] Shift_Right_Arithmetic = 4'd4;
    localparam logic [3:0] And = 4'd5;
    localparam logic [3:0] Or = 4'd6;
    localparam logic [3:0] Xor = 4'd7;
    localparam logic [3:0] SLT_S = 4'd8;
    localparam logic [3:0] SLT_U = 4'd9;
    // localparam logic [3:0] Is_Equal = 4'd10;
    // localparam logic [3:0] SGTE_S = 4'd11;
    // localparam logic [3:0] SGTE_U = 4'd12;
    localparam logic [3:0] In1_To_Out = 4'd10;
    //localparam logic [3:0] In0_To_Out = 4'd11;
    localparam logic [3:0] In0_To_Out_Plus_4 = 4'd11;
    localparam logic [3:0] Debug = 4'd15;

    always_comb begin
        aluselect = Debug;
        if(ALUOp == R_type) begin
            if(Funct7 == 7'b0000000) begin
                case(Funct3)
                    //ADD
                    3'b000: aluselect = Add;
                    //SLL
                    3'b001: aluselect = Shift_Left;
                    //SLT
                    3'b010: aluselect = SLT_S;
                    //SLTU
                    3'b011: aluselect = SLT_U;
                    //XOR
                    3'b100: aluselect = Xor;
                    //SRL
                    3'b101: aluselect = Shift_Right_Logical;
                    //OR
                    3'b110: aluselect = Or;
                    //AND
                    3'b111: aluselect = And;
                endcase 
            end
            else if(Funct7 == 7'b0100000) begin
                //SUB
                if (Funct3 == 3'b000) aluselect = Sub;
                //SRA
                else if(Funct3 == 3'b101) aluselect = Shift_Right_Arithmetic;
            end
        end
        else if(ALUOp == Immediate) begin
            case(Funct3)
                //ADDI
                3'b000: aluselect = Add;
                3'b001: begin
                    //SLLI
                    if(Funct7 == 7'b0000000) aluselect = Shift_Left;
                end
                //SLTI
                3'b010: aluselect = SLT_S;
                //SLTIU
                3'b011: aluselect = SLT_U;
                //XORI
                3'b100: aluselect = Xor;
                3'b101: begin
                    //SRLI
                    if(Funct7 == 7'b0000000) aluselect = Shift_Right_Logical;
                    //SRAI
                    else if(Funct7 == 7'b0100000) aluselect = Shift_Right_Arithmetic;
                end
                //ORI
                3'b110: aluselect = Or;
                //ANDI
                3'b111: aluselect = And;
            endcase
        end
        else if(ALUOp == LUI) begin
            //LUI
            aluselect = In1_To_Out;
        end
        else if(ALUOp == loads_stores) begin
            //LB, LH, LW, LBU, LHU, SB, SH, SW
            aluselect = Add;
        end
        else if(ALUOp == AUIPC) begin
            //AUIPC
            aluselect = Add;
        end
        else if(ALUOp == jumps) begin
            //JAL and JALR
            aluselect = In0_To_Out_Plus_4;
        end
        // else if(ALUOp == branches) begin
        //     case(Funct3)
        //         //BEQ
        //         3'b000: aluselect = Sub;
        //         //BNE
        //         3'b001: aluselect = Is_Equal;
        //         //BLT
        //         3'b100: aluselect = SGTE_S;
        //         //BGE
        //         3'b101: aluselect = SLT_S;
        //         //BLTU
        //         3'b110: aluselect = SGTE_U;
        //         //BGEU
        //         3'b111: aluselect = SLT_U;
        //         default: aluselect = Debug;
        //     endcase
        // end
    end

endmodule