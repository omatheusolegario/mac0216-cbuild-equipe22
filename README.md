# O que é o cbuild
O cbuild é uma ferramenta de construção de executável de projetos desenvolvidos em C, capaz de verificar dependências, compilar, limpar compilação, recompilar, ligar objetos e rodar o executável, em modo normal, verboso e debug.
# Pré-requisitos
- Linux/ Unix-like SO
- Bash/Zsh
- GCC
- GNU Make

# Como executar
Para executar, da pasta da ferramenta:
```bash
chmod +x cbuild
./cbuild build --dir /caminho/do/projeto
```

Ou sem depender da permissão para execução de scripts:
```bash
bash cbuild build --dir /caminho/do/projeto
```
Por padrão a ferramenta considera o diretório corrente como diretório do projeto.

# Comandos
- build: gera o executável do seu projeto
- run: roda o executável do seu projeto
- clean: limpa a pasta build/ e preserva os logs
- rebuild: limpa a pasta build/ e gera o executável do seu projeto
- info: mostra informações do projeto e da execução da ferramenta

# Opções 
- --dir \[caminho/do/projeto]: escolhe o diretório do projeto
- --verbose: roda a ferramenta informando suas etapas
- --debug: mostra mensagens de debug, como estado de variáveis, loop atual, etc.
- --report: gera um relatório report.txt com informações de execução internas
- --O \[0 | 1 | 2 | 3]: escolhe o nível de otimização na compilação dos arquivos

# Configuração
O .cbuild.conf deve ser criado no diretório do projeto informado ou no diretório corrente e aceita a variável EXECUTABLE, que define o nome do executável do projeto.

```bash
EXECUTABLE="programa"
```


# Exemplos de uso

```bash
./cbuild build --dir tests/mgolegario
./cbuild run --dir tests/mgolegario
./cbuild rebuild --dir tests/mgolegario -- O 2 --verbose
./cbuild clean --dir tests/mgolegario --report
```

# Arquivos gerados
- Os arquivos objeto, dependências e o executável em caminho/do/projeto/build/
- Os logs e o report.txt em caminho/do/projeto/logs

# Testes e limitações
Existe um projeto teste disponível em tests/projeto_teste01. Para executá-lo:

```bash
./cbuild build --dir tests/projeto_teste01
./cbuild run --dir tests/projeto_teste01
```

Não é recomendado o uso de caracteres como "$" ou "#" nos nomes de arquivos e diretórios do projeto, pois eles quebram os scripts da ferramenta, escritos em bash.
