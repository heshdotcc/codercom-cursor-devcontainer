# Use a lightweight base image
FROM mcr.microsoft.com/devcontainers/base:debian

# Install Rust
RUN apt-get update && apt-get install -y curl build-essential \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && ~/.cargo/bin/rustup install stable \
    && ~/.cargo/bin/rustup default stable

# Install Go
RUN curl -fsSL https://golang.org/dl/go1.20.linux-amd64.tar.gz | tar -C /usr/local -xz \
    && echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile

# Set PATH for Rust and Go
ENV PATH="/root/.cargo/bin:/usr/local/go/bin:$PATH"
