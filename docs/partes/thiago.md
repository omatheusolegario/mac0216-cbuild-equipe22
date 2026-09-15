# Thiago Assumpção Baisch

# Parte: execução, limpeza e reconstruçao

# Log
- Vou começar implementando 3 funçoes:
    -'run_project'
    -'clean_project'
    -'rebuild_project''

Fiz inicialmente o esqueleto delas no arquivo actions.sh.

## Parte 1 - função run_project
Criei a função run_project com a verificação de erros, se o executável
existe, se tem permissão de execuçao, se é um arquivo executável mesmo, e 
se o path para o arquivo está correto. 

Decidi fazer em ordem os ifs para cada verificação - se está com path correto,
se existe, se tem permissão e se é um executável. 
Depois fiz primeiro um if que executa o $EXECUTABLE e coloca status como 0 se funcionar e lança um erro se não funcionar
Depois fiz outro if para ver se o record_event funcionou. 

Tive um pouco de dificuldade com a sintaxe dos ifs, e também para entender como 
testar a execução usando um if. Mas consegui. 

Depois, fui para o arquivo de testes e criei as funçoes verbose_msg(), debug_msg()
e record_event() de forma "mock" para poder usar na função original e fazer 
testes dela. 
Fiz 5 testes, um para cada erro que eu "setei" na função original.

## Parte 1.5 (revisão)

Fiz algumas mudanças na ultima parte da função para ficar mais claro que 
pode ocorrer a execução do $EXECUTABLE mas falhar apenas o registro 
em record_event. 

## Parte 2 - função clean_project
Depois, comecei a implementar a função clean_project.

Pensei nela como uma função que primeiro precisa ter certeza de que está apagando o lugar certo e, só depois disso, pode realmente apagar os arquivos da compilação.

Comecei verificando se PROJECT_DIR e BUILD_DIR estavam definidos. Depois, coloquei algumas verificações para evitar que a função apague um diretório errado, como a raiz /, o próprio diretório do projeto ou alguma pasta que esteja fora dele.

Se a pasta build não existir, decidi que a função simplesmente retorna 0, porque isso significa que o projeto já está limpo. Assim, é possível usar clean várias vezes sem dar erro.

Se a pasta existir, uso: rm -rf -- "$BUILD_DIR" para apagar os arquivos da compilação.

Tive um pouco de dificuldade para entender como conferir se BUILD_DIR estava realmente dentro de PROJECT_DIR. Também fiquei com receio de usar rm -rf, porque eu sabia que esse comando poderia apagar coisas importantes se recebesse um caminho errado. Por isso, preferi fazer várias verificações antes de executar o comando.

## Parte 2.5 - revisão da função

Depois de revisar melhor a função, percebi alguns casos que eu não tinha pensado.

Eu tinha pensado em apagar somente os arquivos dentro de build usando:
rm -rf "$BUILD_DIR"/* , mas percebi que isso poderia deixar arquivos ocultos para trás. Então achei melhor apagar a própria pasta build, que depois poderá ser criada novamente quando o projeto for compilado.

Pensei no que aconteceria se BUILD_DIR apontasse para um arquivo em vez de uma pasta. Acrescentei uma verificação para esse caso, retornando um erro sem tentar apagar nada.

Percebi que também precisava tomar cuidado com a pasta de logs. Se, por algum erro, LOG_DIR estivesse dentro de BUILD_DIR, o clean poderia apagar o histórico do programa. Então coloquei mais uma verificação para impedir isso.

A maior dificuldade nessa parte foi pensar nos casos em que o caminho poderia estar errado. A lógica de apagar a pasta era simples, mas fazer isso de uma forma segura acabou exigindo mais verificações do que eu queria ter feito.
