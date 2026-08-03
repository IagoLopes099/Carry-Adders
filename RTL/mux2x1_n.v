`ifndef _MUX2_N_
`define _MUX2_N_

module mux2x1_n #(
    parameter N = 4
)(
    input wire [N-1:0] in_a,
    input wire [N-1:0] in_b,
    input wire sel,
    output wire [N-1:0] out_y
);

    assign out_y = sel ? in_b : in_a;

endmodule

`endif