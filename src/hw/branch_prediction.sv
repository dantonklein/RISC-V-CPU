module branch_prediction #(
    parameter int table_width = 3
)(
    input logic[table_width-1:0] ID_PC_Slice, //PC[4:2]
    input logic ID_BranchTaken,
    input logic ID_AttemptBranch,

    input logic clk,
    input logic rst,

    output logic ID_PredictBranchTaken

);
    localparam logic [1:0] Strongly_Not_Taken = 2'b00;
    localparam logic [1:0] Weakly_Not_Taken = 2'b01;
    localparam logic [1:0] Weakly_Taken = 2'b10;
    localparam logic [1:0] Strongly_Taken = 2'b11;

    localparam int table_size = 2 ** table_width;

    logic [table_width-1:0] bht [table_size-1:0];

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            for(int i = 0; i < table_size; i++) begin
                bht[i] <= Weakly_Not_Taken; //Start in the Weakly Not Taken state
            end
        end else begin
            //Array Of Saturation Counters
            if(ID_AttemptBranch) begin
                if(ID_BranchTaken) begin
                    //increment unless full
                    if(bht[ID_PC_Slice] != Strongly_Taken) bht[ID_PC_Slice] <= bht[ID_PC_Slice] + 1;
                end else begin
                    //decrement unless empty
                    if(bht[ID_PC_Slice] != Strongly_Not_Taken) bht[ID_PC_Slice] <= bht[ID_PC_Slice] - 1;
                end
                
            end
        end
    end
    //left bit of bht slot used to predict if a branch is taken.
    assign ID_PredictBranchTaken = bht[ID_PC_Slice][1];

endmodule