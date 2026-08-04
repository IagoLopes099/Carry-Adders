`ifndef _CLA_GENERATOR_
`define _CLA_GENERATOR_

module cla_generator
#(
    parameter WIDTH = 4
)
(
    input  [WIDTH-1:0] p,
    input  [WIDTH-1:0] g,
    input              cin,
    output reg [WIDTH:0] carry
);

    integer i, j, k;
    reg term;

    always @(*) begin

        carry = {(WIDTH+1){1'b0}};
        carry[0] = cin;

        for (i = 0; i < WIDTH; i = i + 1) begin

            term = cin;
            for (k = 0; k <= i; k = k + 1)
                term = term & p[k];

            carry[i+1] = term;

            for (j = 0; j <= i; j = j + 1) begin

                term = g[j];

                for (k = j+1; k <= i; k = k + 1)
                    term = term & p[k];

                carry[i+1] = carry[i+1] | term;
            end
        end

    end

endmodule
`endif