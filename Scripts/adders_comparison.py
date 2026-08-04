import matplotlib.pyplot as plt

# ==========================
# Dados
# ==========================

bits = [4, 8, 16, 32, 64]

# Área (µm²)
cra_area  = [183.926, 364.099, 724.444, 1445.136, 2886.518]
cla_area  = [190.182, 377.862, 930.8928, 2288.4448, 12221.7216]
csa_area  = [183.926, 364.0992, 730.7008, 1451.392, 2894.026]
csla_area = [183.9264, 367.8528, 735.7056, 1471.4112, 2972.8512]

# Delay (ns)
cra_delay  = [1.69, 3.12, 5.62, 8.58, 16.86]
cla_delay  = [1.95, 2.96, 4.18, 6.77, 9.56]
csa_delay  = [1.92, 3.10, 5.38, 8.99, 16.34]
csla_delay = [1.91, 3.00, 5.22, 8.33, 14.06]

# Número de células
cra_cells  = [20, 40, 80, 160, 320]
cla_cells  = [23, 41, 104, 254, 1428]
csa_cells  = [20, 40, 81, 161, 322]
csla_cells = [20, 40, 80, 160, 328]

# ==========================
# Cores 
# ==========================

cores = {
    'CRA': "#020508",   # Preto
    'CLA': "#c91fbb",   # Rosa
    'CSA': "#b8081c",   # Vermelho
    'CSLA':"#0ee48f"    # Verde
}

# ==========================
# Função para criar gráficos
# ==========================
#x = eixo x (número de bits), y1 = CRA, y2 = CLA, y3 = CSA, y4 = CSLA, titulo = título do gráfico, ylabel = nome do eixo y
def grafico(x, y1, y2, y3, y4, titulo, ylabel):
    plt.figure(figsize=(8,5)) #Cria uma figura

    plt.plot(x, y1, '-o', linewidth=2, markersize=7, #Plotando o gráfico com os dados de CRA, com marcador de círculo
             color=cores['CRA'], label='CRA')

    plt.plot(x, y2, '-*', linewidth=2, markersize=7, #Plotando o gráfico com os dados de CLA, com marcador de estrela
             color=cores['CLA'], label='CLA')

    plt.plot(x, y3, '-^', linewidth=2, markersize=7, #Plotando o gráfico com os dados de CSA, com marcador de triângulo
             color=cores['CSA'], label='CSA')

    plt.plot(x, y4, '-D', linewidth=2, markersize=7, #Plotando o gráfico com os dados de CSLA, com marcador de losango
             color=cores['CSLA'], label='CSLA')

    plt.title(titulo, fontsize=14, fontweight='bold') #Adicionando o título do gráfico
    plt.xlabel('Número de Bits', fontsize=12) #Adicionando o nome do eixo x
    plt.ylabel(ylabel, fontsize=12) #Adicionando o nome do eixo y
    plt.xticks([0, 4, 8, 16, 24, 32, 40, 48, 56, 64], fontsize=10) #Adicionando os valores do eixo x
    plt.yticks(fontsize=10) #Adicionando os valores do eixo y
    plt.grid(True, linestyle='--', alpha=0.5) #Adicionando uma grade ao gráfico
    plt.legend(loc='upper left', fontsize=11) #Adicionando a legenda ao gráfico
    plt.tight_layout() #Ajustando o layout do gráfico para que não haja sobreposição de elementos
    plt.show() #Exibindo o gráfico

# ==========================
# Gerar gráficos
# ==========================

grafico(bits, cra_area, cla_area, csa_area, csla_area,
         'Área × Número de Bits',
         'Área (µm²)')

grafico(bits, cra_delay, cla_delay, csa_delay, csla_delay,
         'Delay × Número de Bits',
         'Delay (ns)')

grafico(bits, cra_cells, cla_cells, csa_cells, csla_cells,
         'Número de Células × Número de Bits',
         'Número de Células')

# ==========================
# Gráfico Relação entre Área e Delay
# ==========================

def grafico_area_delay(): 

    plt.figure(figsize=(8,5))

    # CRA
    plt.plot(cra_area, cra_delay,
             '-o',
             color=cores['CRA'],
             linewidth=2,
             markersize=7,
             label='CRA')

    # CLA
    plt.plot(cla_area, cla_delay,
             '-*',
             color=cores['CLA'],
             linewidth=2,
             markersize=7,
             label='CLA')

    # CSA
    plt.plot(csa_area, csa_delay,
             '-^',
             color=cores['CSA'],
             linewidth=2,
             markersize=7,
             label='CSA')

    # CSLA
    plt.plot(csla_area, csla_delay,
             '-D',
             color=cores['CSLA'],
             linewidth=2,
             markersize=7,
             label='CSLA')

    plt.title('Relação entre Área e Delay',
              fontsize=14,
              fontweight='bold')

    plt.xlabel('Área (µm²)', fontsize=12)
    plt.ylabel('Delay (ns)', fontsize=12)

    plt.xticks(fontsize=10)
    plt.yticks(fontsize=10)

    plt.grid(True, linestyle='--', alpha=0.5)
    plt.legend(loc='upper left', fontsize=11)

    plt.tight_layout()
    plt.show()


# Gera o gráfico
grafico_area_delay()

#Para rodar o script, basta executar o comando:
# python3 Scripts/adders_comparison.py
