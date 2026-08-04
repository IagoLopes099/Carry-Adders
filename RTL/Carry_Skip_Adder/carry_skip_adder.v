module full_adder(
    input  wire Cin,	 //Carry in do somador completo
    input  wire A,		 //Primeira entrada para soma
    input  wire B,		 //Segunda entrada para soma
    output wire S,		 //Resultado da soma
    output wire Cout,    //Carry out do somador completo
    output wire P        //propagate exposto para o skip do grupo
);
    assign P    = A ^ B;
    assign S    = P ^ Cin;
    assign Cout = (A & B) | (P & Cin);
endmodule


module skip_mux #(
    parameter BLOCO = 4
)(
    input  wire [BLOCO-1:0] propagates, // P de cada bit do grupo
    input  wire X,                      // carry que "pulou" o grupo
    input  wire Y,                      // Carry do últomo somador
    output wire S                       // carry final selecionado
);
    wire skip;
    assign skip = &propagates;  // AND-N — equivalente ao AndN()
    assign S    = skip ? X : Y;
endmodule


module carry_skip_adder #(
    parameter NUM_BITS   = 16,				//Número de bits para somar
    parameter NUM_GROUPS = 4				//Quantos grupos terão
)(
    input  wire [NUM_BITS-1:0] A,			//Entrada 
    input  wire [NUM_BITS-1:0] B,			//Entrada 
    input  wire                C0,			//Carry de entrada do somador skip
   output wire [NUM_BITS-1:0] S,			//Saída da soma
    output wire                Cout_final	//ùltimo carry out do somador
);
    localparam BLOCO = NUM_BITS / NUM_GROUPS;

    // C[i] = carry de entrada do bit i (C[NUM_BITS] = carry final)
    wire [NUM_BITS:0] C;
    assign C[0] = C0;

    wire [NUM_BITS-1:0] P;         // propagate de cada XOR entre Ai e Bi
    wire [NUM_BITS-1:0] CoutRaw;   // carry ripple cru (só usado na fronteira)

    genvar i, g;
    generate
        for(i = 0; i < NUM_BITS; i = i + 1) begin : bits
            full_adder fa (
                .Cin  (C[i]),
                .A    (A[i]),
                .B    (B[i]),
                .S    (S[i]),
                .Cout (CoutRaw[i]),
                .P    (P[i])
            );
			
            //O Cout do i-ésimo somador = Cin do (i+1)-ésimo somador 
            if((i+1) % BLOCO != 0) begin : ripple_direto
                assign C[i+1] = CoutRaw[i];
            end
        end

        //Fecha grupo: instancia o mux de skip
        for(g = 0; g < NUM_GROUPS; g = g + 1) begin : groups
            localparam IDX_I = g * BLOCO;         // primeiro Cin do grupo
            localparam IDX_F = IDX_I + BLOCO - 1; // último bit do grupo

            skip_mux #(.BLOCO(BLOCO)) mux (
                .propagates (P[IDX_F:IDX_I]),	// XOR Ai e Bi do grupo
                .X          (C[IDX_I]),         // Primeiro carry do grupo
                .Y          (CoutRaw[IDX_F]),   // Último carry do grupo
                .S          (C[IDX_F+1])        // Carry do próximo grupo
            );
        end
    endgenerate

    assign Cout_final = C[NUM_BITS];

endmodule
