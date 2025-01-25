FROM codercom/enterprise-base:ubuntu

USER root

# Update and install essential packages
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    zsh \
    tmux \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && /root/.cargo/bin/rustup install stable \
    && /root/.cargo/bin/rustup default stable

# Set Rust in PATH
ENV PATH="/root/.cargo/bin:$PATH"

# Install cargo-watch
RUN /root/.cargo/bin/cargo install cargo-watch

# Install Go
RUN curl -fsSL https://golang.org/dl/go1.20.linux-amd64.tar.gz | tar -C /usr/local -xz \
    && echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install kind
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 \
    && chmod +x ./kind \
    && mv ./kind /usr/local/bin/kind

# Setup shell tools
RUN wget -O /home/coder/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc \
    && wget -O /home/coder/.zshrc.local https://git.grml.org/f/grml-etc-core/etc/skel/.zshrc \
    && chown coder:coder /home/coder/.zshrc /home/coder/.zshrc.local

# Set default shell to Zsh for coder user
RUN chsh -s $(which zsh) coder

USER coder

# Install code-server extensions
RUN code-server --install-extension rust-lang.rust-analyzer \
    && code-server --install-extension golang.go \
    && code-server --install-extension GitHub.github-vscode-theme \
    && code-server --install-extension GitHub.copilot \
    && code-server --install-extension eamodio.gitlens \
    && code-server --install-extension Continue.continue

# Set default code-server theme
RUN mkdir -p ~/.config/Code/User \
    && echo '{ "workbench.colorTheme": "GitHub Dark Default" }' > ~/.config/Code/User/settings.json

WORKDIR /workspaces
