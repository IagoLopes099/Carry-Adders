module generic_adder #(
    parameter WIDTH = 4
)(
    input wire [WIDTH-1:0] a, b,
    output reg [WIDTH-1:0] s,

    input wire cin,
    output reg cout
);
    reg [WIDTH:0] temp_sum;

    always @(*) begin : adder
        temp_sum = a + b + cin;
        s = temp_sum[WIDTH-1:0];
        cout = temp_sum[WIDTH];
    end

    
endmodule