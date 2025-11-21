#!/bin/zsh

echo "🚀 Iniciando setup do ambiente de desenvolvimento no macOS..."

# --- Homebrew ---
if ! command -v brew &> /dev/null; then
  echo "📦 Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew já instalado!"
fi

echo "🔄 Atualizando Homebrew..."
brew update

# --- Ferramentas essenciais ---
echo "📦 Verificando e instalando pacotes essenciais..."

packages=(git wget curl zsh zsh-completions)
for package in "${packages[@]}"; do
  if ! brew list --formula | grep -q "^${package}\$"; then
    echo "📦 Instalando $package..."
    brew install $package
  else
    echo "✅ $package já instalado!"
  fi
done

# --- AWS CLI ---
echo "📦 Verificando e instalando AWS CLI..."
if ! command -v aws &> /dev/null; then
  echo "📦 Instalando aws-cli..."
  brew install awscli
else
  echo "✅ aws-cli já instalado!"
fi

# --- GitHub CLI ---
echo "📦 Verificando e instalando GitHub CLI..."
if ! command -v gh &> /dev/null; then
  echo "📦 Instalando gh..."
  brew install gh
else
  echo "✅ gh já instalado!"
fi

# --- Linguagens e gerenciadores ---
echo "📦 Verificando linguagens e gerenciadores de versão..."

# NVM
if [ ! -d "$HOME/.nvm" ]; then
  echo "📦 Instalando Node Version Manager (nvm)..."
  if ! brew list --formula | grep -q "^nvm\$"; then
    brew install nvm
  fi
  mkdir -p ~/.nvm
  if ! grep -q "NVM_DIR" ~/.zshrc; then
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
    echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"' >> ~/.zshrc
  fi
else
  echo "✅ NVM já instalado!"
fi

# SDKMAN
if ! brew list --formula | grep -q "^sdkman-cli\$"; then
  echo "📦 Instalando SDKMAN..."
  if ! brew tap | grep -q "sdkman/tap"; then
    brew tap sdkman/tap
  fi
  brew install sdkman-cli
else
  echo "✅ SDKMAN já instalado!"
fi

# PYENV
if ! brew list --formula | grep -q "^pyenv\$"; then
  echo "📦 Instalando pyenv..."
  brew install pyenv
fi
if [ ! -d "$HOME/.pyenv" ]; then
  mkdir -p ~/.pyenv
  if ! grep -q "PYENV_ROOT" ~/.zshrc; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
  fi
else
  echo "✅ pyenv já instalado!"
fi

# --- Docker / Colima ---
echo "🐳 Verificando e instalando Colima + Docker..."

docker_packages=(colima docker docker-compose)
for package in "${docker_packages[@]}"; do
  if ! brew list --formula | grep -q "^${package}\$"; then
    echo "📦 Instalando $package..."
    brew install $package
  else
    echo "✅ $package já instalado!"
  fi
done

# Inicializa Colima se ainda não estiver rodando
if ! colima status &>/dev/null; then
  echo "⚙️ Iniciando Colima (Apple Silicon otimizado)..."
  colima start --arch aarch64 --cpu 4 --memory 8 --disk 60
else
  echo "✅ Colima já está em execução!"
fi

echo "✅ Colima + Docker prontos! Teste com: docker ps"

# --- Aplicações ---
echo "📦 Verificando e instalando aplicações de desenvolvimento..."

# DBeaver
if ! command -v dbeaver &> /dev/null && [ ! -d "/Applications/DBeaver.app" ]; then
  echo "📦 Instalando DBeaver..."
  brew install --cask dbeaver-community
else
  echo "✅ DBeaver já instalado!"
fi

# Postman
if ! command -v postman &> /dev/null && [ ! -d "/Applications/Postman.app" ]; then
  echo "📦 Instalando Postman..."
  brew install --cask postman
else
  echo "✅ Postman já instalado!"
fi

# --- Zsh + Plugins + Tema ---
echo "📦 Configurando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh já instalado!"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

echo "📦 Verificando e instalando plugins do Zsh..."

# FZF
if ! command -v fzf &> /dev/null; then
  echo "📦 Instalando fzf..."
  brew install fzf
  $(brew --prefix)/opt/fzf/install --all
else
  echo "✅ fzf já instalado!"
fi

# Plugins do Zsh
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "📦 Instalando zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
else
  echo "✅ zsh-autosuggestions já instalado!"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "📦 Instalando zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
else
  echo "✅ zsh-syntax-highlighting já instalado!"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
  echo "📦 Instalando fzf-tab..."
  git clone https://github.com/Aloxaf/fzf-tab $ZSH_CUSTOM/plugins/fzf-tab
else
  echo "✅ fzf-tab já instalado!"
fi

# Adiciona plugins no .zshrc se ainda não estiverem lá
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  echo "📝 Adicionando plugins ao .zshrc..."
  sed -i '' 's/plugins=(/plugins=(fzf-tab zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
else
  echo "✅ Plugins já configurados no .zshrc!"
fi

# Configurações adicionais para fzf-tab
if ! grep -q "Configurações do fzf-tab" ~/.zshrc; then
  echo "📝 Adicionando configurações do fzf-tab..."
  echo '' >> ~/.zshrc
  echo '# Configurações do fzf-tab' >> ~/.zshrc
  echo 'zstyle ":completion:*" menu select' >> ~/.zshrc
  echo 'zstyle ":fzf-tab:complete:cd:*" fzf-preview "eza -1 --color=always \$realpath 2>/dev/null || ls -1 \$realpath"' >> ~/.zshrc
  echo 'zstyle ":fzf-tab:*" switch-group "," "."' >> ~/.zshrc
else
  echo "✅ Configurações do fzf-tab já adicionadas!"
fi

# Powerlevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "📦 Instalando Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
else
  echo "✅ Powerlevel10k já instalado!"
fi

# Define o tema no .zshrc se não estiver definido
if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc; then
  echo "📝 Configurando tema Powerlevel10k..."
  if grep -q "ZSH_THEME=" ~/.zshrc; then
    sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
  else
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc
  fi
else
  echo "✅ Tema Powerlevel10k já configurado!"
fi

# Starship
if ! command -v starship &> /dev/null; then
  echo "📦 Instalando Starship..."
  brew install starship
  if ! grep -q "starship init zsh" ~/.zshrc; then
    echo '# Starship prompt (pode comentar se preferir só powerlevel10k)' >> ~/.zshrc
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
  fi
else
  echo "✅ Starship já instalado!"
fi

echo "🎉 Setup concluído! Reinicie o terminal para aplicar as alterações."
