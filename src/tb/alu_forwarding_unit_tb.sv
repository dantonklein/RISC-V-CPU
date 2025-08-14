module alu_forwarding_unit_tb #(

);
    logic clk;

    logic MEM_RegWrite;
    logic WB_RegWrite;
    logic[4:0] EX_Rs;
    logic[4:0] MEM_Rd;
    logic[4:0] WB_Rd;
    logic[1:0] forward_data;

    alu_data_forwarding_unit DUT (
        .MEM_RegWrite(MEM_RegWrite),
        .WB_RegWrite(WB_RegWrite),
        .EX_Rs(EX_Rs),
        .MEM_Rd(MEM_Rd),
        .WB_Rd(WB_Rd),
        .forward_data(forward_data)
    );
    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
        MEM_RegWrite <= '0;
        WB_RegWrite <= '0;
        EX_Rs <= '0;
        MEM_Rd <= '0;
        WB_Rd <= '0;
        @(posedge clk);
        //Test data coming from the memory stage
        MEM_RegWrite <= 1'b1;
        MEM_Rd <= 5'd3;
        EX_Rs <= 5'd3;
        @(posedge clk);
        $display("mem stage forward_data: %d", forward_data);

        //Test data coming from write-back stage
        MEM_RegWrite <= 1'b0;
        WB_RegWrite <= 1'b1;
        EX_Rs <= 5'd4;
        WB_Rd <= 5'd4;
        @(posedge clk);
        $display("wb stage forward_data: %d", forward_data);

        //Test situation where both mem and wb could forward data
        MEM_RegWrite <= 1'b1;
        WB_RegWrite <= 1'b1;
        MEM_Rd <= 5'd5;
        WB_Rd <= 5'd5;
        EX_Rs <= 5'd5;
        @(posedge clk);
        $display("both wb and mem available forward_data: %d", forward_data);

        //Edge Case 1 mem and ex point to same register, regwrite is 0
        MEM_RegWrite <= 1'b0;
        WB_RegWrite <= 1'b0;
        MEM_Rd <= 5'd3;
        WB_Rd <= 5'd1;
        EX_Rs <= 5'd3;
        @(posedge clk);
        $display("edge case 1 forward_data: %d", forward_data);

        //Edge Case 2 mem regwrite is 1, mem points to zero
        MEM_RegWrite <= 1'b1;
        WB_RegWrite <= 1'b0;
        MEM_Rd <= 5'd0;
        WB_Rd <= 5'd3;
        EX_Rs <= 5'd3;
        @(posedge clk);
        $display("edge case 2 forward_data: %d", forward_data);
        
        //Edge Case 3 wb regwrite is 1, mem points to 3, wb points to 0, ex points to 3
        MEM_RegWrite <= 1'b0;
        WB_RegWrite <= 1'b1;
        MEM_Rd <= 5'd3;
        WB_Rd <= 5'd0;
        EX_Rs <= 5'd3;
        @(posedge clk);
        $display("edge case 3 forward_data: %d", forward_data);

        //Edge Case 4 wb and mem regwrite is 1, mem points to 0, wb points to 0, ex points to 0
        MEM_RegWrite <= 1'b1;
        WB_RegWrite <= 1'b1;
        MEM_Rd <= 5'd0;
        WB_Rd <= 5'd0;
        EX_Rs <= 5'd0;
        @(posedge clk);
        $display("edge case 3 forward_data: %d", forward_data);
        
        disable generate_clk;
    end
endmodule