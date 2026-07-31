`include "../full_adder.v"

module carry_ripple_adder #(
    parameter WIDTH = 4
)(
    input wire [WIDTH-1:0] in_a, in_b,
    input wire in_cin,
    output [WIDTH-1:0] out_sum,
    output out_cout

);
    wire [WIDTH:0] carry; // chain of carrys
    assign carry[0] = in_cin;
    assign out_cout = carry[WIDTH]; 

    // full adders will calculate the values of the sums and the chain carrys
    genvar i;

    generate
        for(i = 0; i < WIDTH ; i = i + 1) begin
            full_adder inst_fa (
                .a(in_a[i]),
                .b(in_b[i]),
                .cin(carry[i]),
                .sum(out_sum[i]),
                .cout(carry[i+1])
            );

        end
    endgenerate

endmodule