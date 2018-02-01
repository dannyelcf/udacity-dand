#!/usr/bin/env python
#coding: utf-8

import re
import requests
from selenium import webdriver
from datetime import datetime, date, timedelta

#------------------------------------------------------------------------------

def read_checkpoint(file_path):
    with open(file_path, "r") as f:
        return datetime.strptime(f.readline(), "%d/%m/%Y").date()

def write_checkpoint(file_path, new_date):
    with open(file_path, "w") as f:
        f.write(new_date)
#------------------------------------------------------------------------------

USER = ""
PASSWORD = ""
CHECKPOINT_FILE = "checkpoint.txt"

START_DATE = read_checkpoint(CHECKPOINT_FILE)
END_DATE = date.today()
TIME_DELTA = timedelta(days=1)

PATH_CHROME_DRIVER = "./chromedriver"
CHROME_PREFS = {"profile.managed_default_content_settings.images": 2}
CHUNK_SIZE = 1024*64

PAGE_LOGIN = "https://sigproject.esig.com.br/iproject/login.jsf"
PAGE_LOGIN_ELEMENT_LOGIN = "login"
PAGE_LOGIN_ELEMENT_SENHA = "senha"
PAGE_LOGIN_ELEMENT_LOGAR = "//input[@type='submit'][@value='Logar']"

PAGE_CONSULTA_TAREFAS = "https://sigproject.esig.com.br/iproject/Tarefa/consulta.jsf"
PAGE_CONSULTA_TAREFAS_ELEMENT_BUSCA_ABERTA_EM = "formBuscaTarefa:buscaAbertaEm"
PAGE_CONSULTA_TAREFAS_ELEMENT_DATA_INICIO = "formBuscaTarefa:dataInicio"
PAGE_CONSULTA_TAREFAS_ELEMENT_DATA_FIM = "formBuscaTarefa:dataFim"
PAGE_CONSULTA_TAREFAS_ELEMENT_BUSCAR = "//input[@type='submit'][@value='Buscar']"

PAGE_TAREFA = "https://sigproject.esig.com.br/iproject/Tarefa/ajaxView.jsf?id={0}"
PAGE_TAREFA_ELEMENT_LINKS_ANEXOS = "//a[starts-with(@href,'/iproject/verArquivo')]"
PAGE_TAREFA_ELEMENT_IMAGEM_LINK_ANEXO = ".//img"

PAGE_ANEXO = "https://sigproject.esig.com.br/iproject/verArquivo?idArquivo={0}&key={1}"

REGEX_ID_TAREFAS = r"exibirPainel\((\d+)\)"
REGEX_ID_ARQUIVO_AND_KEY = r"idArquivo=(\d+)&key=(\w+)"
REGEX_EXTENSAO_ARQUIVO = r"\.(\w+)"

PATTERN_ATUAL_PATH_ARQUIVO = "\"/iproject/verArquivo\?idArquivo={0}&amp;key={1}.*\""
PATTERN_PATH_ANEXO_ARQUIVO = "anexos/{0}"
PATTERN_PATH_TAREFA_ARQUIVO = "tarefas/{0}.html"

#------------------------------------------------------------------------------
try:
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_experimental_option("prefs", CHROME_PREFS)
    chrome_options.add_argument("--headless")
    driver = webdriver.Chrome(PATH_CHROME_DRIVER, chrome_options = chrome_options)

    driver.get(PAGE_LOGIN)
    driver.find_element_by_name(PAGE_LOGIN_ELEMENT_LOGIN).send_keys(USER)
    driver.find_element_by_name(PAGE_LOGIN_ELEMENT_SENHA).send_keys(PASSWORD)
    driver.find_element_by_xpath(PAGE_LOGIN_ELEMENT_LOGAR).click()

    cookies_list = driver.get_cookies()
    cookies_dict = {}
    for cookie in cookies_list:
        cookies_dict[cookie['name']] = cookie['value']

    data_inicio = START_DATE
    data_fim = data_inicio + TIME_DELTA

    while (data_inicio <= END_DATE):
        print data_inicio.strftime("%d/%m/%Y") + " - " + data_fim.strftime("%d/%m/%Y")

        driver.get(PAGE_CONSULTA_TAREFAS)
        checkbox = driver.find_element_by_id(PAGE_CONSULTA_TAREFAS_ELEMENT_BUSCA_ABERTA_EM)
        if not checkbox.is_selected():
            checkbox.click()
        driver.find_element_by_id(PAGE_CONSULTA_TAREFAS_ELEMENT_DATA_INICIO).send_keys(data_inicio.strftime("%d/%m/%Y"))
        driver.find_element_by_id(PAGE_CONSULTA_TAREFAS_ELEMENT_DATA_FIM).send_keys(data_fim.strftime("%d/%m/%Y"))
        driver.find_element_by_xpath(PAGE_CONSULTA_TAREFAS_ELEMENT_BUSCAR).click()
        busca_page_source = driver.page_source

        for id_tarefa in re.findall(REGEX_ID_TAREFAS, busca_page_source):
            print "Getting tarefa: " + "{0}.html".format(id_tarefa)
            driver.get(PAGE_TAREFA.format(id_tarefa))
            tarefa_page_source = driver.page_source

            print "Finding all files in " + "{0}.html".format(id_tarefa)
            anexos_links = driver.find_elements_by_xpath(PAGE_TAREFA_ELEMENT_LINKS_ANEXOS)
            print "Found {0}".format(len(anexos_links)) + " files"
            for link in anexos_links:
                id_arquivo, key = re.findall(REGEX_ID_ARQUIVO_AND_KEY, link.get_attribute("href"))[0]
                file_name = link.find_element_by_xpath(PAGE_TAREFA_ELEMENT_IMAGEM_LINK_ANEXO).get_attribute("title")
                extensao_arquivo = ""

                extensao_list = re.findall(REGEX_EXTENSAO_ARQUIVO, file_name)
                if len(extensao_list) >= 1:
                    extensao_arquivo = extensao_list[-1]
                
                nome_arquivo = id_arquivo + "_" + key + "." + extensao_arquivo.lower()

                print "Downloading file: " + file_name
                r = requests.get(PAGE_ANEXO.format(id_arquivo, key), cookies=cookies_dict, stream=True)

                print "Opening file: " + PATTERN_PATH_ANEXO_ARQUIVO.format(nome_arquivo)
                with open(PATTERN_PATH_ANEXO_ARQUIVO.format(nome_arquivo), 'wb') as fd:
                    print "Writing file: " + nome_arquivo
                    i = CHUNK_SIZE
                    for chunk in r.iter_content(chunk_size=CHUNK_SIZE):
                        print "Writing chunk: {0}".format(i)
                        fd.write(chunk)
                        i = i + CHUNK_SIZE
                
                print "Changing file path para: " + "../" + PATTERN_PATH_ANEXO_ARQUIVO.format(nome_arquivo)
                atual_path_arquivo = PATTERN_ATUAL_PATH_ARQUIVO.format(id_arquivo, key)
                tarefa_page_source = re.sub(atual_path_arquivo, ("../" + PATTERN_PATH_ANEXO_ARQUIVO.format(nome_arquivo)), tarefa_page_source)
            
            with open(PATTERN_PATH_TAREFA_ARQUIVO.format(id_tarefa), "w") as fd:
                print "Writing tarefa: {0}.html".format(id_tarefa)
                fd.write(tarefa_page_source.encode('utf-8'))
        
        data_inicio = data_fim
        data_fim = data_inicio + TIME_DELTA
        write_checkpoint(CHECKPOINT_FILE, data_inicio.strftime("%d/%m/%Y"))
finally:
    driver.quit()
