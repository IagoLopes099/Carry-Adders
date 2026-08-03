`ifndef _CLA_GENERATOR_
`define _CLA_GENERATOR_

module cla_generator(
    input wire a, b, cin,
    output cout
);
    wire p, g;
    assign g = a & b; // a AND b
    assign p = a ^ b; // a XOR b
    assign cout = g | (p & cin); // g OR (p AND cin)

endmodule
`endif