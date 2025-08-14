module hazard_unit_tb;
    logic clk;
    logic rst;

    logic ID_AttemptBranch;
    logic ID_BranchTaken;
    logic ID_PredictBranchTaken;
    logic ID_IsJALR;
    logic EX_RegWrite;
    logic EX_MemRead;
    logic[4:0] EX_Rd;
    logic[4:0] ID_Rs1;
    logic[4:0] ID_Rs2;
    logic flush;
    logic mispredict;
    logic ID_Stall;

    hazard_unit DUT (
        .ID_AttemptBranch(ID_AttemptBranch),
        .ID_BranchTaken(ID_BranchTaken),
        .ID_PredictBranchTaken(ID_PredictBranchTaken),
        .ID_IsJALR(ID_IsJALR),
        .EX_RegWrite(EX_RegWrite),
        .EX_MemRead(EX_MemRead),
        .EX_Rd(EX_Rd),
        .ID_Rs1(ID_Rs1),
        .ID_Rs2(ID_Rs2),
        .flush(flush),
        .mispredict(mispredict),
        .ID_Stall(ID_Stall),
        .rst(rst),
        .clk(clk)
    );

    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
        rst <= 1;
        ID_AttemptBranch <= '0;
        ID_BranchTaken <= '0;
        ID_PredictBranchTaken <= '0;
        ID_IsJALR <= '0;
        EX_RegWrite <= '0;
        EX_MemRead <= '0;
        EX_Rd <= '0;
        ID_Rs1 <= '0;
        ID_Rs2 <= '0;
        @(posedge clk);
        rst <= 0;
        @(posedge clk);
        //Test Hazards
        $display("Hazard 1");
        //Hazard 1
        EX_MemRead <= 1;
        ID_AttemptBranch <= 1;
        EX_Rd <= 5'd3;
        ID_Rs1 <= 5'd3;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);
        EX_Rd <= 5'd0;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);

        $display("Hazard 2");
        //Hazard 2
        EX_MemRead <= 1;
        ID_AttemptBranch <= 0;
        ID_IsJALR <= 1;
        EX_Rd <= 5'd4;
        ID_Rs1 <= 5'd4;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);
        EX_Rd <= 5'd0;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);

        $display("Hazard 3");
        //Hazard 3
        ID_AttemptBranch <= 0;
        ID_IsJALR <= 0;
        EX_MemRead <= 1;
        EX_Rd <= 5'd5;
        ID_Rs1 <= 5'd5;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);
        EX_Rd <= 5'd0;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);

        $display("Hazard 4");
        //Hazard 4
        ID_AttemptBranch <= 1;
        EX_MemRead <= 0;
        EX_RegWrite <= 1;
        EX_Rd <= 5'd6;
        ID_Rs1 <= 5'd6;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);
        EX_Rd <= 5'd0;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);


        $display("Hazard 5");
        //Hazard 5
        ID_AttemptBranch <= 0;
        ID_IsJALR <= 1;
        EX_RegWrite <= 1;
        EX_Rd <= 5'd7;
        ID_Rs1 <= 5'd7;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);
        EX_Rd <= 5'd0;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);


        $display("Test Flush");
        //Test Flush Situation 
        ID_IsJALR <= 0;
        ID_AttemptBranch <= 1;
        EX_Rd <= 5'd0;
        ID_Rs1 <= 5'd0;
        ID_BranchTaken <= 1;
        ID_PredictBranchTaken <= 0;
        @(posedge clk);
        $display("Stall:%d flush:%b",ID_Stall, flush);

        disable generate_clk;
    end
endmodule