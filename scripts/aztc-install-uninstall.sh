#!/usr/bin/env bash
# filepath: /Users/andersongksilva/Personal/scripts/aztc-install-uninstall.sh
# aztc-install-uninstall.sh
# Uso:
#   sudo ./aztc-install-uninstall.sh install /path/to/AZTClient-<version>-macos.pkg [--silent]
#   sudo ./aztc-install-uninstall.sh uninstall

set -euo pipefail

ACTION="${1:-}"
PKG_PATH="${2:-}"
SILENT=false

# Parâmetros predefinidos
export IDP="conectati.minhati.com.br"
export AUTO_START="no"
export MINIMIZED="yes"
export AZTC_LANG="Brasil"
export ALLOW_DOWNGRADE="yes"

# Verifica se --silent foi passado
for arg in "$@"; do
  if [[ "$arg" == "--silent" ]]; then
    SILENT=true
    break
  fi
done

confirm() {
  read -r -p "$1 [y/N]: " resp
  case "$resp" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) return 1 ;;
  esac
}

install_flow() {
  if [[ -z "$PKG_PATH" ]]; then
    echo "Erro: informe o .pkg (ex: /path/AZTClient-<version>-macos.pkg)"
    exit 2
  fi
  if [[ ! -f "$PKG_PATH" ]]; then
    echo "Arquivo .pkg não encontrado: $PKG_PATH"
    exit 2
  fi

  if $SILENT; then
    echo "Executando instalação silenciosa com os parâmetros predefinidos:"
    echo "  IDP=${IDP}, AUTO_START=${AUTO_START}, MINIMIZED=${MINIMIZED}, AZTC_LANG=${AZTC_LANG}, ALLOW_DOWNGRADE=${ALLOW_DOWNGRADE}"
    
    # Adicionado -allowUntrusted conforme documentação oficial
    sudo env IDP="${IDP}" AUTO_START="${AUTO_START}" MINIMIZED="${MINIMIZED}" AZTC_LANG="${AZTC_LANG}" ALLOW_DOWNGRADE="${ALLOW_DOWNGRADE}" installer -pkg "${PKG_PATH}" -target / -allowUntrusted
    echo "Instalação silenciosa executada. Verifique System Settings → Privacy & Security para aprovações pendentes."
  else
    echo "Instalação interativa: abrindo o .pkg para instalação manual."
    open "${PKG_PATH}"
    echo "Siga a interface gráfica para concluir."
  fi
}

uninstall_flow() {
  echo "Rotina de desinstalação do AZT Client."
  
  # Primeiro tenta usar o uninstaller oficial
  OFFICIAL_UNINSTALLER="/Applications/Akamai Zero Trust Client.app/Contents/Resources/uninstall.sh"
  ß
  if [[ -f "$OFFICIAL_UNINSTALLER" ]]; then
    echo "Usando uninstaller oficial da Akamai..."
    if confirm "Executar uninstaller oficial?"; then
      sudo "$OFFICIAL_UNINSTALLER"
      echo "Desinstalação oficial concluída."
      return 0
    fi
  else
    echo "Uninstaller oficial não encontrado. Usando método manual..."
  fi
  
  if ! confirm "Continuar com desinstalação manual?"; then
    echo "Abortando."
    exit 0
  fi

  # Mata processo AZTClient (se existir)
  if pgrep -x "AZTClient" >/dev/null 2>&1; then
    echo "Finalizando processo AZTClient..."
    sudo kill -9 $(pgrep AZTClient) || true
  else
    echo "Processo AZTClient não encontrado."
  fi

  # Remove aplicativo
  APP_PATH="/Applications/Akamai Zero Trust Client.app"
  if [[ -e "$APP_PATH" ]]; then
    echo "Removendo $APP_PATH..."
    if confirm "Mover $APP_PATH para a lixeira?"; then
      /bin/mv "$APP_PATH" "$HOME/.Trash/" || sudo rm -rf "$APP_PATH"
    else
      echo "Pulando remoção do app."
    fi
  else
    echo "Aplicativo não encontrado em $APP_PATH"
  fi

  # Remove receipts do sistema
  mapfile -t PKGS < <(pkgutil --pkgs | grep -i "azt\|akamai" || true)
  if [[ ${#PKGS[@]} -gt 0 ]]; then
    echo "Pacotes encontrados:"
    printf '%s\n' "${PKGS[@]}"
    if confirm "Deseja remover os registros dos pacotes acima?"; then
      for p in "${PKGS[@]}"; do
        echo "Removendo registro: $p"
        sudo pkgutil --forget "$p" || true
      done
    fi
  fi

  echo "Desinstalação concluída."
}

case "$ACTION" in
  install)
    install_flow
    ;;
  uninstall)
    uninstall_flow
    ;;
  *)
    cat <<EOF
Uso:
  sudo $0 install /path/to/AZTClient-<version>-macos.pkg [--silent]
  sudo $0 uninstall

Parâmetros aplicados automaticamente na instalação silenciosa:
  IDP=${IDP}
  AUTO_START=${AUTO_START}
  MINIMIZED=${MINIMIZED}
  AZTC_LANG=${AZTC_LANG}
  ALLOW_DOWNGRADE=${ALLOW_DOWNGRADE}

Observações:
 - Após instalação verifique System Settings → Privacy & Security para aprovações
 - Se gerenciado por MDM, a remoção pode ser bloqueada ou revertida
EOF
    ;;
esac
