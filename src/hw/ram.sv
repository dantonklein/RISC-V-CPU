//Danton Klein
//This file contains the different rams that are on the cpu. For now there is no memory management unit,
//with the solution being that the ram is directly addressable. The input address width is 32 but it only
//supports RAM_SIZE_WIDTH. The instruction memory is assumed to always be a multiple of 4 so no translation
//logic for that.

//FPGA synthesizable ram
module ram_template #(
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 14
) (
    input logic clk,
    input logic[ADDR_WIDTH-1:0] address,
    input logic write, 
    input logic[DATA_WIDTH-1:0] data_in,
    output logic[DATA_WIDTH-1:0] data_out
);
    logic [DATA_WIDTH-1:0] mem [2 ** ADDR_WIDTH];
    always_ff @(posedge clk) begin
        if(write) mem[address] <= data_in;
        data_out <= mem[address];
    end

endmodule

//Module that simulates data memory
module data_ram #(
    //Byte-Addresed
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 32,
    parameter int RAM_SIZE_WIDTH = 16
) (
    input logic clk,

    input logic[ADDR_WIDTH-1:0] address,
    input logic[31:0] data_in,
    input logic write, 
    input logic read,
    input logic[2:0] funct3,

    output logic[31:0] data_out,
    output logic data_access_fault_exception
);
    localparam logic[2:0] SB = 3'b000;
    localparam logic[2:0] SH = 3'b001;
    localparam logic[2:0] SW = 3'b010;

    localparam logic[2:0] LB = 3'b000;
    localparam logic[2:0] LH = 3'b001;
    localparam logic[2:0] LW = 3'b010;
    localparam logic[2:0] LBU = 3'b100;
    localparam logic[2:0] LHU = 3'b101;
    
    logic data_access_fault_exception_temp;
    logic read_next_cycle;
    logic[2:0] funct3_next_cycle;
    logic [RAM_SIZE_WIDTH-1:0] effective_address;
    logic [1:0] effective_address_next_cycle;

    //Check for fault exception
    always_comb begin
        data_access_fault_exception_temp = 0;
        if((funct3 == SW && write) || (funct3 == LW && read)) begin
            if(address > 2 ** (RAM_SIZE_WIDTH) - 4) data_access_fault_exception_temp = 1;
        end
        else if((funct3 == SH && write) || (funct3 == LHU && read) || (funct3 == LH && read)) begin
            if(address > 2 ** (RAM_SIZE_WIDTH) - 2) data_access_fault_exception_temp = 1;
        end
        else if(write || read) begin
            if(address > 2 ** (RAM_SIZE_WIDTH) - 1) data_access_fault_exception_temp = 1;
        end
    end

    //address translation, eventually a memory management unit will be made
    assign effective_address = address[RAM_SIZE_WIDTH-1:0];

    logic [DATA_WIDTH-1:0] inputs[4];
    logic writes[4];
    logic [RAM_SIZE_WIDTH-3:0] ram_template_addresses[4];

    //address logic for writes
    always_comb begin
        //default values
        for(int i = 0; i < 4; i++) begin
            inputs[i] = '0;
            writes[i] = 0;
            ram_template_addresses[i] = '0;
        end

        case(effective_address[1:0])
            2'd0: begin
                case(funct3)
                    SB: begin
                        inputs[0] = data_in[7:0];
                        writes[0] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[0] = effective_address[15:2];
                    end
                    SH: begin
                        inputs[0] = data_in[7:0];
                        writes[0] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[0] = effective_address[15:2];
                        inputs[1] = data_in[15:8];
                        writes[1] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[1] = effective_address[15:2];
                    end
                    SW: begin
                        inputs[0] = data_in[7:0];
                        writes[0] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[0] = effective_address[15:2];
                        inputs[1] = data_in[15:8];
                        writes[1] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[1] = effective_address[15:2];
                        inputs[2] = data_in[23:16];
                        writes[2] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[2] = effective_address[15:2];
                        inputs[3] = data_in[31:24];
                        writes[3] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[3] = effective_address[15:2];
                    end
                    //default to make vivado happy
                    default: inputs[0] = '0;
                endcase
            end
            2'd1: begin
                case(funct3)
                    SB: begin
                        inputs[1] = data_in[7:0];
                        writes[1] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[1] = effective_address[15:2];
                    end
                    SH: begin
                        inputs[1] = data_in[7:0];
                        writes[1] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[1] = effective_address[15:2];
                        inputs[2] = data_in[15:8];
                        writes[2] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[2] = effective_address[15:2];
                    end
                    SW: begin
                        inputs[1] = data_in[7:0];
                        writes[1] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[1] = effective_address[15:2];
                        inputs[2] = data_in[15:8];
                        writes[2] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[2] = effective_address[15:2];
                        inputs[3] = data_in[23:16];
                        writes[3] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[3] = effective_address[15:2];
                        inputs[0] = data_in[31:24];
                        writes[0] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[0] = effective_address[15:2] + 1;
                    end
                    //default to make vivado happy
                    default: inputs[0] = '0;
                endcase
            end
            2'd2: begin
                case(funct3)
                    SB: begin
                        inputs[2] = data_in[7:0];
                        writes[2] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[2] = effective_address[15:2];
                    end
                    SH: begin
                        inputs[2] = data_in[7:0];
                        writes[2] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[2] = effective_address[15:2];
                        inputs[3] = data_in[15:8];
                        writes[3] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[3] = effective_address[15:2];
                    end
                    SW: begin
                        inputs[2] = data_in[7:0];
                        writes[2] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[2] = effective_address[15:2];
                        inputs[3] = data_in[15:8];
                        writes[3] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[3] = effective_address[15:2];
                        inputs[0] = data_in[23:16];
                        writes[0] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[0] = effective_address[15:2] + 1;
                        inputs[1] = data_in[31:24];
                        writes[1] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[1] = effective_address[15:2] + 1;
                    end
                    //default to make vivado happy
                    default: inputs[0] = '0;
                endcase
            end
            2'd3: begin
                case(funct3)
                    SB: begin
                        inputs[3] = data_in[7:0];
                        writes[3] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[3] = effective_address[15:2];
                    end
                    SH: begin
                        inputs[3] = data_in[7:0];
                        writes[3] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[3] = effective_address[15:2];
                        inputs[0] = data_in[15:8];
                        writes[0] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[0] = effective_address[15:2] + 1;
                    end
                    SW: begin
                        inputs[3] = data_in[7:0];
                        writes[3] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[3] = effective_address[15:2];
                        inputs[0] = data_in[15:8];
                        writes[0] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[0] = effective_address[15:2] + 1;
                        inputs[1] = data_in[23:16];
                        writes[1] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[1] = effective_address[15:2] + 1;
                        inputs[2] = data_in[31:24];
                        writes[2] = !data_access_fault_exception_temp & write;
                        ram_template_addresses[2] = effective_address[15:2] + 1;
                    end
                    //default to make vivado happy
                    default: inputs[0] = '0;
                endcase
            end
        endcase
    end

    logic [DATA_WIDTH-1:0] outputs[4];

    //FPGA synthesizable rams
    generate
        for(genvar i = 0; i < 4; i++) begin : ram_array
            ram_template #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(RAM_SIZE_WIDTH - 2)
            ) rams (
                .clk(clk),
                .address(ram_template_addresses[i]),
                .write(writes[i]),
                .data_in(inputs[i]),
                .data_out(outputs[i])
            );
        end
    endgenerate
   
    logic data_access_fault_exception_next_cycle;
    //delay signals
    always_ff @(posedge clk) begin
        data_access_fault_exception_next_cycle <= data_access_fault_exception_temp;
        read_next_cycle <= read;
        effective_address_next_cycle <= effective_address[1:0];
        funct3_next_cycle <= funct3;
    end

    assign data_access_fault_exception = data_access_fault_exception_next_cycle;
    //this section is in the write back stage 
    always_comb begin
       
        if(read_next_cycle && !data_access_fault_exception_next_cycle) begin
            case(effective_address_next_cycle)
                2'd0: begin
                    case(funct3_next_cycle) 
                        LB:  data_out = {'0, outputs[0]};
                        LBU: data_out = {'0, outputs[0]};
                        LH:  data_out = {'0, outputs[1], outputs[0]};
                        LHU: data_out = {'0, outputs[1], outputs[0]};
                        LW:  data_out = {outputs[3], outputs[2], outputs[1], outputs[0]};
                        //default to make vivado happy
                        default: data_out = '0;
                    endcase
                end
                2'd1: begin
                    case(funct3_next_cycle) 
                        LB:  data_out = {'0, outputs[1]};
                        LBU: data_out = {'0, outputs[1]};
                        LH:  data_out = {'0, outputs[2], outputs[1]};
                        LHU: data_out = {'0, outputs[2], outputs[1]};
                        LW:  data_out = {outputs[0], outputs[3], outputs[2], outputs[1]};
                        //default to make vivado happy
                        default: data_out = '0;
                    endcase
                end
                2'd2: begin
                    case(funct3_next_cycle) 
                        LB:  data_out = {'0, outputs[2]};
                        LBU: data_out = {'0, outputs[2]};
                        LH:  data_out = {'0, outputs[3], outputs[2]};
                        LHU: data_out = {'0, outputs[3], outputs[2]};
                        LW:  data_out = {outputs[1], outputs[0], outputs[3], outputs[2]};
                        //default to make vivado happy
                        default: data_out = '0;
                    endcase
                end
                2'd3: begin
                    case(funct3_next_cycle) 
                        LB:  data_out = {'0, outputs[3]};
                        LBU: data_out = {'0, outputs[3]};
                        LH:  data_out = {'0, outputs[0], outputs[3]};
                        LHU: data_out = {'0, outputs[0], outputs[3]};
                        LW:  data_out = {outputs[2], outputs[1], outputs[0], outputs[3]};
                        //default to make vivado happy
                        default: data_out = '0;
                    endcase
                end
                //default to make vivado happy
                default: data_out = '0;
            endcase
        end
        else data_out = '0;
    end

endmodule

//Module thats a simple instruction memory
// module instruction_ram #(
//     //Byte-Addresed
//     parameter int DATA_WIDTH = 32,
//     parameter int ADDR_WIDTH = 32,
//     parameter int RAM_SIZE_WIDTH = 16
// ) (
//     input logic clk,
//     input logic flush,
//     input logic instruction_write,
//     input logic[31:0] instruction_in,
//     input logic[13:0] PC15_2,

//     output logic[31:0] instruction
// );
//     logic flush_next_cycle;
//     //address translation, eventually a memory management unit will be made

//     always_ff @(posedge clk) begin
//         flush_next_cycle <= flush;
//     end
//     logic [DATA_WIDTH/4-1:0] inputs[4];
//     logic [RAM_SIZE_WIDTH-3:0] ram_template_address;
//     logic [DATA_WIDTH/4-1:0] outputs[4];
        
//     //WRITING IS ONLY FOR DEBUG, WILL NOT BE USED BECAUSE I FIGURED OUT $readmemb EXISTS
//     always_comb begin
//         ram_template_address = PC15_2;
//         inputs[0] = instruction_in[7:0];
//         inputs[1] = instruction_in[15:8];
//         inputs[2] = instruction_in[23:16];
//         inputs[3] = instruction_in[31:24];
//     end

//     //FPGA synthesizable rams
//     generate
//         for(genvar i = 0; i < 4; i++) begin : ram_array
//             ram_template #(
//                 .DATA_WIDTH(DATA_WIDTH/4),
//                 .ADDR_WIDTH(RAM_SIZE_WIDTH - 2)
//             ) rams (
//                 .clk(clk),
//                 .address(ram_template_address),
//                 .write(instruction_write),
//                 .data_in(inputs[i]),
//                 .data_out(outputs[i])
//             );
//         end
//     endgenerate

//     //flush block
//     always_comb begin
//         if(flush_next_cycle) begin
//             instruction = '0;
//         end

//         else begin
//             instruction = {outputs[3], outputs[2], outputs[1], outputs[0]};
//         end
//     end
// endmodule

//this ram is word addressable. we are running with the assumption that the address will always be a multiple of 4 for simplicity.
//the complexity of this topic will be addressed when an instruction cache and data cache are made.
module instruction_ram #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32,
    parameter int RAM_SIZE_WIDTH = 16
) (
    input logic clk,
    input logic flush,
    input logic instruction_write,
    input logic[31:0] instruction_in,
    input logic[RAM_SIZE_WIDTH-3:0] PC15_2,

    output logic[31:0] instruction
);
    logic flush_next_cycle;
    //address translation, eventually a memory management unit will be made

    always_ff @(posedge clk) begin
        flush_next_cycle <= flush;
    end
    logic [DATA_WIDTH-1:0] ram_output;
    ram_template #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(RAM_SIZE_WIDTH - 2)
    ) singular_ram (
        .clk(clk),
        .address(PC15_2),
        .write(instruction_write),
        .data_in(instruction_in),
        .data_out(ram_output)
    );
    //flush block
    always_comb begin
        if(flush_next_cycle) instruction = '0;
        else instruction = ram_output;
    end
endmodule