library(dplyr)
library(lubridate)
library(stringr)
library(readr)

# Load issues tracking data set exported by "issues_export_csv.py" script.
issues <-
  read.csv("issues_exported.csv",
           stringsAsFactors = FALSE,
           na.strings = "")

# Drop column "gerente_relacionamento_tarefa" (issue_relationship_manager). 
# Its content is always NA.
issues <-
  issues %>%
  select(-one_of("gerente_relacionamento_tarefa"))

# Rename columns of issues data set. Translate their names from Portuguese to
# English.
issues <-
  issues %>%
  rename(
    issue_id = id_tarefa,
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
    log_svn_revision = revisao_svn_log
  )


# Rename issue_type values. Translate them from Portuguese to English.
# Grouping the 65 issue_type in four types: CUSTOMIZATION, MAINTENANCE, DATA
# MIGRATION and OTHERS.
# Cast issue_type from character to unordered factor.
issues <-
  issues %>%
  mutate(
    issue_type = recode(
      issue_type,
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
      "TAREFA DE ROTINA / OUTRAS DEMANDAS" = "OTHERS"
    )
  ) %>%
  mutate(issue_type = factor(issue_type))

# Rename issue_priority_scale values. Translate them from Portuguese to English.
# Cast issue_priority_scale from character to ordered factor.
issues <-
  issues %>%
  mutate(
    issue_priority_scale = recode(
      issue_priority_scale,
      "SUSPENSA" = "SUSPENDED",
      "BAIXA" = "LOW",
      "MEDIA" = "MEDIUM",
      "ALTA" = "HIGH",
      "URGENTE" = "URGENT",
      "BLOQUEANTE" = "BLOCKING"
    )
  ) %>%
  mutate(issue_priority_scale = factor(
    issue_priority_scale,
    levels = c("SUSPENDED",
               "LOW",
               "MEDIUM",
               "HIGH",
               "URGENT",
               "BLOCKING")
  ))
# Rename issue_stakeholder values. Translate them from Portuguese to English.
# Cast issue_stakeholder from character to unordered factor.
issues <-
  issues %>%
  mutate(issue_stakeholder = recode(
    issue_stakeholder,
    "CERCOMP" = "CUSTOMER",
    "EMPRESA" = "COMPANY"
  )) %>%
  mutate(issue_stakeholder = factor(issue_stakeholder))

# Rename issue_status values. Translate them from Portuguese to English.
# Cast issue_status from character to unordered factor.
issues <-
  issues %>%
  mutate(
    issue_status = recode(
      issue_status,
      "FINALIZADA" = "FINISHED",
      "CANCELADA" = "CANCELED",
      "RESOLVIDA" = "SOLVED",
      "PENDENTE INICIAR" = "PENDING START",
      "SOLICITADO ATUALIZAÇÃO PRODUÇÃO" = "REQUESTED PRODUCTION UPDATE",
      "AGUARD. AUTORIZAÇÃO PARA APRIMORAMENTO" = "WAITING FOR AUTHORIZATION FOR ENHANCEMENT",
      "PENDENTE FECHAMENTO CLIENTE" = "CUSTOMER CLOSING PENDING",
      "VALIDADA PARA PRODUÇÃO" = "VALIDATED FOR PRODUCTION",
      "AGUARDANDO RETORNO - SIG" = "WAITING FOR RETURN - COMPANY",
      "ERRO DE VALIDAÇÃO" = "VALIDATION ERROR"
    )
  ) %>%
  mutate(issue_status = factor(issue_status))

# Rename log_action values. Translate them from Portuguese to English.
# Cast log_action from character to unordered factor.
issues <-
  issues %>%
  mutate(
    log_action = recode(
      log_action,
      "ALTERAÇÃO DE TAREFA" = "ISSUE ALTERATION",
      "RESPOSTA AOS INTERESSADOS NA TAREFA" = "RESPONSE TO STAKEHOLDERS ON THE ISSUE",
      "SOLICITAÇÃO DE INTEGRAÇÃO EM VERSÃO" = "REQUEST FOR INTEGRATION IN VERSION",
      "COMPLEMENTO DE INFORMAÇÕES" = "COMPLEMENT OF INFORMATION",
      "ALTERAÇÃO DE RESPONSABILIDADE" = "CHANGE OF RESPONSIBILITY",
      "SOLICITAÇÃO DE ATUALIZAÇÃO DE BASE DE DADOS" = "REQUEST FOR UPDATING DATABASE",
      "DESENVOLVIMENTO/EVOLUÇÃO" = "DEVELOPMENT/EVOLUTION",
      "REGISTRO DE AGUARDANDO RETORNO" = "LOGGING OF WAITING FOR RETURN",
      "TAREFA CANCELADA" = "ISSUE CANCELED",
      "CONCLUSÃO DO CHAMADO" = "CONCLUSION OF THE ISSUE",
      "VALIDAÇÃO" = "VALIDATION",
      "TESTE REALIZADO" = "TEST DONE",
      "SOLICITAÇÃO DE TESTES" = "REQUEST FOR TESTING",
      "NOVA SUB-TAREFA" = "NEW SUBTASK"
    )
  ) %>%
  mutate(log_action = factor(log_action))

# Rename log_status values. Translate them from Portuguese to English.
# Cast log_status from character to unordered factor.
issues <-
  issues %>%
  mutate(
    log_status = recode(
      log_status,
      "FINALIZADA" = "FINISHED",
      "PENDENTE FECHAMENTO CLIENTE" = "CUSTOMER CLOSING PENDING",
      "SOLICITADO ATUALIZAÇÃO PRODUÇÃO" = "REQUESTED PRODUCTION UPDATE",
      "VALIDADA PELO CLIENTE" = "VALIDATED BY CUSTOMER",
      "EM DESENVOLVIMENTO" = "UNDER DEVELOPMENT",
      "ERRO DE VALIDAÇÃO" = "VALIDATION ERROR",
      "PENDENTE VALIDAÇÃO DO CLIENTE" = "CUSTOMER VALIDATION PENDING",
      "RETORNADA INFORMAÇÃO" = "RETURNED INFORMATION",
      "AGUARD. RETORNO" = "WAITING FOR RETURN",
      "AGUARDANDO RETORNO - CLIENTE" = "WAITING FOR RETURN - CUSTOMER",
      "CONCLUÍDO" = "COMPLETED",
      "AGUARDANDO RETORNO - SIG" = "WAITING FOR RETURN - COMPANY",
      "ABERTA" = "OPEN",
      "CANCELADA" = "CANCELED",
      "VALIDADA PARA PRODUÇÃO" = "VALIDATED FOR PRODUCTION",
      "EM PRÉ-PRODUÇÃO" = "IN PRE-PRODUCTION",
      "PENDENTE INICIAR" = "PENDING START",
      "ERRO DE TESTE" = "TEST ERROR",
      "PENDENTE ATUALIZAÇÃO EM HOMOLOGAÇÃO/TESTES" = "PENDING UPGRADE IN HOMOLOGATION/TESTS",
      "VALIDADA INTERNAMENTE" = "VALIDATED INTERNALLY",
      "PENDENTE DE DISTRIBUIÇÃO" = "DISTRIBUTION PENDING",
      "AGUARD. VALIDAÇÃO TÉCNICA INTERNA" = "WAITING FOR INTERNAL TECHNICAL VALIDATION",
      "EM HOMOLOGAÇÃO/TESTES" = "IN HOMOLOGATION/TESTS",
      "AUTORIZADO DESENVOLVIMENTO" = "AUTHORIZED DEVELOPMENT",
      "EM TESTE" = "IN TEST",
      "PENDENTE DE ANÁLISE TÉCNICA" = "TECHNICAL ANALYSIS PENDING",
      "RETORNADA POR FALTA DE INFORMAÇÃO" = "RETURNED FOR LACK OF INFORMATION",
      "VALIDADO POR TESTES" = "VALIDATED BY TEST",
      "SUSPENSA" = "SUSPENDED",
      "REABERTA" = "REOPENED",
      "AGUARD. APROVAÇÃO DO CLIENTE" = "WAITING FOR CUSTOMER APPROVAL",
      "TESTE SOLICITADO" = "TEST REQUESTED",
      "EM PRODUÇÃO" = "IN PRODUCTION",
      "INICIADA EXECUÇÃO" = "STARTED EXECUTION"
    )
  ) %>%
  mutate(log_status = factor(log_status))

# Cast issue_system and issue_subsystem from character to unordered factor.
issues <-
  issues %>%
  mutate(
    issue_system = factor(issue_system),
    issue_subsystem = factor(issue_subsystem)
  )

# To avoid Evaluation error: (converted from warning) unknown timezone
# 'zone/tz/2017c.1.0/zoneinfo/America/Sao_Paulo'.
Sys.setenv(TZ = "America/Sao_Paulo")

# Cast issue_creation_date variable from character to POSIXct (datetime)
issues <-
  issues %>%
  mutate(issue_creation_date = dmy_hms(issue_creation_date))

# Cast issue_start_date variable from character to Date
issues <-
  issues %>%
  mutate(issue_start_date = dmy(issue_start_date))

# Cast issue_deadline_date variable from character to Date
issues <-
  issues %>%
  mutate(issue_deadline_date = dmy(issue_deadline_date))

# Cast log_creation_date variable from character to POSIXct (datetime)
issues <-
  issues %>%
  mutate(log_creation_date = dmy_hm(log_creation_date))

# Cast issue_time_spent variable from character to integer (seconds)
issues <-
  issues %>%
  mutate(
    issue_time_spent = ifelse(
      str_detect(issue_time_spent, "h"),
      issue_time_spent %>%
        str_replace(",", ".") %>%
        str_replace("h", "") %>%
        as.double() * 3600,
      NA
    ) %>%
      as.integer()
  )


# Cast log_time_spent variable from character to Period
issues <-
  issues %>%
  mutate(log_time_spent = period_to_seconds(hms(
    ifelse(
      str_detect(log_time_spent, "min"),
      log_time_spent %>%
        paste("0s") %>%
        str_pad(8, pad = "0") %>%
        str_pad(9, pad = " ") %>%
        str_pad(10, pad = "h") %>%
        str_pad(11, pad = "0"),
      NA
    ),
    quiet = TRUE
  )) %>%
    as.integer())

# Remove '%' character from issue_progress and log_progress
# then cast them from character to integer.
issues <-
  issues %>%
  mutate(
    issue_progress = issue_progress %>%
      str_replace("%", "") %>%
      as.integer(),
    log_progress = log_progress %>%
      str_replace("%", "") %>%
      as.integer()
  )

# Remove 'Revisão:' word from log_svn_revision
# then cast it from character to integer.
issues <-
  issues %>%
  mutate(log_svn_revision = log_svn_revision %>%
           str_replace("Revisão:", "") %>%
           as.integer())

# Extract build version from log_build_info and override it.
issues <-
  issues %>%
  mutate(log_build_info = str_extract(log_build_info, "^S[_a-zA-Z0-9\\.-]+"))

# Write in CSV the issses data.frame after cleaning process.
write.csv(issues,
          "../issues_tracking.csv",
          na = "",
          row.names = FALSE)

