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
    logic[DATA_WIDTH-1:0] extended;
    always_comb begin
        if(inst[6] == 1'b1) begin
            immediate = {inst[31],inst[7],inst[30:25], inst[11:8]};
        end
        else begin
            if(inst[5] == 1'b1) begin
                immediate = {inst[31:25], inst[11:7]};
            end
            else begin
                immediate = inst[31:20];
            end
        end
    end

    sign_extend #(
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_WIDTH(12)
    ) signextend (
        .in(immediate),
        .out(extended)
    );

    always_comb begin
        if(inst[6] == 1'b1) extended_immediate = extended <<< 1;
        else extended_immediate = extended;
    end
endmodule