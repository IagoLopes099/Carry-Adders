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


    wire [WIDTH:0] carrys; // chain of carrys
    assign out_cout = carrys[WIDTH];

    wire [WIDTH-1:0] g, p;

    cla_generator #(.WIDTH(WIDTH)) cla_gen(
        .p(p),
        .g(g),
        .cin(in_cin),
        .carry(carrys)
    );

    genvar i;
    generate
        for(i=0; i < WIDTH; i = i+1) begin
            assign g[i] = in_a[i] & in_b[i]; 
            assign p[i] = in_a[i] ^ in_b[i];
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