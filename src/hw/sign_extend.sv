module sign_extend #(
parameter int DATA_WIDTH = 32,
parameter int INPUT_WIDTH = 12
) (
    input logic[INPUT_WIDTH-1:0] in,
    output logic[INPUT_WIDTH-1:0] out
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