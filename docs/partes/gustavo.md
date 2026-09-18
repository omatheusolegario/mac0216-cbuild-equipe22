# Gustavo Yukio Yamani

# Parte: integração, preparação do projeto e gerenciamento do fluxo do cbuild

## Parte 1 - cbuild: usage e parse_args
Criei usage para conseguir mandar a mensagem de uso do programa.

Em seguida, implementei a função parse_args, responsável por interpretar os argumentos fornecidos pelo usuário. Essa interpretação consiste em identificar o comando solicitado e processar as opções disponíveis, além de armazenar as informações recebidas e realizar validações.
As informações recebidas são armazenadas em variáveis utilizadas pelo restante do programa, como COMMAND, VERBOSE ou DEBUG.
A validação impede a continuação da execução quando os argumentos são inválidos (comando/opção inexistente, ausência de um comando, utilização de mais de um comando, etc.).
Quando há mais de um --dir (com diretório válido) o último valor prevalece.

As informações obtidas ficam disponíveis para as funções executadas posteriormente.

## Parte 1.5 - TESTE: usage e parse_args
Adicionei um trecho temporário em cbuild para exibir os valores obtidos por parse_args. Também foi útil para verificar a formatação de usage.

Os seguintes testes foram realizados:

Casos válidos:
bash cbuild build
bash cbuild run --verbose
bash cbuild info --debug --report
bash cbuild build --dir "/tmp/projeto teste"

Casos inválidos:
bash cbuild
bash cbuild errado
bash cbuild build run
bash cbuild build --dir
bash cbuild build --errado

## Parte 2 - project.sh: read_executable_name
Criei lib/project.sh
Implementei em project.sh a função read\_executable\_name, responsável por obter o nome do executável a partir de .cbuild.conf.

Caso não exista uma configuração válida para o nome do executável, é utilizado o nome padrão "programa".

Utilizando IFS= read -r, realiza-se a leitura linha por linha, preservando espaços e barras invertidas.
Ao achar o nome do executável, verifica-se se ele é válido. Para ser válido, deve começar com uma letra ou número e pode ser seguido por letras, números, ".", "-" ou "_".
Se não for válido dá erro. Se achar mais de um nome também dá erro.

A saída padrão retorna o nome do executável.

## Parte 3 - project.sh: project_init
Implementei em project.sh a função project_init, responsável pela preparação inicial do projeto.

Antes de tudo, o diretório informado pelo usuário (caso seja válido) é convertido para um caminho absoluto. Isso evita que etapas posteriores dependam do diretório a partir do qual cbuild foi executado.

Defini as informações utilizadas pelos demais módulos: PROJECT\_DIR, BUILD\_DIR, LOG\_DIR, EXECUTABLE, SOURCE\_FILES, HEADER_FILES.
O nome do executável é obtido por meio de read\_executable\_name e os diretórios necessários são criados

Também é realizada a descoberta dos arquivos-fonte e dos arquivos de cabeçalho utilizando o comando find.
É utilizado um arquivo temporário criado com mktemp para verificar se find foi executado corretamente. Dessa forma, uma falha durante a busca não é confundida com uma busca que não encontrou arquivos.
A opção -print0 foi utilizada para tratar corretamente nomes de arquivos que contenham espaços ou quebras de linha.

Os caminhos encontrados são armazenados em arrays, permitindo que cada caminho seja tratado individualmente.

A implementação do find foi a parte mais problemática e complexa de project_init. Tanto pelo seu funcionamento, quanto sintaxe.

## Parte 3.5 - TESTE: project_init
Para testar project\_init, foi criado tests/gustavo/teste\_project.sh

O teste foi desenvolvido para verificar a preparação do projeto e a descoberta dos arquivos sem envolver a compilação. Por conta disso, ele utiliza arquivos C vazios.
Falhou duas vezes devido ao find, que tive que consertar.

## Parte 4 - cbuild: load_modules
Implementei em cbuild a função load_modules, responsável por carregar os módulos utilizados.

Os módulos são carregados utilizando source.
Assim, suas funções são disponibilizadas no mesmo processo e as variáveis definidas durante a preparação do projeto permaneçem disponíveis para os módulos.

## Parte 5 - cbuild: dispatch_command
Implementei a função dispatch_command, responsável por encaminhar o comando recebido para a função correta.

A função identifica a operação solicitada e chama a função responsável no módulo correspondente.

## Parte 6 - cbuild: main
Implementei a função main, responsável por organizar o fluxo principal de execução do cbuild.

A função implementa o seguinte fluxo:
- 1. Interpretar os argumentos com parse_args
- 2. Carregar os módulos com load_modules
- 3. Preparar o projeto com project_init
- 4. Iniciar o registro da operação
- 5. Executar o comando com dispatch_command
- 6. Armazenar o código de retorno
- 7. Finalizar o registro
- 8. Gerar o relatório caso solicitado
- 9. Retornar o resultado da operação

O código de retorno é armazenado antes das etapas de finalização para evitar sua perda ou substituição.
O relatório é gerado após a finalização do log para que ele tenha acesso ao registro completo da operação.
