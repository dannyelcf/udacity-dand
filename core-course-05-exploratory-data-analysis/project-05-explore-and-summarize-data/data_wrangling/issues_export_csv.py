#!/usr/bin/env python
#coding: utf-8

"""
Doc
"""
import re
import io
import os
from bs4 import BeautifulSoup
from datetime import date, datetime
from unicodecsv import DictWriter

TAREFAS_DIR = '/Users/dannyelcf/Documents/Tarefas_SIGProject2/tarefas'
STRIP_CHARACTERS = ' \t\n\r'
STRIP_CHARACTERS_DATE = STRIP_CHARACTERS + '-'

def __titulo_tarefa(bs):
    titulo_tarefa = bs.find(id='formPainelTarefa').h2.text.strip(STRIP_CHARACTERS)
    num_tarefa = re.findall(r'(\d+)', titulo_tarefa)[0]
    return {'num_tarefa': num_tarefa,
            'titulo_tarefa': titulo_tarefa}

def __to_str_or_none(text):
    text = re.sub(r'[ \t\n\r]+', ' ', text)
    if text == '' or text == ' ':
        return None
    return text

def __cabecalho_tarefa(bs):
    list_td = bs.find(id='formPainelTarefa').table.findAll('td')
    tipo_tarefa = list_td[0].text.strip(STRIP_CHARACTERS)
    tipo_tarefa = __to_str_or_none(tipo_tarefa)
    data_cadastro_tarefa = list_td[1].text.strip(STRIP_CHARACTERS_DATE)
    data_cadastro_tarefa = __to_str_or_none(data_cadastro_tarefa)
    sistema_tarefa = list_td[2].text.strip(STRIP_CHARACTERS)
    sistema_tarefa = __to_str_or_none(sistema_tarefa)
    data_inicio_tarefa = list_td[3].text.strip(STRIP_CHARACTERS_DATE)
    data_inicio_tarefa = __to_str_or_none(data_inicio_tarefa)
    subsistema_tarefa = list_td[4].text.strip(STRIP_CHARACTERS)
    subsistema_tarefa = __to_str_or_none(subsistema_tarefa)
    data_deadline_tarefa = list_td[5].text.strip(STRIP_CHARACTERS_DATE)
    data_deadline_tarefa = __to_str_or_none(data_deadline_tarefa)
    aberta_por_tarefa = list_td[6].text.strip(STRIP_CHARACTERS)
    aberta_por_tarefa = re.findall(r'(.*)', aberta_por_tarefa)
    if len(aberta_por_tarefa) <= 2:
        localizacao_analista_tarefa = 'CERCOMP'
    else:
        localizacao_analista_tarefa = 'EMPRESA'
    aberta_por_tarefa = aberta_por_tarefa[0]
    aberta_por_tarefa = aberta_por_tarefa.strip(STRIP_CHARACTERS)
    aberta_por_tarefa = __to_str_or_none(aberta_por_tarefa)
    situacao_tarefa = list_td[8].text.strip(STRIP_CHARACTERS)
    situacao_tarefa = __to_str_or_none(situacao_tarefa)
    horas_trabalhadas_tarefa = list_td[9].text.strip(STRIP_CHARACTERS)
    horas_trabalhadas_tarefa = __to_str_or_none(horas_trabalhadas_tarefa)
    gerente_relacionamento_tarefa = list_td[10].text.strip(STRIP_CHARACTERS)
    gerente_relacionamento_tarefa = __to_str_or_none(gerente_relacionamento_tarefa)
    num_prioridade_tarefa = list_td[12].text.strip(STRIP_CHARACTERS)
    num_prioridade_tarefa = __to_str_or_none(num_prioridade_tarefa)
    andamento_tarefa = list_td[13].text.strip(STRIP_CHARACTERS)
    andamento_tarefa = __to_str_or_none(andamento_tarefa)
    prioridade_tarefa = list_td[14].text.strip(STRIP_CHARACTERS)
    prioridade_tarefa = __to_str_or_none(prioridade_tarefa)

    return {'tipo_tarefa': tipo_tarefa,
            'data_cadastro_tarefa': data_cadastro_tarefa,
            'sistema_tarefa': sistema_tarefa,
            'data_inicio_tarefa': data_inicio_tarefa,
            'subsistema_tarefa': subsistema_tarefa,
            'data_deadline_tarefa': data_deadline_tarefa,
            'aberta_por_tarefa': aberta_por_tarefa,
            'localizacao_analista_tarefa': localizacao_analista_tarefa,
            'situacao_tarefa': situacao_tarefa,
            'horas_trabalhadas_tarefa': horas_trabalhadas_tarefa,
            'gerente_relacionamento_tarefa': gerente_relacionamento_tarefa,
            'num_prioridade_tarefa': num_prioridade_tarefa,
            'andamento_tarefa': andamento_tarefa,
            'prioridade_tarefa': prioridade_tarefa}

def __is_even(num):
    if (num % 2) == 0:
        return True
    return False

def __cabecalho_log(bs):
    list_log = list()
    table = bs.find(id='historio2')
    if table != None:
        list_tr = table.findAll('tr', {'style': 'background-color: #C8D5EC;'})
        elem = iter(list_tr) 
        while True:
            try:
                tr = next(elem)
                list_td = tr.findAll('td')
                data_cadastro_log = list_td[1].text.strip(STRIP_CHARACTERS)
                data_cadastro_log = __to_str_or_none(data_cadastro_log)
                atividade_log = list_td[2].text.strip(STRIP_CHARACTERS)
                atividade_log = __to_str_or_none(atividade_log)
                situacao_log = list_td[3].text.strip(STRIP_CHARACTERS)
                situacao_log = __to_str_or_none(situacao_log)
                andamento_log = list_td[4].text.strip(STRIP_CHARACTERS)
                andamento_log = __to_str_or_none(andamento_log)
                horas_trabalhadas_log = list_td[5].text.strip(STRIP_CHARACTERS)
                horas_trabalhadas_log = __to_str_or_none(horas_trabalhadas_log)
                aberto_por_log = list_td[6].span["title"].strip(STRIP_CHARACTERS)
                aberto_por_log = __to_str_or_none(aberto_por_log)
                revisao_svn_log = list_td[7].text.strip(STRIP_CHARACTERS)
                revisao_svn_log = __to_str_or_none(revisao_svn_log)

                tr = next(elem)
                dados_build_log = tr.text.strip(STRIP_CHARACTERS)
                dados_build_log = __to_str_or_none(dados_build_log)

                list_log.append({'dados_build_log': dados_build_log,
                                'data_cadastro_log': data_cadastro_log,
                                'atividade_log': atividade_log,
                                'situacao_log': situacao_log,
                                'andamento_log': andamento_log,
                                'horas_trabalhadas_log': horas_trabalhadas_log,
                                'aberto_por_log': aberto_por_log,
                                'revisao_svn_log': revisao_svn_log})
            except StopIteration: 
                break
    return list_log

def __build_tarefa(bs):
    tarefa = dict()
    tarefa.update(__titulo_tarefa(bs))
    tarefa.update(__cabecalho_tarefa(bs))
    return tarefa

def __to_list_tarefa_logs(html):
    list_tarefa_logs = list()
    bs = BeautifulSoup(html, 'html.parser')
    tarefa = __build_tarefa(bs)
    logs = __cabecalho_log(bs)

    if len(logs) == 0:
        log = {'dados_build_log': None,
               'data_cadastro_log': None,
               'atividade_log': None,
               'situacao_log': None,
               'andamento_log': None,
               'horas_trabalhadas_log': None,
               'aberto_por_log': None,
               'revisao_svn_log':None}
        log.update(tarefa)
        list_tarefa_logs.append(log)
    else:
        for log in logs:
            log.update(tarefa)
            list_tarefa_logs.append(log)

    return list_tarefa_logs

if __name__ == '__main__': 
    print("Exporting tarefas to CSV...")
    with open(TAREFAS_DIR + '/../csv/data_exported.csv', 'wb') as fout:
        csv_writer = DictWriter(fout, fieldnames=['id_tarefa',
                                                  'num_tarefa',
                                                  'titulo_tarefa',
                                                  'tipo_tarefa',
                                                  'data_cadastro_tarefa',
                                                  'sistema_tarefa',
                                                  'data_inicio_tarefa',
                                                  'subsistema_tarefa',
                                                  'data_deadline_tarefa',
                                                  'aberta_por_tarefa',
                                                  'localizacao_analista_tarefa',
                                                  'situacao_tarefa',
                                                  'horas_trabalhadas_tarefa',
                                                  'gerente_relacionamento_tarefa',
                                                  'num_prioridade_tarefa',
                                                  'andamento_tarefa',
                                                  'prioridade_tarefa',
                                                  'dados_build_log',
                                                  'data_cadastro_log',
                                                  'atividade_log',
                                                  'situacao_log',
                                                  'andamento_log',
                                                  'horas_trabalhadas_log',
                                                  'aberto_por_log',
                                                  'revisao_svn_log'])
        csv_writer.writeheader()
        for tarefa_filename in os.listdir(TAREFAS_DIR):
            id_tarefa = re.findall(r'(\d+)', tarefa_filename)[0]
            tarefa_filepath = TAREFAS_DIR + '/' + tarefa_filename
            with io.open(tarefa_filepath, 'r', encoding='utf-8') as fin:
                list_tarefa_logs = __to_list_tarefa_logs(fin.read())
                for tarefa_log in list_tarefa_logs:
                    tarefa_log.update({'id_tarefa': id_tarefa})
                    csv_writer.writerow(tarefa_log)
       
    print("Done!")
        
