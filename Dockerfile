FROM codercom/enterprise-base:ubuntu

# Install essential tools and Zsh with GRML
USER root
RUN apt-get update && apt-get install -y \
    zsh \
    tmux \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && /root/.cargo/bin/rustup install stable \
    && /root/.cargo/bin/rustup default stable \
    && /root/.cargo/bin/cargo install cargo-watch

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

# Install and configure GRML Zsh
RUN wget -O /home/coder/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc \
    && wget -O /home/coder/.zshrc.local https://git.grml.org/f/grml-etc-core/etc/skel/.zshrc \
    && chown coder:coder /home/coder/.zshrc /home/coder/.zshrc.local \
    && chsh -s $(which zsh) coder

# Set the workspace directory
WORKDIR /workspaces
