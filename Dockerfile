FROM codercom/enterprise-base:ubuntu

# Rust deps
RUN apt-get update && apt-get install -y curl build-essential \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && ~/.cargo/bin/rustup install stable \
    && ~/.cargo/bin/rustup default stable

# Go deps
RUN curl -fsSL https://golang.org/dl/go1.20.linux-amd64.tar.gz | tar -C /usr/local -xz \
    && echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile

# Set PATH for Rust and Go
ENV PATH="/root/.cargo/bin:/usr/local/go/bin:$PATH"

# Install cargo-watch
RUN ~/.cargo/bin/cargo install cargo-watch

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

# Setup shell tools
RUN apt-get install -y zsh tmux \
    && wget -O /home/coder/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc \
    && wget -O /home/coder/.zshrc.local https://git.grml.org/f/grml-etc-core/etc/skel/.zshrc \
    && chsh -s $(which zsh) coder \
    && chown coder:coder /home/coder/.zshrc /home/coder/.zshrc.local

# Install kubectl & kind
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 \
    && chmod +x ./kind \
    && mv ./kind /usr/local/bin/kind

WORKDIR /workspaces
