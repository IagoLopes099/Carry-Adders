# Criamos um "clock virtual" — não existe clock real no circuito,
# mas ele serve de referência de tempo para medir os caminhos combinacionais
create_clock -name virtual_clk -period 10 -waveform {0 5}

# Define o atraso de chegada dos sinais de entrada
# (ex: "esses sinais já chegam prontos 1ns depois do início do período")
set_input_delay -clock virtual_clk 1.0 [all_inputs]

# Define o atraso exigido na saída
# (ex: "os sinais de saída precisam estar prontos 1ns antes do fim do período")
set_output_delay -clock virtual_clk 1.0 [all_outputs]

# (Opcional) define uma carga capacitiva nas saídas, simulando o que viria depois
set_load 0.05 [all_outputs]