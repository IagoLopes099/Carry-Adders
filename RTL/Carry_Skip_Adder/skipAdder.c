#include <stdio.h>
#include <string.h>
#include <genlib.h>

#define POWER "vdd", "vss", NULL

void Adder(const char* Cin, const char* A, const char* B, const char* S, const char* Cout, int idxS, int idxC){
    //Construção da saída (S = A ^ B ^ Cin)
    GENLIB_LOINS("xr2_x2", 
                GENLIB_NAME("xor_%d", idxS), 
                A, B, 
                GENLIB_NAME("Sxor_%d", idxS), 
                POWER);
    
    GENLIB_LOINS("xr2_x2", 
                GENLIB_NAME("xor%d", idxS), 
                Cin, GENLIB_NAME("Sxor_%d", idxS), 
                S, 
                POWER);

    //Construção do carry out (Cout = AB + (A^B)Cin)
    GENLIB_LOINS("a2_x2",
                GENLIB_NAME("andAB%d", idxC),
                A, B,
                GENLIB_NAME("CoutAB%d", idxC),
                POWER);
    
    GENLIB_LOINS("a2_x2",
                GENLIB_NAME("andAxBC%d", idxC),
                Cin, GENLIB_NAME("Sxor_%d", idxS),
                GENLIB_NAME("CoutAxBC%d", idxC),
                POWER);

    GENLIB_LOINS("o2_x1",
                GENLIB_NAME("or%d", idxC),
                GENLIB_NAME("CoutAB%d", idxC), GENLIB_NAME("CoutAxBC%d", idxC),
                Cout,
                POWER);
}

void AndN(const char** inputs, int numInputs, const char* output, int idx){
    if(numInputs < 2){
        printf("[ERROR] - AndN precisa de pelo menos 2 entradas.\n");
        return;
    }

    //Caso trivial: só uma porta de 2 entradas
    if(numInputs == 2){
        GENLIB_LOINS("a2_x2",
                    GENLIB_NAME("andN_%d_0", idx),
                    inputs[0], inputs[1],
                    output,
                    POWER);
        return;
    }

    //Primeira porta: combina as duas primeiras entradas
    char prevBuf[64];
    strncpy(prevBuf, GENLIB_NAME("andN_net_%d_0", idx), 63);
    prevBuf[63] = '\0';
    GENLIB_LOINS("a2_x2",
                GENLIB_NAME("andN_%d_0", idx),
                inputs[0], inputs[1],
                prevBuf,
                POWER);

    //Portas intermediárias: acumula uma entrada por vez
    for(int i = 2; i < numInputs - 1; i++){
        char nextBuf[64];
        strncpy(nextBuf, GENLIB_NAME("andN_net_%d_%d", idx, i - 1), 63);
        nextBuf[63] = '\0';

        GENLIB_LOINS("a2_x2",
                    GENLIB_NAME("andN_%d_%d", idx, i - 1),
                    prevBuf, inputs[i],
                    nextBuf,
                    POWER);
        strncpy(prevBuf, nextBuf, 63);
        prevBuf[63] = '\0';
    }

    //Última porta: conecta na saída final de verdade
    GENLIB_LOINS("a2_x2",
                GENLIB_NAME("andN_%d_%d", idx, numInputs - 2),
                prevNet, inputs[numInputs - 1],
                output,
                POWER);
}

void mux2x1(const char** inputs, const char* X, const char* Y, const char* S, int numInputs, int idx){
    char ctrlBuf[64];
    strncpy(ctrlBuf, GENLIB_NAME("Skip%d", idx), 63);
    ctrlBuf[63] = '\0';

    AndN(inputs, numInputs, ctrlBuf, idx);
    GENLIB_LOINS("mux2", GENLIB_NAME("mux%d", idx), X, Y, ctrlBuf, S, POWER);
}

void skipAdder(int numBits, int numGroups){
    int bloco = numBits/numGroups;
    int idCin = 0, idxI = 0, idxF = bloco - 1;

    if(numGroups == numBits){
        printf("[ERROR] - O número de grupos deve ser diferente do número de bits.\n");
        return;
    }
    if((numGroups > 0) && ((numGroups & (numGroups - 1)) != 0)){
        printf("[ERROR] - O número de grupos deve ser potência de 2.\n");
        return;
    }

    char pBuffers[bloco][64];
    const char* pInputs[bloco];

    for(int i = 0; i < numBits; i++){
        int posNoGrupo = i % bloco;
        strncpy(pBuffers[posNoGrupo], GENLIB_NAME("Sxor_%d", i), 63);
        pBuffers[posNoGrupo][63] = '\0';
        pInputs[posNoGrupo] = pBuffers[posNoGrupo];
        
        Adder(GENLIB_NAME("Cin%d", i), 
            GENLIB_NAME("A%d", i), 
            GENLIB_NAME("B%d", i), 
            GENLIB_NAME("S%d", i), 
            GENLIB_NAME("Cout%d", i), i, i);
        
        if((i+1)%bloco == 0){
            //MUX 2x2
            mux2x1(pInputs, GENLIB_NAME("Cin%d", idxI), GENLIB_NAME("Cout%d", i), GENLIB_NAME("Cin%d", i+1), bloco, idCin);
            
            idxI = idxF + 1;
            idxF += bloco;
            idCin++;
        }
    }
}

int main(){
    int nB, nG;
    scanf("%d %d", &nB, &nG);
    
    GENLIB_DEF_LOFIG("Carry_Skip_Adder");

    GENLIB_LOCON("vdd", IN, "vdd");
    GENLIB_LOCON("vss", IN, "vss");
    GENLIB_LOCON("Cin0", IN, "Cin0");

    for(int i = 0; i < nB; i++){
        GENLIB_LOCON(GENLIB_NAME("A%d", i), IN, GENLIB_NAME("A%d", i));
        GENLIB_LOCON(GENLIB_NAME("B%d", i), IN, GENLIB_NAME("B%d", i));
        GENLIB_LOCON(GENLIB_NAME("S%d", i), IN, GENLIB_NAME("S%d", i));
    }
    
    GENLIB_LOCON("Cout_final", OUT, GENLIB_NAME("Cin%d", nB));
    
    skipAdder(nB, nG);
    GENLIB_SAVE_LOFIG();
    return 0;
}
