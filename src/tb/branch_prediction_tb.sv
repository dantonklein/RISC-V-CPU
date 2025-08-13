module branch_prediction_tb;
logic clk;
logic rst;
logic[2:0] index;

logic ID_BranchTaken;
logic ID_AttemptBranch;

logic ID_PredictBranchTaken;

branch_prediction #(
    .table_width(3)
) DUT (
    .ID_PC_Slice(index),
    .ID_BranchTaken(ID_BranchTaken),
    .ID_AttemptBranch(ID_AttemptBranch),
    .clk(clk),
    .rst(rst),
    .ID_PredictBranchTaken(ID_PredictBranchTaken)
);

//Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    //I know using non-blocking signals to assert inputs is what you are supposed to do so I apologize Dr. Stitt
    //I dont want to wait 2 cycles to see the bht change

    initial begin
        index = 3'd0;
        ID_BranchTaken = 0;
        ID_AttemptBranch = 0;
        rst = 1;
        @(posedge clk);

        rst = 0;
        @(posedge clk);

        ID_AttemptBranch = 1;
        ID_BranchTaken = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        ID_BranchTaken = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        index = 3'd1;
        ID_BranchTaken = 1;
        @(posedge clk);
        ID_BranchTaken = 0;
        @(posedge clk);

        disable generate_clk;
    end
endmodule