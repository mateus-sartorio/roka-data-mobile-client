import pandas
import math
import matplotlib.pyplot as plt

from meses import dict_meses
from links import links

def plota_grafico(data, titulo, peso_maximo):
    ticks = list(range(0, int(peso_maximo) + 5, 5))
    data_plotavel = pandas.DataFrame(data)
    data_plotavel.plot(kind='bar', x='id', title=titulo)
    plt.ylabel('Peso (kg)')
    plt.xlabel('Residência')
    plt.xticks(rotation=90)
    plt.grid(True)
    plt.yticks(ticks=ticks)
    plt.subplots_adjust(bottom=0.2)
    plt.show()

def cria_data_dict(dicionario_moradores):
    data = {'id': [], 'peso': []}
    peso_maximo = 0
    for key, value in dicionario_moradores.items():
        if value > peso_maximo:
            peso_maximo = value
        
        data['id'].append(key)
        data['peso'].append(value)

    return data, peso_maximo

def inicializa_identificacao_residencias(data_frame, mes_inicial, mes_final):
    dicionario_moradores = {}
    for _, row in data_frame.iterrows():
        data_e_hora = row['Carimbo de data/hora']
        
        try:
            mes = data_e_hora[3:5]
            mes_int = int(mes)

            if (mes_inicial != -1) and (mes_int < mes_inicial or mes_int > mes_final):
                continue
        except:
            continue

        nome = row['Número de identificação da residência ou nome do morador']

        if type(nome) is float:
            continue

        try:
            nome_parsed = str(int(nome)) 
        except:
            nome_parsed = nome
        
        nome_parsed = nome_parsed[0:15]
        dicionario_moradores[nome_parsed] = 0

    return dicionario_moradores

def calcula_soma_pesos_residencias(dicionario_moradores, data_frame, mes_inicial, mes_final):
    for _, row in data_frame.iterrows():
        data_e_hora = row['Carimbo de data/hora']
        
        try:
            mes = data_e_hora[3:5]
            mes_int = int(mes)

            if (mes_inicial != -1) and (mes_int < mes_inicial or mes_int > mes_final):
                continue
        except:
            continue

        nome = row['Número de identificação da residência ou nome do morador']

        if type(nome) is float:
            continue

        try:
            nome_parsed = str(int(nome))
        except:
            nome_parsed = str(nome)

        peso = float(str(row['Quantidade de resíduo coletado em KG\n\n(insira o valor utilizando vírgula)']).replace(',', '.'))
        
        if math.isnan(peso):
            peso = 0
        
        nome_parsed = nome_parsed[0:15]
        dicionario_moradores[nome_parsed] += peso

def plota_ambos():
    df2022 = pandas.read_csv(links['2022'])
    
    dicionario_moradores_2022 = inicializa_identificacao_residencias(df2022, -1, -1)
    calcula_soma_pesos_residencias(dicionario_moradores_2022, df2022, -1, -1)
    
    df2023 = pandas.read_csv(links['2023'])
    dicionario_moradores_2023 = inicializa_identificacao_residencias(df2023, -1, -1)
    calcula_soma_pesos_residencias(dicionario_moradores_2023, df2023, -1, -1)

    data2022, peso_maximo_2022 = cria_data_dict(dicionario_moradores_2022)
    data2023, peso_maximo_2023 = cria_data_dict(dicionario_moradores_2023)

    d1 = {}
    for index, id in enumerate(data2022['id']):
        d1[id] = data2022['peso'][index]

    d2 = {}
    for index, id in enumerate(data2023['id']):
        d2[id] = data2023['peso'][index]

    todas_resisdencias = (d1 | d2).keys()
    data_combinada = {'id': [], '2022': [], '2023': []}

    for key in todas_resisdencias:
        data_combinada['id'].append(key)
        
        peso2022 = 0
        peso2023 = 0
        
        try:
            peso2022 = d1[key]
        except:
            peso2022 = 0

        try:
            peso2023 = d2[key]
        except:
            peso2023 = 0

        data_combinada['2022'].append(peso2022)
        data_combinada['2023'].append(peso2023)
    
    plota_grafico(data_combinada, 'Peso de plástico coletado por residência', max(peso_maximo_2022, peso_maximo_2023))

def plota_ano(ano, link):
    mes_inicial = -1
    mes_final = -1
    while True:
        resposta = input('Deseja escolher um mes especifico? [s/n]: ')
        if resposta == 's':
            mes_inicial = int(input('Qual o mes inicial?: '))
            mes_final = int(input('Qual o mes final?: '))
            break
        elif resposta == 'n':
            mes_inicial = -1
            mes_final = -1
            break
        else:
            print('Por favor insira uma resposta valida (s ou n)')           

    df = pandas.read_csv(link)

    dicionario_moradores = inicializa_identificacao_residencias(df, mes_inicial, mes_final)
    calcula_soma_pesos_residencias(dicionario_moradores, df, mes_inicial, mes_final)
    
    data, peso_maximo = cria_data_dict(dicionario_moradores)

    if mes_final == mes_inicial and mes_inicial > 0:
        plota_grafico(data, f'Peso de plástico por morador em {dict_meses[mes_inicial]} de {ano}', peso_maximo)
    elif mes_inicial > 0:
        plota_grafico(data, f'Peso de platico por morador entre {dict_meses[mes_inicial]} e {dict_meses[mes_final]} de {ano}', peso_maximo)
    else:
        plota_grafico(data, f'Peso de plastico por morador em {ano}', peso_maximo)

while True:
    resposta = input('Qual ano você quer? 2022, 2023 ou ambos?: ')
    if resposta == 'ambos':
        plota_ambos()
        break
    elif resposta == '2022':
        plota_ano('2022', links['2022'])
        break
    elif resposta == '2023':
        plota_ano('2023', links['2023'])
        break
    else:
        print('Por favor insira uma resposta válida (2022, 2023 ou ambos)')
