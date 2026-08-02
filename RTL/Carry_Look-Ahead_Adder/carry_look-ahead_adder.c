#include <genlib.h>
#include <stdio.h>
#include <stdlib.h>

#define WIDTH 8  // Número de bits do somador

// ------------------------------------------------------------------
// Função de alocação de memória com verificação de erro
// Utiliza a função mbkalloc da biblioteca do Alliance (MBK)
// ------------------------------------------------------------------
static void* xalloc(size_t n) {
    void* p = mbkalloc(n);
    if (p == NULL) {
        fprintf(stderr, "Erro: mbkalloc falhou ao alocar %zu bytes\n", n);
        exit(1);
    }
    return p;
}

// ------------------------------------------------------------------
// Funções de nomeação de sinais/instâncias
// ------------------------------------------------------------------

// Nome simples, ex: "a_3", "g_5"
char* sig_name(const char* prefix, int idx) {
    char* name = (char*) xalloc(64 * sizeof(char));
    sprintf(name, "%s_%d", prefix, idx);
    return name;
}

// Nome com dois índices, ex: "carry_3_2"
char* sig_name2(const char* prefix, int i, int j) {
    char* name = (char*) xalloc(64 * sizeof(char));
    sprintf(name, "%s_%d_%d", prefix, i, j);
    return name;
}

// Adiciona um sufixo a um nome base para diferenciar o sinal de saída da instância
// ex.: base "term_4_2_L0" -> instância "term_4_2_L0_inst", sinal "term_4_2_L0_q"
char* leaf_name(const char* base, const char* suffix) {
    char* name = (char*) xalloc(96 * sizeof(char));
    sprintf(name, "%s_%s", base, suffix);
    return name;
}

// ============================================================
// ÁRVORE BALANCEADA DE ANDs ( portas de 2 entradas)
// ============================================================
// Constrói recursivamente uma árvore de ANDs para multiplicar 'num_signals'
// Retorna o nome do sinal contendo o resultado da operação de AND.
char* build_and_tree(char** signals, int num_signals, const char* base_name) {
    
    // Caso base 1: Apenas 1 sinal, retorna ele mesmo (sem necessidade de porta)
    if (num_signals == 1) return signals[0]; 

    char* out_sig = leaf_name(base_name, "q");   // Sinal de saída deste nó

    if (num_signals == 2) {
        char* inst = leaf_name(base_name, "inst");

        GENLIB_LOINS("a2_x2", inst, signals[0], signals[1], out_sig,
                     "vdd", "vss", (char*)0);
        return out_sig;
    }

// Caso recursivo (3+ sinais): Divisão e Conquista em 2 metades
    int left_count = num_signals / 2;
    int right_count = num_signals - left_count;

    char* left_base = leaf_name(base_name, "L");
    char* right_base = leaf_name(base_name, "R");
// Recorre nos dois ramos (esquerdo e direito)
    char* left_out = build_and_tree(signals, left_count, left_base);
    char* right_out = build_and_tree(signals + left_count, right_count, right_base);
// Instancia a porta AND que une o resultado dos dois ramos
    char* inst = leaf_name(base_name, "inst");
    GENLIB_LOINS("a2_x2", inst, left_out, right_out, out_sig,
                 "vdd", "vss", (char*)0);
    return out_sig;
}

// ============================================================
// ÁRVORE BALANCEADA DE ORs (portas de 2 entradas)
// ============================================================
// Constrói recursivamente uma árvore de ORs para somar 'num_signals'
char* build_or_tree(char** signals, int num_signals, const char* base_name) {
   // Caso base 1: Apenas 1 sinal, retorna ele mesmo
    if (num_signals == 1) return signals[0];

    char* out_sig = leaf_name(base_name, "q");
// Caso base 2: Exatamente 2 sinais -> Instancia 1 porta OR de 2 entradas
    if (num_signals == 2) {
        char* inst = leaf_name(base_name, "inst");
        GENLIB_LOINS("o2_x2", inst, signals[0], signals[1], out_sig,
                     "vdd", "vss", (char*)0);
        return out_sig;
    }
// Caso recursivo (3+ sinais): Divisão em dois subgrupos
    int left_count = num_signals / 2;
    int right_count = num_signals - left_count;

    char* left_base = leaf_name(base_name, "L");
    char* right_base = leaf_name(base_name, "R");

    char* left_out = build_or_tree(signals, left_count, left_base);
    char* right_out = build_or_tree(signals + left_count, right_count, right_base);
// Instancia a porta OR combinando as saídas dos dois sub-ramos
    char* inst = leaf_name(base_name, "inst");
    GENLIB_LOINS("o2_x2", inst, left_out, right_out, out_sig,
                 "vdd", "vss", (char*)0);
    return out_sig;
}

int main(void) {
    int i, j, k;

 // Inicializa a definição da figura lógica (netlist do circuito)
    GENLIB_DEF_LOFIG("carry_lookahead_adder");

    // ============================================================
    // 1. CONECTORES EXTERNOS (INTERFACE DO CIRCUITO)
    // ============================================================
    for (i = 0; i < WIDTH; i++) {
        GENLIB_LOCON(sig_name("a", i), IN, sig_name("a", i));  // Entrada A_i
        GENLIB_LOCON(sig_name("b", i), IN, sig_name("b", i));  // Entrada B_i
        GENLIB_LOCON(sig_name("s", i), OUT, sig_name("s", i)); // Saída Soma S_i
    }
    GENLIB_LOCON("cin", IN, "cin"); // Carry-in inicial
    GENLIB_LOCON("cout", OUT, "cout"); // Carry-out final
    GENLIB_LOCON("vdd", IN, "vdd"); // Alimentação VDD
    GENLIB_LOCON("vss", IN, "vss"); // Terra VSS

    // ============================================================
    // 2. SINAIS INTERNOS
    // ============================================================
    char **g = (char**) xalloc(WIDTH * sizeof(char*)); // Gerações (g_i)
    char **p = (char**) xalloc(WIDTH * sizeof(char*)); // Propagações (p_i)
    char **c = (char**) xalloc((WIDTH + 1) * sizeof(char*)); // Carries internos (c_i)

    for (i = 0; i < WIDTH; i++) {
        g[i] = sig_name("g", i);
        p[i] = sig_name("p", i);
        c[i] = sig_name("c", i);
    }
    c[WIDTH] = sig_name("c", WIDTH); // Carry final c_WIDTH

   // Buffer do cin para c[0]: Isola eletricamente a entrada externa cin
    GENLIB_LOINS("buf_x2", "buf_cin", "cin", c[0], "vdd", "vss", (char*)0);

    // ============================================================
    // 3. SINAIS DE PROPAGAÇÃO (P_i) E GERAÇÃO (G_i)
    // ============================================================
    for (i = 0; i < WIDTH; i++) {
        // G_i = A_i AND B_i
        GENLIB_LOINS("a2_x2", sig_name("and_g", i),
                     sig_name("a", i), sig_name("b", i), g[i],
                     "vdd", "vss", (char*)0);
        // P_i = A_i XOR B_i
        GENLIB_LOINS("xr2_x1", sig_name("xor_p", i),
                     sig_name("a", i), sig_name("b", i), p[i],
                     "vdd", "vss", (char*)0);
    }

    // ============================================================
    // 4. CLA COM ÁRVORES BALANCEADAS
    // ============================================================

    // Para cada bit 'i' (de 1 a 8), constrói-se a expressão lógica do Carry c_i
    for (i = 1; i <= WIDTH; i++) {
        // Aloca espaço para guardar todos os mintermos que compõem o c_i
        char** term_sigs = (char**) xalloc((i + 1) * sizeof(char*));
        int num_terms = 0;

    // Termo 0: G_{i-1} (Não precisa de multiplicação por AND)
        term_sigs[num_terms++] = g[i - 1];

        // Termos j = 1..i-1: P_{i-1}*...*P_{i-j}*G_{i-j-1}
        for (j = 1; j < i; j++) {
            int num_factors = j + 1;
            char** factors = (char**) xalloc(num_factors * sizeof(char*));
        
         // Coleta os fatores de propagação: P_{i-1}, P_{i-2}, ..., P_{i-j}
            for (k = 0; k < j; k++) {
                factors[k] = p[i - 1 - k];
            }
            // O último fator é o termo de geração: G_{i-j-1}
            factors[j] = g[i - j - 1];
            // Multiplica todos os fatores usando uma árvore de ANDs balanceada
            char* base_name = sig_name2("term", i, j);
            term_sigs[num_terms++] = build_and_tree(factors, num_factors, base_name);

            free(factors);  // Libera o vetor temporário de ponteiros
        }

        // Último termo (j = i): P_{i-1}*...*P_0*C_0
        {
            int num_factors = i + 1;
            char** factors = (char**) xalloc(num_factors * sizeof(char*));

            for (k = 0; k < i; k++) {
                factors[k] = p[i - 1 - k];
            }
            factors[i] = c[0]; // Inclui o Carry inicial c_0

            char* base_name = sig_name2("term", i, i);
            term_sigs[num_terms++] = build_and_tree(factors, num_factors, base_name);

            free(factors);
        }

    // Realiza a soma lógica (OR) de todos os termos gerados para formar o c_i
        char* base_name = sig_name("carry", i);
        char* carry_out = build_or_tree(term_sigs, num_terms, base_name);

     // Buffer do c_i interno gerado para isolar a árvore da carga dos gates receptores
        GENLIB_LOINS("buf_x2", sig_name("buf_c", i), carry_out, c[i],
                     "vdd", "vss", (char*)0);

        free(term_sigs);
    }

    // ============================================================
    // 5. GERAÇÃO DA SOMA (S_i = P_i XOR C_i)
    // ============================================================
    for (i = 0; i < WIDTH; i++) {
        GENLIB_LOINS("xr2_x1", sig_name("xor_s", i),
                     p[i], c[i], sig_name("s", i),
                     "vdd", "vss", (char*)0);
    }
    // Buffer de saída para o Carry Out final (cout = c[width])
    GENLIB_LOINS("buf_x2", "buf_cout", c[WIDTH], "cout", "vdd", "vss", (char*)0);
    // Salva a estrutura da figura lógica no disco
    GENLIB_SAVE_LOFIG();
    return 0;
}