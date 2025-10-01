module mux_controller (
    input logic JB_PredictBranchTaken,
    input logic IF_Mispredict,
    input logic JB_Jump,
    output logic[1:0] MUX_Select
);
    always_comb begin
        if(IF_Mispredict) MUX_Select = 2'd2;
        else if(JB_PredictBranchTaken) MUX_Select = 2'd1;
        else if(JB_Jump) MUX_Select = 2'd3;
        else MUX_Select = 2'd0;
    end
endmodule