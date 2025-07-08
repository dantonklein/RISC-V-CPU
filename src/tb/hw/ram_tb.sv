//This testbench is modified version of Dr. Gregory Stitts from his SystemVerilog tutorial.
//The original testbench can be found in the file "ram_sdp_tb.sv".
//The reason this is modified is that the ram only has one address, for both reads and writes. This is due to read and write never
//being asserted at the time since they are different instructions.

//this shit dont work rn
`timescale 1 ns / 100 ps

module ram_tb #(
    parameter int NUM_TESTS = 10,

    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 16
);

    int passed = 0;
    int failed = 0;

    logic clk = 1'b0;

    logic[ADDR_WIDTH-1:0] address;
    logic[DATA_WIDTH-1:0] data_in;
    logic write;
    logic read;
    
    logic[DATA_WIDTH-1:0] data_out;

    ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) DUT (
        .clk(clk),
        .address(address),
        .data_in(data_in),
        .write(write),
        .read(read),
        .data_out(data_out)
    );
    bit addr_used[logic [ADDR_WIDTH-1:0]];
    logic [ADDR_WIDTH-1:0] used_addresses[$];


    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    //initial block for assigning reads and writes
    initial begin
        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data_in_temp;
        logic write_temp;

        for (int i = 0; i < NUM_TESTS; i++) begin
            assert (std::randomize(data_in_temp))
            else $fatal(1, "Randomization failed.");
          	$display("Data_out: 0x%0h", data_out);
            addr = $urandom;
            write_temp = $urandom;
            write   <= write_temp;
            address <= addr;
            data_in <= data_in_temp;

            if (write_temp && !addr_used.exists(addr)) begin
                used_addresses.push_back(addr);
            end

            @(posedge clk);

            read   <= $urandom;
            address <= used_addresses[$urandom_range(0, used_addresses.size()-1)];
            @(posedge clk);
        end

        disable generate_clk;

        $display("Tests completed. Passed: %0d Failed: %0d", passed, failed);
    end

    logic [DATA_WIDTH-1:0] model[2**ADDR_WIDTH];
    logic [DATA_WIDTH-1:0] rd_data_ram;
    

    //initial block for model and for checking correctness
    initial begin
        forever begin
            @(posedge clk);
            if(write) model[address] <= data_in;
            
            @(posedge clk);
            if(read) begin
              $display("Address: 0x%0h", address);
                rd_data_ram = model[address];
                if(rd_data_ram == data_out) passed++;
                else begin
                    $display("Ram Data Out: 0x%0h doesn't match model data out: 0x%0h", data_out, rd_data_ram);
                    failed++;
                end
            end
        end
    end


endmodule