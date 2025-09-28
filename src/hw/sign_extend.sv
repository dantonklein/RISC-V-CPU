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
    input logic[2:0] funct3,

    output logic[DATA_WIDTH-1:0] out
);
    localparam logic[2:0] LB = 3'b000;
    localparam logic[2:0] LH = 3'b001;
    localparam logic[2:0] LW = 3'b010;
    localparam logic[2:0] LBU = 3'b100;
    localparam logic[2:0] LHU = 3'b101;

    logic [DATA_WIDTH-9:0] padder;
    always_comb begin
        padder = '0;
        out = '0;
        case (funct3)

            LW, LBU, LHU: out = in;
            LB: begin
                if(in[7] == 1'b1) padder = '1;
                out = {padder, in[7:0]};
            end
            LH: begin
                if(in[15] == 1'b1) padder = '1;
                out = {padder[15:0], in[15:0]};
            end
            default: out = '0;
        endcase
    end

endmodule