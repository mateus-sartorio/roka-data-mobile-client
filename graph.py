import pandas
import math
import matplotlib.pyplot as plt

df = pandas.read_csv('https://docs.google.com/spreadsheets/d/e/2PACX-1vRDwsNJ7ECerA3SXYh3vr_04xxc4ek_fqR070Pxb_2oBf2EJ62DW35NpEl-IJUAnNZv9ySBUEIB7WlL/pub?output=csv')

# print(df.columns.tolist())
# print(df.to_csv())

moradores_dict = {}
for index, row in df.iterrows():
    nome = row['Número de identificação da residência ou nome do morador']

    if type(nome) is float:
        continue

    moradores_dict[nome] = 0

for value in moradores_dict.keys():
    print(value)

for index, row in df.iterrows():
    nome = row['Número de identificação da residência ou nome do morador']

    if type(nome) is float:
        continue

    peso = float(str(row['Quantidade de resíduo coletado em KG\n\n(insira o valor utilizando vírgula)']).replace(',', '.'))
    
    if math.isnan(peso):
        peso = 0

    moradores_dict[nome] += peso

data = {'id': [], 'peso': []}
for key, value in moradores_dict.items():
    data['id'].append(key)
    data['peso'].append(value)

data_2 = pandas.DataFrame(data)
data_2.plot(kind='bar', x='id', title='Peso de plastico por morador')
plt.show()