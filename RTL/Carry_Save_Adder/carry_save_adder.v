`include "../Carry_Ripple_Adder/carry_ripple_adder.v"

module carry_save_adder #(
    parameter WIDTH = 4
)(
    input wire [WIDTH-1:0] in_a, in_b, in_c,
    input in_cin,
    output [WIDTH:0] out_sum,
    output out_cout_CSA
);

    wire [(WIDTH*2)-1:0] chain_carrys; 
    wire [(WIDTH*2):0] chain_carrys_sum;
    assign chain_carrys_sum = {1'b0,chain_carrys};
    wire [WIDTH-1:0] a_bus, b_bus;


    genvar i;
    generate 
        for (i=0; i < WIDTH ; i=i+1) begin : firsts_FA
            full_adder inst_fa (
                .a(in_a[i]),
                .b(in_b[i]),
                .cin(in_c[i]),
                .sum(chain_carrys[i*2]),
                .cout(chain_carrys[(i*2)+1])
            );
        end
    endgenerate

    generate
        for (i=0 ; i < WIDTH ; i=i+1) begin : a_and_b_bus
            assign a_bus[i] = chain_carrys_sum[(i*2)+1];
            assign b_bus[i] = chain_carrys_sum[(i*2)+2];
        end
    endgenerate

    carry_ripple_adder #( .WIDTH(WIDTH) ) CRA 
    (
        .in_a(a_bus),
        .in_b(b_bus),
        .in_cin(1'b0),
        .out_sum(out_sum[WIDTH:1]),
        .out_cout(out_cout_CSA)
    );


endmodule