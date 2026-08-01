
`include "carry_save_adder.v"

module csa_n_adder #(
    parameter WIDTH = 4,
    parameter N_ADDER = 3
)(
    input wire [WIDTH-1:0] inputs_array [N_ADDER],
    output [WIDTH:0] sum,
    output cout
);

    genvar i;
    generate
        if(N_ADDER%2==0) begin
            for(i = 0; i < N_ADDER ; i=i+1) begin
                
                

            end
        end
    endgenerate

endmodule