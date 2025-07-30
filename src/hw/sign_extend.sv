module sign_extend #(
parameter int DATA_WIDTH = 32,
parameter int INPUT_WIDTH = 12
) (
    input logic[INPUT_WIDTH-1:0] in,
    output logic[DATA_WIDTH-1:0] out
);
logic[DATA_WIDTH-INPUT_WIDTH-1:0] extend;
always_comb begin
    if(in[INPUT_WIDTH-1] == 1'b1) begin
        extend = '1;
    end else begin
        extend = '0;
    end
    out = {extend, in};
end
endmodule

module loads_sign_extend #(
    parameter int DATA_WIDTH = 32
)
(
    input logic[DATA_WIDTH-1:0] in,
    input logic[1:0] type_of_load,

    output logic[DATA_WIDTH-1:0] out
);
    //For LW, LBU, and LHU
    localparam logic[1:0] No_Extension = 2'd0;
    //For LB
    localparam logic[1:0] Load_Byte = 2'd1;
    //For LH
    localparam logic[1:0] Load_HalfWord = 2'd2;

    logic [DATA_WIDTH-9:0] padder;
    always_comb begin
        padder = '0;
        case (type_of_load)
            No_Extension: out = in;
            //LB
            Load_Byte: begin
                if(in[7] == 1'b1) padder = '1;
                out = {padder, in[7:0]};
            end
            //LH
            Load_HalfWord: begin
                if(in[15] == 1'b1) padder = '1;
                out = {padder[15:0], in[15:0]};
            end

        endcase
    end

endmodule