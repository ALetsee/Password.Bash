
GREEN='\033[1;32m'
DARK_GREEN='\033[0;32m'
RED='\033[1;31m'
WHITE='\033[1;37m'
GRAY='\033[1;30m'
NC='\033[0m'

USERS_FILE="users.txt"

generate_password() {
    local length=12
    local characters="A-Za-z0-9@#\$%\&\*"
    local password=""

    while true; do
        password=$(< /dev/urandom tr -dc "$characters" | head -c $length)

        if [[ "$password" =~ [A-Z] && "$password" =~ [a-z] && "$password" =~ [0-9] && "$password" =~ [@#\$%\&\*] ]]; then
            break
        fi
    done

    echo "$password"
}

validate_password() {
    local password="$1"
    local length=${#password}

    if [ $length -lt 12 ]; then
        echo -e "${RED}
╔═══════════════════════════════════════════╗
║ Error: Mínimo 12 caracteres requeridos    ║
╚═══════════════════════════════════════════╝${NC}"
        return 1
    fi

    if ! [[ "$password" =~ [A-Z] ]]; then
        echo -e "${RED}
╔═══════════════════════════════════════════╗
║ Error: Requiere mayúsculas (A-Z)          ║
╚═══════════════════════════════════════════╝${NC}"
        return 1
    fi
    if ! [[ "$password" =~ [a-z] ]]; then
        echo -e "${RED}
╔═══════════════════════════════════════════╗
║ Error: Requiere minúsculas (a-z)          ║
╚═══════════════════════════════════════════╝${NC}"
        return 1
    fi
    if ! [[ "$password" =~ [0-9] ]]; then
        echo -e "${RED}
╔═══════════════════════════════════════════╗
║ Error: Requiere números (0-9)             ║
╚═══════════════════════════════════════════╝${NC}"
        return 1
    fi
    if ! [[ "$password" =~ [@#\$%\&\*!] ]]; then
        echo -e "${RED}
╔═══════════════════════════════════════════╗
║ Error: Requiere caracteres (@,#,$,%,&,*)  ║
╚═══════════════════════════════════════════╝${NC}"
        return 1
    fi

    return 0
}

register_user() {
    clear
    echo -e "${GREEN}
    ██████╗ ███████╗ ██████╗ ██╗███████╗████████╗██████╗  ██████╗ 
    ██╔══██╗██╔════╝██╔════╝ ██║██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗
    ██████╔╝█████╗  ██║  ███╗██║███████╗   ██║   ██████╔╝██║   ██║
    ██╔══██╗██╔══╝  ██║   ██║██║╚════██║   ██║   ██╔══██╗██║   ██║
    ██║  ██║███████╗╚██████╔╝██║███████║   ██║   ██║  ██║╚██████╔╝
    ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ${NC}"
    echo

    read -p "$(echo -e "${WHITE}[>] Ingrese nombre de usuario: ${NC}")" username

    echo -e "${GREEN}
╔═══════════════════════════════════════════╗
║ 1. Generar contraseña automáticamente     ║
║ 2. Ingresar contraseña manualmente        ║
╚═══════════════════════════════════════════╝${NC}"
    read -p "$(echo -e "${WHITE}[>] Seleccione una opción: ${NC}")" option

    case $option in
        1)
            password=$(generate_password)
            echo -e "${WHITE}[>] Contraseña generada: ${GREEN}$password${NC}"
            echo -e "${GREEN}[+] La contraseña contiene todas las reglas: Mayúsculas, minúsculas, números y caracteres especiales.${NC}"
            read -p "[>] Presione Enter para continuar..." </dev/tty
            ;;

        2)
    while true; do
        read -sp "$(echo -e "${WHITE}[>] Ingrese su contraseña: ${NC}")" password
        echo

        if validate_password "$password"; then

            echo -e "${WHITE}[>] Contraseña válida.${NC}"
            read -p "[>] Presione Enter para continuar..." </dev/tty
            break
        else

            echo -e "${RED}[!] Contraseña inválida. Intente nuevamente.${NC}"
        fi
    done
    ;;


        *)
            echo -e "${RED}[!] Opción inválida${NC}"
            return 1
            ;;
    esac

    echo "$username:$password" >> "$USERS_FILE"
    echo -e "${GREEN}
    ✓ Usuario registrado exitosamente
    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀${NC}"
}

login() {
    clear
    echo -e "${GREEN}
    ██╗      ██████╗  ██████╗ ██╗███╗   ██╗
    ██║     ██╔═══██╗██╔════╝ ██║████╗  ██║
    ██║     ██║   ██║██║  ███╗██║██╔██╗ ██║
    ██║     ██║   ██║██║   ██║██║██║╚██╗██║
    ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║
    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝${NC}"
    echo
    read -p "$(echo -e "${WHITE}[>] Usuario: ${NC}")" username
    read -sp "$(echo -e "${WHITE}[>] Contraseña: ${NC}")" password
    echo

    if grep -q "^$username:$password$" "$USERS_FILE" 2>/dev/null; then
        echo -e "${GREEN}
    ╔═══════════════════════════════════════════╗
    ║             ACCESO CONCEDIDO              ║
    ║         Bienvenido $username              ║
    ╚═══════════════════════════════════════════╝${NC}"

        read -p "[>] Presione Enter para continuar..." </dev/tty
        return 0
    else
        echo -e "${RED}
    ╔═══════════════════════════════════════════╗
    ║             ACCESO DENEGADO               ║
    ║     Usuario o contraseña incorrectos      ║
    ╚═══════════════════════════════════════════╝${NC}"

        read -p "[>] Presione Enter para continuar..." </dev/tty
        return 1
    fi
}


main() {
    touch "$USERS_FILE"

    while true; do
        clear
        echo -e "${GREEN}Sistema de Gestión de Usuarios${NC}"

        echo -e "${GREEN}
╔═══════════════════════════════════════════╗
║ 1. Registrar nuevo usuario                ║
║ 2. Iniciar sesión                         ║
║ 3. Salir del sistema                      ║
╚═══════════════════════════════════════════╝${NC}"
        read -p "$(echo -e "${WHITE}[>] Seleccione una opción: ${NC}")" choice

        case $choice in
            1)
                register_user
                ;;
            2)
                login
                ;;
            3)
                clear
                echo -e "${GREEN}
    ██████╗██╗   ██╗███████╗
    ██╔════╝╚██╗ ██╔╝██╔════╝
    ██║      ╚████╔╝ █████╗  
    ██║       ╚██╔╝  ██╔══╝  
    ╚██████╗   ██║   ███████╗
     ╚═════╝   ╚═╝   ╚══════╝${NC}"
                exit 0
                ;;
        
            *)
                echo -e "${RED}[!] Opción inválida${NC}"
                sleep 1
                ;;
        esac
    done
}

main