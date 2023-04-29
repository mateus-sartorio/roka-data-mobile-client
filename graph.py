import sys
import calendar
import pandas
import math
import matplotlib.pyplot as plt

dict_meses = {
    '1': 'janeiro',
    '2': 'fevereiro',
    '3': 'março',
    '4': 'abril',
    '5': 'maio',
    '6': 'junho',
    '7': 'julho',
    '8': 'agosto',
    '9': 'setembro',
    '10': 'outubro',
    '11': 'novembro',
    '12': 'dezembro'
}

def inicializa_identificacao_residencias(dicionario_moradores, data_frame, mes_int_arg):
    for _, row in data_frame.iterrows():
        data_e_hora = row['Carimbo de data/hora']
        
        try:
            mes = data_e_hora[3:5]
            mes_int = int(mes)

            if mes_int != mes_int_arg:
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

def calcula_soma_pesos_residencias(dicionario_moradores, data_frame, mes_int_arg):
    for _, row in data_frame.iterrows():
        data_e_hora = row['Carimbo de data/hora']
        
        try:
            mes = data_e_hora[3:5]
            mes_int = int(mes)

            if mes_int != mes_int_arg:
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

def cria_data_dict(dicionario_moradores):
    data = {'id': [], 'peso': []}
    for key, value in dicionario_moradores.items():
        data['id'].append(key)
        data['peso'].append(value)

    return data

df = pandas.read_csv('https://docs.google.com/spreadsheets/d/e/2PACX-1vRDwsNJ7ECerA3SXYh3vr_04xxc4ek_fqR070Pxb_2oBf2EJ62DW35NpEl-IJUAnNZv9ySBUEIB7WlL/pub?output=csv')
moradores_dict = {}
inicializa_identificacao_residencias(moradores_dict, df, int(sys.argv[1]))
calcula_soma_pesos_residencias(moradores_dict, df, int(sys.argv[1]))

df2 = pandas.read_csv('https://docs.google.com/spreadsheets/d/e/2PACX-1vQzjDbWR4NjkH0wnjbUHlrkGtcFiv-FJUfx3_mCwFGG3h1HM1wxbgMklvF3Q8ZQdwVL6xPc0NkH9zfM/pub?output=csv')
moradores_dict_2 = {}
inicializa_identificacao_residencias(moradores_dict_2, df2, int(sys.argv[2]))
calcula_soma_pesos_residencias(moradores_dict_2, df2, int(sys.argv[2]))

data1 = cria_data_dict(moradores_dict)
data2 = cria_data_dict(moradores_dict_2)

d1 = {}
for index, id in enumerate(data1['id']):
    d1[id] = data1['peso'][index]

d2 = {}
for index, id in enumerate(data2['id']):
    d2[id] = data2['peso'][index]

# todas_resisdencias = (d1 | d2).keys()
# data_combinada = {'id': [], '2022': [], '2023': []}
# for key in todas_resisdencias:
#     data_combinada['id'].append(key)
#     
#     peso2022 = 0
#     peso2023 = 0
#     
#     try:
#         peso2022 = d1[key]
#     except:
#         peso2022 = 0

#     try:
#         peso2023 = d2[key]
#     except:
#         peso2023 = 0
#     
#     data_combinada['2022'].append(peso2022)
#     data_combinada['2023'].append(peso2023)

# data_plotavel = pandas.DataFrame(data_combinada)
# data_plotavel.plot(kind='bar', x='id', title='Peso de plástico por morador')
# plt.ylabel('Peso (kg)')
# plt.xlabel('Residência')
# plt.xticks(rotation=90)
# plt.grid(True)
# plt.yticks(ticks=[0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60])
# plt.subplots_adjust(bottom=0.2)

data_plotavel = pandas.DataFrame(data1)
data_plotavel.plot(kind='bar', x='id', title=f'Peso de plástico por morador em {dict_meses[sys.argv[1]]} de 2022')
plt.ylabel('Peso (kg)')
plt.xlabel('Residência')
plt.xticks(rotation=90)
plt.grid(True)
plt.yticks(ticks=[0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60])
plt.subplots_adjust(bottom=0.2)

data_plotavel = pandas.DataFrame(data2)
data_plotavel.plot(kind='bar', x='id', title=f'Peso de plástico por morador em {dict_meses[sys.argv[2]]} de 2023')
plt.ylabel('Peso (kg)')
plt.xlabel('Residência')
plt.xticks(rotation=90)
plt.grid(True)
plt.yticks(ticks=[0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60])
plt.subplots_adjust(bottom=0.2)

plt.show()
