#Leitura da configuração e descoberta do nome do executável.
read_executable_name() {
    local project_dir="$1"
    local config_file="$project_dir/.cbuild.conf"
    local executable_name="programa"
    local line
    local value
    local line_number=0
    local found=0

    #config_file não existe e não é link simbólico. Usa o nome padrão programa.
    if [[ ! -e "$config_file" && ! -L "$config_file" ]]; then
        echo "$executable_name"
        return 0
    fi

    #config_file não é válida ou não pode ser lida.
    if [[ ! -f "$config_file" || ! -r "$config_file" ]]; then
        echo "Erro: configuração inválida ou sem permissão de leitura." >&2
        return 1
    fi

    #Lê o arquivo linha por linha.
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_number=$((line_number +1))
        line="${line%$'\r'}"

        #Ignora linhas vazias e comentários.
        if [[ -z "$line" || "$line" == \#* ]]; then
            continue
        fi

        case "$line" in
            EXECUTABLE=*)
                #Verifica se há múltiplas configurações EXECUTABLE.
                if ((found == 1)); then
                    echo "Erro: EXECUTABLE foi definido mais de uma vez." >&2
                    return 1
                fi

                #Remove EXECUTABLE= da linha e guarda somente o valor.
                value="${line#EXECUTABLE=}"

                #Valida o nome do executável.
                #Primeiro caractere deve ser uma letra ou número.
                #Os caracteres subsequentes podem ser letras, números, ".", "_" ou "-".
                if [[ ! "$value" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
                    echo "Erro: nome de executável inválido na linha $line_number" >&2
                    return 1
                fi

                #Nome existe e é válido. Substitui o nome padrão. Marcamos que encontramos o EXECUTABLE.
                executable_name="$value"
                found=1
                ;;

            *)
                echo "Erro: configuração desconhecida na linha $line_number" >&2
                return 1
                ;;
        esac
    done < "$config_file"
    echo "$executable_name"
    return 0
}


#Preparação do projeto.
project_init() {
    local input_dir="$1"
    local executable_name
    local listing_file
    local file

    #Verifica se o diretório existe.
    if [[ ! -d "$input_dir" ]]; then
        echo "Erro: diretório inexistente: $input_dir" >&2
        return 1
    fi

    #Converte o diretório em caminho absoluto.
    if PROJECT_DIR="$(cd -- "$input_dir" && pwd -P)"; then
        :
    else
        echo "Erro: não foi possível acessar: $input_dir" >&2
        return 1
    fi

    #Impede que a raiz do sistema seja usada.
    if [[ "$PROJECT_DIR" == "/" ]]; then
        echo "Erro: escolha uma pasta de projeto, não a raiz do sistema." >&2
        return 1
    fi

    #Define onde ficam os artefatos.
    BUILD_DIR="$PROJECT_DIR/build"
    LOG_DIR="$PROJECT_DIR/logs"

    #Verifica se build/ ou logs/ já existem e são links simbólicos.
    if [[ -L "$BUILD_DIR" || -L "$LOG_DIR" ]]; then
        echo "Erro: build/ e logs/ não podem ser links simbólicos." >&2
        return 1
    fi

    #Define o caminho completo do executável.
    if executable_name="$(read_executable_name "$PROJECT_DIR")"; then
        EXECUTABLE="$BUILD_DIR/$executable_name"
    else
        return 1
    fi

    #Criação de build/ e logs/.
    if ! mkdir -p -- "$BUILD_DIR" "$LOG_DIR"; then
        echo "Erro: não foi possível preparar build/ e logs/." >&2
        return 1
    fi

    #Inicializa os arrays que irão armazenar os arquivos encontrados.
    #SOURCE_FILES para arquivos .c
    #HEADER_FILES para arquivos .h
    SOURCE_FILES=()
    HEADER_FILES=()

    #Cria um arquivo temporário dentro de logs/
    if listing_file="$(mktemp "$LOG_DIR/discovery.XXXXXX")"; then
        :
    else
        echo "Erro: não foi possível criar o arquivo de descoberta." >&2
        return 1
    fi

    #Procura arquivos .c e .h dentro do projeto. A saída é redirecionada para o arquivo temporário.
    if ! find "$PROJECT_DIR" \( -path "$BUILD_DIR" -o -path "$LOG_DIR" \) -prune -o -type f \( -name '*.c' -o -name '*.h' \) -print0 > "$listing_file"; then
        echo "Erro: não foi possível concluir a busca de arquivos." >&2
        rm -f -- "$listing_file"
        return 1
    fi

    while IFS= read -r -d '' file;do
        #Verifica a extensão dos arquivos encontrados. Adiciona os arquivos .c e .h em seus respectivos arrays.
        case "$file" in
            *.c)
                SOURCE_FILES+=("$file")
                ;;
            *.h)
                HEADER_FILES+=("$file")
                ;;
        esac
    done < "$listing_file"

    if ! rm -f -- "$listing_file"; then
        echo "Erro: não foi possível remover o arquivo temporário." >&2
        return 1
    fi

    return 0
}
