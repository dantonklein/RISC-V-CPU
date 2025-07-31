module alu_data_forwarding_unit (
    input logic MEM_RegWrite,
    input logic WB_RegWrite,
    input logic[4:0] EX_Rs1,
    input logic[4:0] EX_Rs2,
    input logic[4:0] MEM_Rd,
    input logic[4:0] WB_Rd,
    output logic[1:0] forward_data1,
    output logic[1:0] forward_data2
);
    //output = 0 (data comes from pipeline register)
    //output = 1 (data comes from memory stage)
    //output = 2 (data comes from write back stage)
    //forwarding unit for alu input1
    always_comb begin
        if(MEM_RegWrite && (MEM_Rd != 5'd0) && (MEM_Rd == EX_Rs1)) forward_data1 = 2'd1;
        else if(WB_RegWrite && (WB_Rd != 5'd0) && (WB_Rd == EX_Rs1)) forward_data1 = 2'd2;
        else forward_data1 = 2'd0;
    end

    //forwarding unit for alu input2
    always_comb begin
        if(MEM_RegWrite && (MEM_Rd != 5'd0) && (MEM_Rd == EX_Rs2)) forward_data2 = 2'd1;
        else if(WB_RegWrite && (WB_Rd != 5'd0) && (WB_Rd == EX_Rs2)) forward_data2 = 2'd2;
        else forward_data2 = 2'd0;
    end
endmodule


module memory_data_forwarding_unit (
    input logic WB_RegWrite,
    input logic[4:0] MEM_Rs2,
    input logic[4:0] WB_Rd,
    output logic forward_data
);
    //output = 0 (data comes from pipeline register)
    //output = 1 (data comes from write back stage)

    //fowarding unit for lw -> sw
    always_comb begin
        if(WB_RegWrite && (WB_Rd != 5'd0) && (WB_Rd == MEM_Rs2)) forward_data = 1'b1;
        else forward_data = 1'b0;
    end

endmodule
