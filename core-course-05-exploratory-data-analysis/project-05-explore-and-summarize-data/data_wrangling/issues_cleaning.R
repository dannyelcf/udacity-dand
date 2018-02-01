
library(dplyr)

issues <- read.csv("issues_exported.csv")

# There are 65 issues type
unique(issues$tipo_tarefa)

issues <- issues %>%
  mutate(tipo_tarefa = recode(tipo_tarefa,
    "CUSTOMIZACAO DE FUNCIONALIDADE EXISTENTE" = "CUSTOMIZATION",
    "SUSTENTAÇÃO / ERRO EM PRODUÇÃO" = "MAINTENANCE",
    "SUSTENTAÇÃO / AMBIENTE FORA DO AR" = "MAINTENANCE",
    "MIGRAÇÃO DE DADOS" = "DATA MIGRATION",
    "SUSTENTAÇÃO / ERRO EM CUSTOMIZAÇÃO REALIZADA" = "MAINTENANCE",
    "SUSTENTAÇÃO" = "MAINTENANCE",
    "SUSTENTAÇÃO / ALTERAÇÕES DIRETAMENTE NO BANCO DE DADOS" = "MAINTENANCE",
    
    "MANUTENÇÃO COSMÉTICA" = "MAINTENANCE",
    "COLETA INFORMAÇÕES" = "OTHERS",
    "ORDEM DE SERVIÇO / CUSTOMIZAÇÃO" = "OTHERS",
    "TAREFA DE ROTINA / OUTRAS DEMANDAS" = "OTHERS"
    ))

unique(issues$tipo_tarefa)

