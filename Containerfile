# Stage 1: Builder stage for downloading and extracting artifacts
FROM ubuntu:latest AS builder
ARG ARCH_f1
ARG ARCH_f2
# Set environment variables for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive \
    PYENV_ROOT="/root/.pyenv" \
    PATH="/root/.pyenv/bin:$PATH"

# Install build dependencies, including fontconfig
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    fontconfig \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install FiraCode Nerd Font
RUN mkdir -p /root/.fonts \
    && curl -Lo /tmp/firacode.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip" \
    && unzip /tmp/firacode.zip -d /root/.fonts/ \
    && fc-cache -fv \
    && rm /tmp/firacode.zip

COPY ./zscaler.crt /usr/local/share/ca-certificates/zscaler.crt
RUN update-ca-certificates 

# Install pyenv and set up Python virtualenv
RUN curl https://pyenv.run | bash \
    && eval "$(pyenv init --path)" \
    && eval "$(pyenv init -)" \
    && eval "$(pyenv virtualenv-init -)" \
    && pyenv install -s 3.9.0 \
    && pyenv global 3.9.0 \
    && pyenv virtualenv 3.9.0 nvim \
    && pyenv activate nvim \
    && pip install pynvim \
    && pyenv deactivate

# Install LazyGit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*' || echo "0.55.1") \
    && echo "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_${ARCH_f1}.tar.gz" \
    && curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_${ARCH_f1}.tar.gz" \
    && tar xf /tmp/lazygit.tar.gz -C /usr/local/bin/ \
    && rm /tmp/lazygit.tar.gz

# Install Neovim
RUN curl -Lo /tmp/nvim-linux-${ARCH_f1}.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${ARCH_f1}.tar.gz" \
    && mkdir -p /tmp/nvim-extracted \
    && tar xzf /tmp/nvim-linux-${ARCH_f1}.tar.gz -C /tmp/nvim-extracted \
    && mv /tmp/nvim-extracted/nvim-linux-${ARCH_f1} /opt/nvim \
    && rm -rf /tmp/nvim-linux-${ARCH_f1}.tar.gz /tmp/nvim-extracted

# Install Go with version validation
RUN GO_VERSION_RAW=$(curl -s --retry 3 --connect-timeout 10 --fail https://go.dev/VERSION?m=text|head -1|| echo "go1.23.1") \
    && echo "Raw Go version output: $GO_VERSION_RAW" \
    && GO_VERSION=$GO_VERSION_RAW \
    && echo "Using Go version: $GO_VERSION" \
    && echo "Getting: https://go.dev/dl/${GO_VERSION}.linux-${ARCH_f2}.tar.gz" \
    && curl -Lo /tmp/go.tar.gz --retry 3 --connect-timeout 10 --fail "https://go.dev/dl/${GO_VERSION}.linux-${ARCH_f2}.tar.gz" \
    && tar -C /usr/local -xzf /tmp/go.tar.gz \
    && rm /tmp/go.tar.gz

# Stage 2: Config stage for Neovim configuration
FROM ubuntu:latest AS config

# Install git for cloning Neovim configuration
RUN apt-get update && apt-get install -y \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Neovim binary from builder stage to run configuration commands
COPY --from=builder /opt/nvim /opt/nvim

RUN git clone --depth 1 https://github.com/b0bul/neovimrc.git /root/dev/neovimrc

RUN git clone https://github.com/b0bul/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

# Enable custom plugins and Nerd Fonts in configuration (if not already enabled)
RUN sed -i "s/-- { import = 'custom.plugins' },/{ import = 'custom.plugins' },/" /root/.config/nvim/init.lua \
    && sed -i "s/vim.g.have_nerd_font = false/vim.g.have_nerd_font = true/" /root/.config/nvim/init.lua || true


# Sync Neovim customizations from /root/dev/neovimrc
WORKDIR /root/dev/neovimrc
RUN /opt/nvim/bin/nvim --headless -c "luafile after/plugin/sync.lua" -c "lua Sync({})" -c "qa" || true

# Stage 3: Final stage for runtime environment
FROM ubuntu:latest

# Set environment variables for runtime
ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/go/bin:/opt/nvim/bin:/root/.pyenv/bin:$PATH" \
    PYENV_ROOT="/root/.pyenv" \
    HOME="/root"

# Install runtime dependencies (eBPF, fonts, and essential tools), including fontconfig
RUN apt-get update && apt-get install -y \
    git \
    npm \
    linux-headers-generic \
    linux-tools-common \
    linux-tools-generic \
    libbpf-dev \
    libbpfcc-dev \
    llvm \
    clang \
    gcc \
    make \
    pkg-config \
    fonts-firacode \
    fontconfig \
    python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy artifacts from builder stage
COPY --from=builder /root/.fonts /root/.fonts
COPY --from=builder /root/.pyenv /root/.pyenv
COPY --from=builder /usr/local/bin/lazygit /usr/local/bin/lazygit
COPY --from=builder /opt/nvim /opt/nvim
COPY --from=builder /usr/local/go /usr/local/go

# Copy Neovim configuration and development repo from config stage
COPY --from=config /root/.config/nvim /root/.config/nvim
COPY --from=config /root/dev /root/dev

# Set up font cache
RUN fc-cache -fv

# Configure shell environment
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /root/.bashrc \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /root/.bashrc \
    && echo 'eval "$(pyenv init --path)"' >> /root/.bashrc \
    && echo 'eval "$(pyenv init -)"' >> /root/.bashrc \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.bashrc \
    && echo "alias vim='nvim'" >> /root/.bashrc \
    && echo 'export PATH=$PATH:/usr/local/go/bin:/opt/nvim/bin' > /etc/profile.d/env.sh \
    && chmod 644 /etc/profile.d/env.sh

# Set working directory
WORKDIR /root

# Default command
CMD ["/bin/bash"]
