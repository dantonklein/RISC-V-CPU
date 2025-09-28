//This testbench was written while the data_ram didnt have the access fault check.

module instruction_ram_tb;

    logic clk = 1'b0;

    logic[31:0] address;
    logic[31:0] data_in;
    logic write;
    //logic read;
    //logic[2:0] funct3;
    //logic data_access_fault_exception;
    logic flush;
    logic[31:0] data_out;
    

    // data_ram #(
    //     .DATA_WIDTH(32),
    //     .ADDR_WIDTH(16)
    // ) DUT (
    //     .clk(clk),
    //     .address(address),
    //     .data_in(data_in),
    //     .write(write),
    //     .read(read),
    //     .funct3(funct3),
    //     .data_out(data_out)
    // );

    instruction_ram #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(32),
        .RAM_SIZE_WIDTH(16)
    ) DUT (
        .clk(clk),
        .PC(address),
        .instruction_in(data_in),
        .instruction_write(write),
        .flush(flush),
        .instruction(data_out)
    );
    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
      
       	// Initialize all control signals
        write <= 1'b0;
        //read <= 1'b0;
        address <= '0;
        data_in <= '0;
        flush <= 1'b0;

        // Wait a clock cycle
        repeat(2) @(posedge clk);
      	
      	//test a few write cycles
        //funct3 <= 3'b000;
        write   <= 1'b1;
      
      	data_in <= 32'h11111111;
        address <= 32'h00000000;
        repeat(2) @(posedge clk);

        address <= 32'h00000004;
      	data_in <= 32'h22222222;
        write   <= 1'b1;
      
        repeat(2) @(posedge clk);
        address <= 32'h00000008;
      	data_in <= 32'h33333333;
        write   <= 1'b1;
      
        repeat(2) @(posedge clk);
      	write   <= 1'b0;
        address <= 32'h00000000;
        repeat(2) @(posedge clk);
        $display("Data:%x at Address:%x", data_out, address);

        address <= 32'h00000004;
        
      	repeat(2) @(posedge clk);	
        $display("Data:%x at Address:%x", data_out, address);

        address <= 32'h00000008;

        repeat(2) @(posedge clk);
        $display("Data:%x at Address:%x", data_out, address);
        
        flush <= 1'b1;

        repeat(2) @(posedge clk);
        $display("Test Flush: Data:%x at Address:%x", data_out, address);

        flush <= 1'b0;

        repeat(2) @(posedge clk);
        $display("Test Flush turned off: Data:%x at Address:%x", data_out, address);
        // //SH testing boundary condition
        // addr = 16'hFFFF;
        // test_data = 32'h0000FFFF & $urandom;
        // funct3 <= 3'b001;
        // write   <= 1'b1;
      
      	// data_in <= test_data;
        // address <= addr;
      	// @(posedge clk);	
		// write <= 1'b0;
        // @(posedge clk);

        // //LH from the same address
        // write <= 1'b0;
        // read <= 1'b1;
        // address <= addr;
        // @(posedge clk);
        // $display("SH and LH test with max address address:%x input:%x, output:%x", address, data_in, data_out);

        // //SW 
        // addr = 16'h2222;
      	// test_data = $urandom;
        // funct3 <= 3'b010;
        // write   <= 1'b1;
      
      	// data_in <= test_data;
        // address <= addr;
      	// @(posedge clk);	
		// write <= 1'b0;
        // @(posedge clk);
        // //LW from the same address
      	// write <= 1'b0;
        // read <= 1'b1;
        // address <= addr;
        // @(posedge clk);
        // $display("SW and LW test address:%x input:%x, output:%x", address, data_in, data_out);


        // //SW testing max addy
        // addr = 16'hFFFF;
      	// test_data = $urandom;
        // funct3 <= 3'b010;
        // write   <= 1'b1;
      
      	// data_in <= test_data;
        // address <= addr;
      	// @(posedge clk);	
		// write <= 1'b0;
        // @(posedge clk);
        // //LW from the same address
      	// write <= 1'b0;
        // read <= 1'b1;
        // address <= addr;
        // @(posedge clk);
        // $display("SW and LW test with max address address:%x input:%x, output:%x", address, data_in, data_out);

        // //SW testing max addy - 1
        // addr = 16'hFFFE;
      	// test_data = $urandom;
        // funct3 <= 3'b010;
        // write   <= 1'b1;
      
      	// data_in <= test_data;
        // address <= addr;
      	// @(posedge clk);	
		// write <= 1'b0;
        // @(posedge clk);
        // //LW from the same address
      	// write <= 1'b0;
        // read <= 1'b1;
        // address <= addr;
        // @(posedge clk);
        // $display("SW and LW test with max address - 1 address:%x input:%x, output:%x", address, data_in, data_out);

        // //SW testing max addy - 2
        // addr = 16'hFFFD;
      	// test_data = $urandom;
        // funct3 <= 3'b010;
        // write   <= 1'b1;
      
      	// data_in <= test_data;
        // address <= addr;
      	// @(posedge clk);	
		// write <= 1'b0;
        // @(posedge clk);
        // //LW from the same address
      	// write <= 1'b0;
        // read <= 1'b1;
        // address <= addr;
        // @(posedge clk);
        // $display("SW and LW test with max address - 2 address:%x input:%x, output:%x", address, data_in, data_out);


        disable generate_clk;

    end
  
endmodule

module data_ram_tb;

    logic clk = 1'b0;

    logic[31:0] address;
    logic[31:0] data_in;
    logic write;
    logic read;
    logic[2:0] funct3;
    logic data_access_fault_exception;
    //logic flush;
    logic[31:0] data_out;
    
    localparam logic[2:0] SB = 3'b000;
    localparam logic[2:0] SH = 3'b001;
    localparam logic[2:0] SW = 3'b010;

    localparam logic[2:0] LB = 3'b000;
    localparam logic[2:0] LH = 3'b001;
    localparam logic[2:0] LW = 3'b010;
    localparam logic[2:0] LBU = 3'b100;
    localparam logic[2:0] LHU = 3'b101;

    data_ram #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(32),
        .RAM_SIZE_WIDTH(16)
    ) DUT (
        .clk(clk),
        .address(address),
        .data_in(data_in),
        .write(write),
        .read(read),
        .funct3(funct3),
        .data_access_fault_exception(data_access_fault_exception),
        .data_out(data_out)
    );


    //Clock generation block
    initial begin: generate_clk
        clk <= 1'b0;
        forever #5 clk <= ~clk;
    end

    initial begin
      
        //My tests:
        //1. tests for write conditions that cause data_access_fault_exceptions
        //2. tests involving storing data at a location then reading from it, with all the LSB configurations

       	// Initialize all signals
        write <= 1'b0;
        read <= 1'b0;
        address <= '0;
        data_in <= '0;
        funct3 <= '0;

        // Wait clock cycles
        repeat(2) @(posedge clk);
      	
      	$display("Test 1: data_access_fault_exception triggers when a word is written and the address is too big");
        funct3 <= SW;
        write  <= 1'b1;
      
      	data_in <= 32'h11111111;
        address <= 32'd65533;
        @(posedge clk);

        write   <= 1'b0;
      
        @(posedge clk)
        $display("Data_Access_Fault_Exception: %b\n", data_access_fault_exception);
        
        $display("Test 2: data_access_fault_exception triggers when a halfword is written and the address is too big");
        funct3 <= SH;
        write  <= 1'b1;
      
      	data_in <= 32'h11111111;
        address <= 32'd65535;
        @(posedge clk);

        write   <= 1'b0;
      
        @(posedge clk)
        $display("Data_Access_Fault_Exception: %b\n", data_access_fault_exception);
        
        $display("Test 3: data_access_fault_exception triggers when a byte is written and the address is too big");
        funct3 <= SB;
        write  <= 1'b1;
      
      	data_in <= 32'h11111111;
        address <= 32'd65536;
        @(posedge clk);

        write   <= 1'b0;
      
        @(posedge clk)
        $display("Data_Access_Fault_Exception: %b\n", data_access_fault_exception);
        
        $display("Test 4: Store Byte then Read Byte with address that has remainder 0");
        funct3 <= SB;
        write  <= 1'b1;
      
      	data_in <= 32'h12345678;
        address <= 32'd100;
        @(posedge clk);
        funct3 <= LB;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 5: Store Byte then Read Byte with address that has remainder 1");
        funct3 <= SB;
        write  <= 1'b1;
      
      	data_in <= 32'h34567812;
        address <= 32'd101;
        @(posedge clk);
        funct3 <= LB;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 6: Store Byte then Read Byte with address that has remainder 2");
        funct3 <= SB;
        write  <= 1'b1;
      
      	data_in <= 32'h56781234;
        address <= 32'd102;
        @(posedge clk);
        funct3 <= LB;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 7: Store Byte then Read Byte with address that has remainder 3");
        funct3 <= SB;
        write  <= 1'b1;
      
      	data_in <= 32'h78123456;
        address <= 32'd103;
        @(posedge clk);
        funct3 <= LB;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 8: Store Halfword then Read Halfword with address that has remainder 0");
        funct3 <= SH;
        write  <= 1'b1;
      
      	data_in <= 32'h12345678;
        address <= 32'd104;
        @(posedge clk);
        funct3 <= LH;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 9: Store Halfword then Read Halfword with address that has remainder 1");
        funct3 <= SH;
        write  <= 1'b1;
      
      	data_in <= 32'h34567812;
        address <= 32'd109;
        @(posedge clk);
        funct3 <= LH;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 10: Store Halfword then Read Halfword with address that has remainder 2");
        funct3 <= SH;
        write  <= 1'b1;
      
      	data_in <= 32'h56781234;
        address <= 32'd114;
        @(posedge clk);
        funct3 <= LH;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 11: Store Halfword then Read Halfword with address that has remainder 3");
        funct3 <= SH;
        write  <= 1'b1;
      
      	data_in <= 32'h78123456;
        address <= 32'd119;
        @(posedge clk);
        funct3 <= LH;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 12: Store Word then Read Word with address that has remainder 0");
        funct3 <= SW;
        write  <= 1'b1;
      
      	data_in <= 32'h12345678;
        address <= 32'd124;
        @(posedge clk);
        funct3 <= LW;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 13: Store Word then Read Word with address that has remainder 1");
        funct3 <= SW;
        write  <= 1'b1;
      
      	data_in <= 32'h34567812;
        address <= 32'd129;
        @(posedge clk);
        funct3 <= LW;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 14: Store Word then Read Word with address that has remainder 2");
        funct3 <= SW;
        write  <= 1'b1;
      
      	data_in <= 32'h56781234;
        address <= 32'd134;
        @(posedge clk);
        funct3 <= LW;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        $display("Test 15: Store Word then Read Word with address that has remainder 3");
        funct3 <= SW;
        write  <= 1'b1;
      
      	data_in <= 32'h78123456;
        address <= 32'd139;
        @(posedge clk);
        funct3 <= LW;
        write   <= 1'b0;
        read    <= 1'b1;
      
        @(posedge clk)

        read    <= 1'b0;

        @(posedge clk)
        $display("Data In: %x Data Out: %x at Address: %x\n", data_in, data_out, address);

        disable generate_clk;

    end
  
endmodule

