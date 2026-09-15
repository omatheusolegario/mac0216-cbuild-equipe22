# Thiago Assumpção Baisch

# Parte: execução, limpeza e reconstruçao

# Log
- Vou começar implementando 3 funçoes:
    -'run_project'
    -'clean_project'
    -'rebuild_project''

Fiz inicialmente o esqueleto delas no arquivo actions.sh.

## Commit 1 
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

## Commit 1.5

Fiz algumas mudanças na ultima parte da função para ficar mais claro que 
pode ocorrer a execução do $EXECUTABLE mas falhar apenas o registro 
em record_event. 