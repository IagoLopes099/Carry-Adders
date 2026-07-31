`ifndef _FULL_ADDER_
`define _FULL_ADDER_

module full_adder (
    input wire a, b, cin,
    output sum, cout
);

    assign sum = a ^ b ^ cin; // a AND b AND carry-in
    assign cout = (a & b) | ((a ^ b) & cin);    // (a AND b) OR ((a XOR b) AND carry-in)

endmodule

`endif