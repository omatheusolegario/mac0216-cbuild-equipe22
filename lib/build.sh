build_project() {
  #Confere se o gcc existe no sistema
  debug_msg "Conferindo se o gcc existe no sistema..."
  if command -v gcc >/dev/null 2>&1; then
    verbose_msg "GCC encontrado."
  else
    echo "Erro: GCC não encontrado. Por favor instale o GCC para continuar." >&2
    return 1
  fi

  #Confere se o make existe no sistema
  debug_msg "Conferindo se o make existe no sistema..."
  if command -v make >/dev/null 2>&1; then
    verbose_msg "Make encontrado."
  else
    echo "Erro: Make não encontrado. Por favor instale o Make para coninuar" >&2
    return 1
  fi

  debug_msg "Conferindo se existem arquivos fonte..."
  #Confere se existem arquivos fonte
  if [[ ${#SOURCE_FILES[@]} -eq 0 ]]; then
    echo "Erro: Não há arquivos fonte especificados" >&2
    return 1
  fi
  debug_msg "Existem arquivos fonte."

  #Array para armazenar os arquivos objeto
  local objetos=()

  #Verificação de mudança de flag de otimização
  local forcar_recompilacao=0

  debug_msg "Conferindo se o nível de otimização mudou..."

  if [[ ! -f "$BUILD_DIR/OPT_LEVEL.txt" || "$(<"$BUILD_DIR/OPT_LEVEL.txt")" != "$OPT_LEVEL" ]]; then
    verbose_msg "O nível de otimização mudou. Forçando recompilação de todos arquivos."
    forcar_recompilacao=1
    if ! rm -f "$BUILD_DIR/OPT_LEVEL.txt"; then
      echo "Erro: Falha ao tentar remover arquivo de nível de otimização antigo." >&2
      return 1
    fi
  else
    debug_msg "O nível de otimização não mudou."
  fi

  #Itera cada arquivo fonte, e verifica se é necessária uma compilação dele
  local arquivo_fonte

  debug_msg "Entrando na iteração de arquivos fonte..."
  for arquivo_fonte in "${SOURCE_FILES[@]}"; do

    debug_msg "Arquivo fonte atual: $arquivo_fonte"

    #Atribuição de nomes únicos ao objeto e dependência em build
    local caminho_relativo="${arquivo_fonte#"$PROJECT_DIR/"}"
    local nome_unico="${caminho_relativo%.c}"
    local caminho_obj="$BUILD_DIR/${nome_unico}.o"
    local caminho_dep="$BUILD_DIR/${nome_unico}.d"

    debug_msg "caminho_relativo: $caminho_relativo"
    debug_msg "nome_unico: $nome_unico"
    debug_msg "caminho_obj: $caminho_obj"
    debug_msg "caminho_dep: $caminho_dep"

    #Adiciona a lista de objetos o caminho do objeto do arquivo fonte atual
    objetos+=("$caminho_obj")
    debug_msg "objetos: ${objetos[*]}"

    debug_msg "Criando diretório do objeto em $caminho_obj..."
    #Cria o diretório onde o objeto vai ficar dentro de $BUILD_DIR, pois preservamos as "/" no nome único
    if ! mkdir -p "$(dirname "$caminho_obj")"; then
      echo "Erro: Não foi possível criar o diretório do objeto." >&2
      return 1
    fi
    debug_msg "Diretório do objeto criado."

    #Variável binária (0 ou 1), que decide se é necessário compilar, iniciada com o valor de forçar recompilação que também é binária (0 ou 1)
    local precisa_compilar="$forcar_recompilacao"
    debug_msg "precisa_compilar: $precisa_compilar"

    debug_msg "Checando se não existe o objeto ou a dependência..."
    #Checagem para ver se não existe ou o objeto ou a dependência
    if [[ ! -f "$caminho_obj" || ! -f "$caminho_dep" ]]; then
      precisa_compilar=1
      debug_msg "precisa_compilar: $precisa_compilar"
    else
      debug_msg "Existem ambos."
    fi

    debug_msg "Checando se ou o .c ou suas dependências foram atualizadas..."

    local arquivo_fonte_formatado_make="${arquivo_fonte// /\\ }"
    local caminho_obj_formatado_make="${caminho_obj// /\\ }"
    local caminho_dep_formatado_make="${caminho_dep// /\\ }"
    #Utiliza o próprio make para saber se ou o .c ou suas dependências foram atualizadas, e se sim precisa compilar.
    if [[ $precisa_compilar -eq 0 ]]; then
      #Justamente o controle de status (precisa atualizar ou não)
      local status_make=0

      #Chama o make dentro do bash, com -Rr para desativar regras e variáveis implícitas do make não desejadas,
      # -f seguido de - para dizer que o make vai ler o stdin, e o -q para o make apenas dizer se precisa ou não atualizar
      make -Rr -f - -q "$caminho_obj" <<EOF || status_make=$?
$caminho_obj_formatado_make: $arquivo_fonte_formatado_make ; @:
include $caminho_dep_formatado_make
EOF

      debug_msg "status_make: $status_make"
      case $status_make in
      0) precisa_compilar=0 ;;
      1) precisa_compilar=1 ;;
      *)
        echo "Erro: Não foi possível verificar as dependências com o make." >&2
        return 1
        ;;
      esac
    fi

    #Se precisa compilar, chama o gcc e compila o arquivo fonte atual
    if [[ $precisa_compilar -eq 1 ]]; then
      verbose_msg "Compilando $arquivo_fonte..."

      # -c para compilar até o arquivo de objeto, -I para especificar onde o compilador pode buscar por cabeçalhos,
      # -MMD para gerar um arquivo de dependências locais, -MP para o make não falhar com dependências antigas,
      # -O para o nível de otimização e -o para especificar o caminho do objeto gerado
      gcc -c -I "$PROJECT_DIR/include" -MMD -MP "$arquivo_fonte" -O"$OPT_LEVEL" -o "$caminho_obj"

      if [[ $? -ne 0 ]]; then
        echo "Erro: Não foi possível compilar o arquivo fonte" >&2
        return 1
      fi

    else
      verbose_msg "O arquivo objeto $caminho_obj está atualizado"
    fi
  done
  debug_msg "Finalizada a iteração de arquivos fonte."

  #Depois de conferir se cada arquivo fonte está atualizado, agora é feito o ligamento entre os objetos
  verbose_msg "Ligando arquivos objeto..."

  gcc "${objetos[@]}" -o "$EXECUTABLE"

  if [[ $? -ne 0 ]]; then
    echo "Erro: Não foi possível ligar os arquivos objeto" >&2
    return 1
  elif ! echo "$OPT_LEVEL" >"$BUILD_DIR/OPT_LEVEL.txt"; then
    echo "Erro: Não foi possível salvar o nível de otimização" >&2
    return 1
  else
    echo "Build concluída com sucesso."
    echo "O executável está disponível em: $EXECUTABLE"
    return 0
  fi
}
