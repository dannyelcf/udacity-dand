library(dplyr)
library(lubridate)
library(stringr)
library(readr)

# Load issues tracking data set exported by "issues_export_csv.py" script.
issues <- read.csv("issues_exported.csv", stringsAsFactors=FALSE, na.strings = "")

# Rename columns of issues data set. Translate their names from Portuguese to 
# English.
issues <- 
  issues %>%
    rename(issue_id = id_tarefa, 
           issue_number = num_tarefa,
           issue_title = titulo_tarefa,
           issue_type = tipo_tarefa,
           issue_creation_date = data_cadastro_tarefa,
           issue_system = sistema_tarefa,
           issue_start_date = data_inicio_tarefa,
           issue_subsystem = subsistema_tarefa,
           issue_deadline_date = data_deadline_tarefa,
           issue_created_by = aberta_por_tarefa,
           issue_stakeholder = localizacao_analista_tarefa,
           issue_status = situacao_tarefa,
           issue_time_spent = horas_trabalhadas_tarefa,
           issue_relationship_manager = gerente_relacionamento_tarefa,
           issue_priority_number = num_prioridade_tarefa,
           issue_progress = andamento_tarefa,
           issue_priority_scale = prioridade_tarefa,
           log_build_info = dados_build_log,
           log_creation_date = data_cadastro_log,
           log_action = atividade_log,
           log_status = situacao_log,
           log_progress = andamento_log,
           log_time_spent = horas_trabalhadas_log,
           log_created_by = aberto_por_log,
           log_svn_revision = revisao_svn_log)
  

# Grouping the 65 issues type in four types: CUSTOMIZATION, MAINTENANCE, DATA 
# MIGRATION and OTHERS.
issues <- 
  issues %>%
    mutate(issue_type = recode(issue_type,
      "CUSTOMIZACAO DE FUNCIONALIDADE EXISTENTE" = "CUSTOMIZATION",
      "SUSTENTAÇÃO / ERRO EM PRODUÇÃO" = "MAINTENANCE",
      "SUSTENTAÇÃO / AMBIENTE FORA DO AR" = "MAINTENANCE",
      "MIGRAÇÃO DE DADOS" = "DATA MIGRATION",
      "SUSTENTAÇÃO / ERRO EM CUSTOMIZAÇÃO REALIZADA" = "MAINTENANCE",
      "SUSTENTAÇÃO" = "MAINTENANCE",
      "SUSTENTAÇÃO / ALTERAÇÕES DIRETAMENTE NO BANCO DE DADOS" = "MAINTENANCE",
      "SUSTENTAÇÃO / OUTRAS DEMANDAS" = "MAINTENANCE",
      "SUSTENTAÇÃO / DÚVIDAS DE NEGÓCIO" = "MAINTENANCE",
      "DEMANDAS EM AMBIENTES DE APOIO / DEMANDA EM AMBIENTE DE IMPLANTAÇÃO/HOMOLOGAÇÃO" = "MAINTENANCE",
      "ERRO DE VALIDAÇÃO INTERNA" = "MAINTENANCE",
      "CASO DE USO/NOVA FUNCIONALIDADE" = "CUSTOMIZATION",
      "SUSTENTAÇÃO / ERRO DE MIGRAÇÃO REALIZADA" = "MAINTENANCE",
      "DISPONIBILIZAÇÃO DE MÓDULO EM PRODUÇÃO" = "MAINTENANCE",
      "DOCUMENTAÇÃO" = "OTHERS",
      "SUSTENTAÇÃO / OUTRAS DEMANDAS DE INFRAESTRUTURA" = "MAINTENANCE",
      "SUSTENTAÇÃO / ATUALIZAÇÃO DE AMBIENTE DE TREINAMENTO" = "MAINTENANCE",
      "TAREFA DE ROTINA" = "MAINTENANCE",
      "APRIMORAMENTO EM SUSTENTACAO" = "CUSTOMIZATION",
      "DEMANDAS EM AMBIENTES DE APOIO / DEMANDA EM OUTROS AMBIENTES" = "MAINTENANCE",
      "SUSTENTAÇÃO / ANÁLISE DE CUSTOMIZAÇÃO" = "MAINTENANCE",
      "ERRO DE VALIDAÇÃO DO CLIENTE" = "MAINTENANCE",
      "VALIDAÇÃO" = "MAINTENANCE",                                                                
      "AMBIENTE/INFRA-ESTRUTURA / ERRO DEVIDO À ATUALIZAÇÃO DE VERSÃO" = "MAINTENANCE",                
      "DEMANDAS EM AMBIENTES DE APOIO / DEMANDA EM AMBIENTE DE TREINAMENTO" = "MAINTENANCE",          
      "MERGE SELETIVO DE FUNCIONALIDADES" = "CUSTOMIZATION",                                            
      "AMBIENTE/INFRA-ESTRUTURA" = "MAINTENANCE",                                                       
      "AMBIENTE/INFRA-ESTRUTURA / OUTRAS DEMANDAS INTERNAS DE INFRAESTRUTURA" = "MAINTENANCE",          
      "VERIFICAÇÃO" = "MAINTENANCE",                                                                     
      "SUSTENTAÇÃO / ATIVIDADE PROATIVA" = "MAINTENANCE",                                                
      "SUSTENTAÇÃO / ERRO DEVIDO À ATUALIZAÇÃO DE VERSÃO" = "MAINTENANCE",                               
      "SUSTENTAÇÃO / ERRO APÓS ENCERRAMENTO DO CONTRATO" = "MAINTENANCE",                                
      "SUSTENTAÇÃO / AUDITORIA" = "MAINTENANCE",                                                         
      "SUSTENTAÇÃO / RELATÓRIO EXTRAÍDO DO BANCO DE DADOS" = "MAINTENANCE",                              
      "SUSTENTAÇÃO / ERRO DE IMPLANTAÇÃO DE MÓDULO EM PRODUÇÃO" = "MAINTENANCE",                         
      "SUSTENTAÇÃO / PRE ORÇAMENTO" = "MAINTENANCE",                                                    
      "PROJETO BÁSICO DE CUSTOMIZAÇÕES" = "OTHERS",                                                
      "ANÁLISE TÉCNICA" = "MAINTENANCE",                                                               
      "SUGESTÃO DE MELHORIA" = "MAINTENANCE",                                                            
      "ATUALIZAÇÃO DE AMBIENTE" = "MAINTENANCE",                                                         
      "AMBIENTE/INFRA-ESTRUTURA / AMBIENTE FORA DO AR." = "MAINTENANCE",                                  
      "AMBIENTE/INFRA-ESTRUTURA / OUTRAS DEMANDAS" = "MAINTENANCE",                                       
      "DEMANDAS EM AMBIENTES DE APOIO / ERRO EM PRODUÇÃO" = "MAINTENANCE",                                
      "ATESTE DE OS PELO CLIENTE (NÍVEL 2)" = "OTHERS",                                       
      "AGRUPAMENTO DE DEMANDAS" = "OTHERS",                                                        
      "SUSTENTAÇÃO / PROJETO DETALHADO" = "MAINTENANCE",                                                
      "PROJETO BÁSICO DE CUSTOMIZAÇÕES / PRE ORÇAMENTO" = "OTHERS",                                
      "MERGE/ATUALIZAÇÃO DE VERSÃO" = "MAINTENANCE",                                                    
      "AMBIENTE/INFRA-ESTRUTURA / ATIVIDADE PROATIVA" = "MAINTENANCE",                                  
      "ERRO DE AMBIENTE" = "MAINTENANCE",                                                               
      "PARAMETRIZAÇÃO DE REGRA DE NEGÓCIO" = "MAINTENANCE",                                             
      "DÚVIDA" = "OTHERS",                                                                         
      "RELATÓRIO" = "OTHERS",                                                                      
      "ATUALIZAÇÃO DE BASE DE DADOS" = "MAINTENANCE",                                                    
      "REUNIÃO" = "OTHERS",                                                                        
      "AMBIENTE/INFRA-ESTRUTURA / RESTAURAR BANCO DE DADOS" = "MAINTENANCE",                             
      "CORREÇÃO DE ERROS DE ROTEIRO" = "MAINTENANCE",                                                    
      "RETORNO DO CLIENTE - GUIA DE VERIFICAÇÃO" = "OTHERS",                                       
      "AMBIENTE/INFRA-ESTRUTURA / ERRO EM CUSTOMIZAÇÃO REALIZADA" = "MAINTENANCE",                      
      "VALIDAÇÃO DE ROTEIROS NA SIG (NÍVEL 1)" = "MAINTENANCE",                                        
      "DESIGN/CRIAÇÃO" = "MAINTENANCE",                                      
      "MANUTENÇÃO COSMÉTICA" = "MAINTENANCE",
      "COLETA INFORMAÇÕES" = "OTHERS",
      "ORDEM DE SERVIÇO / CUSTOMIZAÇÃO" = "OTHERS",
      "TAREFA DE ROTINA / OUTRAS DEMANDAS" = "OTHERS"))

# Cast date variables to Date and POSIXct types
issues <- 
  issues %>%
    mutate(issue_creation_date = dmy_hms(issues$issue_creation_date),
           issue_start_date = dmy(issues$issue_start_date),
           issue_deadline_date = dmy(issues$issue_deadline_date),
           log_creation_date = dmy_hm(issues$log_creation_date),
           issue_time_spent = seconds_to_period(
                                ifelse(str_detect(issues$issue_time_spent, "h"),
                                       issues$issue_time_spent %>% 
                                         str_replace(",", ".") %>% 
                                         str_replace("h", "") %>% 
                                         as.double() * 60,
                                       NA)
                              ),
           log_time_spent = hms(
                              ifelse(str_detect(issues$log_time_spent, "min"),
                                     issues$log_time_spent %>% 
                                       paste("0s") %>%
                                       str_pad(8, pad ="0") %>% 
                                       str_pad(9, pad =" ") %>% 
                                       str_pad(10, pad ="h") %>%
                                       str_pad(11, pad ="0"),
                                     NA)
                              ))
  
issues <- 
  issues %>%
    mutate(issue_progress = issues$issue_progress %>% 
                              str_replace("%", "") %>% 
                              as.integer(),
           log_progress = issues$log_progress %>% 
                            str_replace("%", "") %>% 
                            as.integer())

issues <- 
  issues %>%
    mutate(log_svn_revision = issues$log_svn_revision %>% 
                                str_replace("Revisão:", "") %>% 
                                as.integer())

# Write in CSV the issses data.frame after cleaning process.
write.csv(issues, "../issues_tracking.csv", na = "", row.names = FALSE)

