# Matheus Moreira Cabral

# Parte: logs, estatísticas e relatórios
As funções abaixo estão no arquivo observability.sh.

## Parte 1 - função show_info
Começei fazendo a função show_info, que será chamada com o comando info do cbuild. Ela vai exibir estatísticas do projeto, cujo formato é o segunte:

Número de arquivos: \<número>  
Número de linhas: \<número>  
Tamanho do executável: \<tamanho> bytes  
Data da última compilação: \<data horário>  
Data da última execução: \<data horario> 

A contagem de linhas foi feita com o comando wc -l. Assim, o critério para a contagem de linhas é a presença de \n no final da linha. Linhas vazias, comentários e diretivas de pré-processamento contam para a contagem de linhas. Mas linhas sem o \n no final não contam.

Quando uma informação não está disponível, é exibido que a informação está indisponível e a função retorna normalmente, sem erros.

Inicialmente o plano era fazer outra função (record_event) que seria chamada depois de toda compilação e execução, para guardar a data e o horário da última compilação e execução, mas decidi percorrer o log (que está descrito na Parte 2) para obter essas informações. Assim, a função record_event não existe mais.

## Parte 2 - funções log_begin e log_end
A função log_begin é chamada antes, e a log_end depois, do comando a ser executado pelo cbuild. A log_begin recebe como argumento o comando que será executado, e deixa-o salvo, para o log_end usar depois. Ela também usa o comando date para deixar salvo o horário de execução.

A função log_end adiciona uma linha no arquivo logs/operations.log. Ela retorna erro se não consegue criar o diretório logs/. Essa função recebe como argumento o código de retorno do comando executado pelo cbuild. Ela utiliza as informações salvas pelo log_begin para saber o comando executado pelo cbuild e calcula o tempo de execução, usando o comando date. Além disso, lê o arquivo temporário que guarda as mensagens de erro.

O formato de uma linha do log é:

\<data horário> - Comando: \<comando> - Status: \<Sucesso ou Falha> - Tempo de execução: \<tempo em segundos, com três casas decimais> - Código de retorno: \<0 ou 1> - Erros: \<erros, se houveram>

## Parte 3 - função generate_report
A função generate_report deverá ser chamada quando o cbuild for chamado com a opção --report. Ela cria um arquivo logs/report.txt, com informações sobre as operações executadas pelo cbuild. Mas retorna erro se não consegue localizar os logs. Essa função obtém suas informações dos logs, que foram descritos na Parte 2.

O formato do relatório é:

Relatório das operações

Total de operações: \<número>  
Operações bem sucedidas: \<número>  
Operações fracassadas: \<número>

Compilações: \<número>  
Execuções: \<número>

## Parte 4 - funções verbose_msg e debug_msg
Essas são as funções mais simples. Elas são chamadas por outros arquivos quando uma mensagem do modo verbose ou debug pode ser exibida, e recebem essa mensagem como argumento. Elas simplesmente exibem a mensagem se o modo verbose ou debug estão ativos, esses modos são ativados quando o cbuild é chamado com a opção --verbose e --debug, respectivamente.