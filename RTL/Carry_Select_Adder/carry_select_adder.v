`include "../Carry_Ripple_Adder/carry_ripple_adder.v"
`include "../mux2x1_n.v"

`ifndef _CSLA_
`define _CSLA_

module carry_select_adder #(
    parameter WIDTH = 8
)(
    input wire [WIDTH-1:0] in_a, in_b,
    input wire in_cin,
    output [WIDTH-1:0] out_sum,
    output out_cout
);

    localparam CRA_WIDTH = 4;
    // Number of used CRAs
    localparam num_cra = WIDTH/CRA_WIDTH;

    // Array of the truly used carries
    wire [num_cra:0] carry_chosen;
    assign carry_chosen[0] = in_cin;
    assign out_cout = carry_chosen[num_cra];

    // Array of the carries from two different scenarios (carry=0 or carry=1)
    wire [num_cra:1] carry_0;
    wire [num_cra:1] carry_1;

    // Outputs of the CRAs in both scenarios (carry=0 or carry=1)
    wire [WIDTH-1:CRA_WIDTH] output_carry_0;
    wire [WIDTH-1:CRA_WIDTH] output_carry_1;

    // The first 4 bits
    carry_ripple_adder #(
        .WIDTH(CRA_WIDTH)
    ) inst_cra (
        .in_a(in_a[CRA_WIDTH-1:0]),
        .in_b(in_b[CRA_WIDTH-1:0]),
        .in_cin(in_cin),
        .out_sum(out_sum[CRA_WIDTH-1:0]),
        .out_cout(carry_chosen[1])
    );

    // The next ones
    genvar i;
    generate
        for(i = 1; i < num_cra; i = i + 1) begin : gen_cra_blocks
            mux2x1_n #(
                .N(1)
            ) inst_mux2_cra(
                .in_a(carry_0[i]),
                .in_b(carry_1[i]),
                .sel(carry_chosen[i]),
                .out_y(carry_chosen[i+1])
            );

            carry_ripple_adder #(
                .WIDTH(CRA_WIDTH)
            ) inst_cra_carry_0 (
                .in_a(in_a[(i+1)*CRA_WIDTH-1 : i*CRA_WIDTH]),
                .in_b(in_b[(i+1)*CRA_WIDTH-1 : i*CRA_WIDTH]),
                .in_cin(1'b0),
                .out_sum(output_carry_0[(i+1)*CRA_WIDTH-1 : i*CRA_WIDTH]),
                .out_cout(carry_0[i])
            );

            carry_ripple_adder #(
                .WIDTH(CRA_WIDTH)
            ) inst_cra_carry_1 (
                .in_a(in_a[(i+1)*CRA_WIDTH-1 : i*CRA_WIDTH]),
                .in_b(in_b[(i+1)*CRA_WIDTH-1 : i*CRA_WIDTH]),
                .in_cin(1'b1),
                .out_sum(output_carry_1[(i+1)*CRA_WIDTH-1 : i*CRA_WIDTH]),
                .out_cout(carry_1[i])
            );

            mux2x1_n #(
                .N(CRA_WIDTH)
            ) inst_mux2_output_cra(
                .in_a(output_carry_0[(i+1)*CRA_WIDTH-1 : i*CRA_WIDTH]),
                .in_b(output_carry_1[(i+1)*CRA_WIDTH-1 : i*CRA_WIDTH]),
                .sel(carry_chosen[i]),
                .out_y(out_sum[(i+1)*CRA_WIDTH-1 : i*CRA_WIDTH])
            );
        end
    endgenerate

endmodule

`endif