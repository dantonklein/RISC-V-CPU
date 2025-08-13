module counter_tb;
    logic clk;
    logic reset;
    logic count_up, count_down;
    logic[1:0] count;

    n_bit_counter #(
        .width(2)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .count_up(count_up),
        .count_down(count_down),
        .count(count)
    );

    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
        count_up <= 0;
        count_down <= 0;
        reset <= 1;
        @(posedge clk);

        reset <= 0;
        @(posedge clk);

        count_down <= 1;
        @(posedge clk);

        count_up <= 1;
        count_down <= 0;
        @(posedge clk);

        count_up <= 1;
        count_down <= 0;
        @(posedge clk);

        count_up <= 1;
        count_down <= 0;
        @(posedge clk);

        count_up <= 1;
        count_down <= 0;
        @(posedge clk);

        count_up <= 0;
        count_down <= 1;
        @(posedge clk);

        count_up <= 0;
        count_down <= 1;
        @(posedge clk);

        count_up <= 1;
        count_down <= 1;
        @(posedge clk);

        @(posedge clk);

        $display("Tests Finished.");
        disable generate_clk;
    end
endmodule