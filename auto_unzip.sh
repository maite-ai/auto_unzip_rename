#!/bin/bash

# Estilos
BOLD='\e[1m'
UNDERLINE='\e[4m'

# Colores semáforo para mensajes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'

# Otros colores
BLUE='\033[0;34m'
NOCOLOR='\033[0m' # para resetear color

# Funciones para imprimir con colorcito ;)
log_info() {
  echo -e "${BLUE}[INFO]${NOCOLOR} $1"
}

log_error() {
  echo -e "${RED}[ERROR] $1${NOCOLOR}"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NOCOLOR} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS] $1${NOCOLOR}"
}

# Crea una lista con los distintos challenges de la unidad
folder_name=$(basename "$(pwd)")
echo -e "${UNDERLINE}Obteniendo lista de challenges de la unidad ${folder_name}${NOCOLOR}"
challenges=(*)

# Itero sobre la lista
for challenge in "${challenges[@]}"; do
  if [ -d "$challenge" ]; then # verifica que sea un directorio
    cd $challenge
    log_info "Ingresando al challenge ${BOLD}${challenge}${NOCOLOR}"

    if ls | grep -q ".zip"; then
      zip_files=$(find . -maxdepth 1 -type f -name '*.zip')

      for zip_file in $zip_files; do
        log_info "Encontrado archivo: ${BOLD}${zip_file}${NOCOLOR}"

        unzip_output=$(unzip -l "$zip_file")
        echo "$unzip_output"

        read -p "¿Deseas descomprimir este archivo? (s/n): " extract_choice

        if [[ "$extract_choice" == "s" ]]; then
          # creo carpeta temporal donde va a estar almacenado el ipynb
          temp_dir=$(mktemp -d)
          log_info "Creando directorio temporal: ${temp_dir}"
          unzip -q "$zip_file" -d "$temp_dir"

          solution_ipynb=$(find "$temp_dir" -type f -name "*.ipynb" | head -1)
          if [[ -z "$solution_ipynb" ]]; then
            log_warning "No se encontró archivo ipynb de solución en el zip"
            rm -rf "$temp_dir"
            continue
          fi

          solution_ipynb_name=$(basename "$solution_ipynb")
          log_info "Archivo ipynb de solución encontrado: ${solution_ipynb_name}"

          cp "$solution_ipynb" "./sol_$solution_ipynb_name"

          # borrar el directorio temporal
          rm -rf "$temp_dir"
          rm "$zip_file"
          log_success "Archivo .zip eliminado"
        else
          log_info "Archivo no procesado"
        fi
      done
    else
      log_info "No hay archivos comprimidos en este directorio"
    fi
  cd ..
  echo ""
  fi
done

echo -e "${BOLD}===== Proceso completado ====="
