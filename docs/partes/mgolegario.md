# Matheus Guimarães Olegario

# Minha responsabilidade
Fiquei responsável pela implementação do comando build do nosso cbuild, tendo que lidar com compilação, ligação de objetos e compilação incremental, de acordo com as especificações da tarefa.

# Funcionamento de build_project
1. Recebe os caminhos, fontes e níveis de otimização (da parte do Gustavo)
2. Verifica se existe o GCC, o Make e os arquivos fonte
3. Confere se a otimização mudou
4. Para cada fonte, determina os caminhos .d e .o únicos para cada arquivo
5. Se faltam alguns desses arquivos (.d ou .o), recompila; se não consulta o make dentro do bash
6. Compila os arquivos necessários e liga os objetos relativos às fonte atuais
7. Salva a otimização após sucesso e retorna falha se alguma das etapas der erro

# Primeira abordagem e dificuldades
A grande dificuldade da implementação foi achar um jeito de conseguir fazer a compilação incremental funcionar. A primeira ideia que veio foi comparar as datas dos arquivos .c e .o, e procurar dependências com grep dentro dos arquivos .c. Abordagem que logo de cara falhava para dependências de dependências, além de não conseguir interpretar corretamente nomes com espaços e outros caracteres, que não eram tratados corretamente nas minhas tentativas de grep junto de qualquer tratamento de texto: sed, awk, etc. por terem que tratar de muitos casos diferentes e específicos.

# Decisão de usar GCC e Make
Então comecei a andar no caminho certo ao adotar a filosofia de delegar tarefas para quem sabe fazer elas, e não tentar recriar um gcc ou make completamente, até porque o bash trata strings e nomes de maneira diferente deles. Então a primeira decisão foi utilizar as flags -MMD -MP na compilação para obter as dependências de um .c, e então quando fosse precisar compilar novamente, já saberia onde encontrar todas dependências para cada arquivo. A segunda decisão, e aqui foi o grande ápice, foi usar o GNU Make no modo mínimo e de apenas resposta para apenas checar se as dependências (armazenadas por conta da compilação gcc) haviam sido modificadas desde a data da última compilação (data do .o, arquivo também armazenado) daquele arquivo. Assim ficaram resolvidas as questões tanto de dependências encadeadas, quanto de nomes (dentro dos casos suportados e testados pela ferramenta).

# Decisões específicas da implementação
- Foram preservados os caminhos inteiros desde o diretório informado pelo usuário ou desde o diretório onde roda o cbuild, para garantir a unicidade dos nomes dos arquivos em build. Isso quer dizer que dentro do diretório build, você encontra uma estrutura similar a do seu projeto, se ele tem arquivos em src, os objetos desses arquivos estarão em build/src.
- Para garantir que o executável gerado tivesse apenas os objetos necessários e atualizados, os arquivos que passam pelo build vindos de SOURCE_FILES têm o caminho de seus .o respectivos armazenados em um array, assim na hora de ligar todos objetos, os objetos que são passados são exatamente apenas os correspondentes dos arquivos vindos de SOURCE_FILES, prevenindo de arquivos velhos/descartados de entrarem no executável.
- Existe uma checagem antes de entrar no loop principal (cada arquivo de SOURCE_FILES) para saber se o nível de otimização mudou, e garantir que todos arquivos serão recompilados quando isso for verdade. Para isso no final de toda build bem sucedida é guardado o nível de otimização da última compilação em OPT_LEVEL.txt. É importante ressaltar também que se o nível mudou, o arquivo antigo é apagado, para que sejam evitados reaproveitamentos indevidos de um nível de otimização não condizente ao pedido.
- Quando estão faltando ou o .o ou o .d relativo daquele arquivo .c, o programa já marca que precisa compilar aquele arquivo, pois isso quer dizer que ele não passou pelo gcc ainda, ou que seus respectivos arquivos foram apagados, o que impede a geração de um executável ou verificação devida das dependências.

# Dificuldades na integração
Também fui responsável por juntar as partes de cada um em suas branches na main, corrigir erros e verificar o que estava pendente. O principal vilão dessa parte com certeza foi a lógica de conseguir capturar todos erros de cada execução do cbuild produzidos pelos nossos scripts, e ao mesmo tempo que gravava esses erros em um arquivo temporário para aparecer nos logs, mandar para stderr para aparecer no terminal. Entender como o tee era a solução para isso e pesquisar como tratar ele, pois executa em background e pode haver problemas de sincronismo, também foi desafiador. Evitar loops de erro com ele e que diferentes execuções de cbuild usassem o mesmo arquivo temporário também foram complicadas soluções, que envolveram criação de novo canal, usar o mktemp corretamente e excluir o temporário no momento correto com o trap.

# Testes e resultados
 Para o build, construí uma estrutura similar a descrita nas instruções da tarefa, e estressei a questão do nome, nível de otimização e caminhos parecidos, para mitigar qualquer caso de borda e entender limitações do script. Graças a decisão de usar o make para informar se aquele arquivo precisava ser atualizado, grande parte desses problemas e limitações foram mitigadas, e em todos esses testes descritos o código passou. Os arquivos de teste utilizados estão disponíveis em tests/mgolegario no github do projeto. Mas em resumo os testes executados e que passaram foram:
- Primeira compilação e execução do executável.
- Repetição sem alterações
- Alteração de uma fonte 
- Alteração de um cabeçalho
- Remoção de um .d 
- Mudança de otimização
- Falha no meio da recompilação e recuperação 
- Renomeação de fonte e ligação apenas dos objetos das fontes atuais
- Nomes e caminhos com espaços

# Aprendizados e melhorias futuras
Com certeza fazer a interligação da parte de cada um rendeu um conhecimento riquíssimo, pois percebi a real importância de se utilizar aspas em volta de variáveis, como tratar e direcionar erros e o que isso realmente significa no contexto do shell, além de procurar soluções mais eficientes para comandos de busca, como substituir grep com wc por awk, utilizar o trap ao invés de tentar achar o momento de algo acontecer na main(). Da parte de build em específico ficou o conhecimento do make, aprendizado de novas flags do gcc e o que um caminho de um arquivo representa para o sistema, pois tive que mexer muito com isso. Melhorias ficariam principalmente para o tratamento de casos mais específicos, como uso de $ e # nos caminhos e nomes, para garantir o funcionamento ideal para qualquer projeto, e chegar mais perto do que um Makefile consegue fazer em poucas linhas.
