`ifndef _ADDER_IF_
`define _ADDER_IF_

interface Adder_if #(
    parameter WIDTH = 4
);
    logic [WIDTH-1:0] in_x, in_y, out_s; // input x and y , outpyt s
    logic carry_in, carry_out; // carry-in and carry-out

    modport TEST(
        input out_s, carry_out,
        output in_x, in_y, carry_in
    );

    modport DUT(
        input in_x, in_y, carry_in,
        output  out_s, carry_out
    );

endinterface 

`endif