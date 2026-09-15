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
