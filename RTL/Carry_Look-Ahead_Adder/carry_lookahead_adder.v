`include "../full_adder.v"
`include "cla_generator.v"

module carry_lookahead_adder #(
    parameter WIDTH = 4
)(
    input wire [WIDTH-1:0] in_a, in_b,
    input wire in_cin,
    output [WIDTH-1:0] out_sum,
    output out_cout
);


    (* keep = 1 *) wire [WIDTH:0] carrys; // chain of carrys
    assign carrys[0] = in_cin; 
    assign out_cout = carrys[WIDTH];

    genvar i;
    generate 
        for(i=0 ; i<WIDTH ; i=i+1) begin : carry_generators
            cla_generator couts_generator (
                .a(in_a[i]),
                .b(in_b[i]),
                .cin(carrys[i]),
                .cout(carrys[i+1])
            ); 
        end
    endgenerate


    generate
        for(i=0; i<WIDTH; i=i+1) begin : full_adders_generators
            full_adder fa_insts (
                .a(in_a[i]),
                .b(in_b[i]),
                .cin(carrys[i]),
                .sum(out_sum[i]), 
                .cout() // keep unconnected. signed Iago
            );
        end
    endgenerate

endmodule