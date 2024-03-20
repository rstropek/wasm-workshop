ARG base_image=ubuntu:jammy

# Base image, installs various commonly used tools
FROM $base_image AS base
RUN apt update \
    && apt install -y \
        build-essential \
        wget \
        git \
        curl \
        vim \
        ca-certificates \
        gnupg \
        pkg-config \
        libssl-dev

# Build WABT tools from source
FROM base AS wabt
WORKDIR /app
RUN apt install -y \
        cmake \
        software-properties-common \
        python3-pip \
    && git clone --recursive https://github.com/WebAssembly/wabt \
    && cd wabt \
    && git submodule update --init \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build .

# Build final image
FROM base
ARG wasi_sdk=21
ARG dotnet_repo=22.04
ARG dotnet_version=8.0
ARG node_major=20
ARG wasm_tools=1.201.0
# Copy WABT tools
COPY --from=wabt /app/wabt/build/wat2wasm \
    /app/wabt/build/wasm2wat \
    /app/wabt/build/wasm-objdump \
    /app/wabt/build/wasm-decompile \
    /app/wabt/build/wat-desugar \
    /app/wabt/build/wasm2c \
    /app/wabt/build/wasm-strip \
    /app/wabt/build/wasm-validate \
    /app/wabt/build/wast2json \
    /app/wabt/build/wasm-stats \
    /app/wabt/build/spectest-interp \
    /opt/wabt/bin/
RUN echo 'export PATH=$PATH:/opt/wabt/bin' >> ~/.bashrc
RUN curl https://wasmtime.dev/install.sh -sSf | bash
RUN curl https://get.wasmer.io -sSfL | bash
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH $PATH:/root/.cargo/bin
RUN rustup target add wasm32-wasi \
    && rustup target add wasm32-unknown-unknown \
    && curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
RUN cargo install --git https://github.com/bytecodealliance/cargo-component --locked cargo-component \
    && cargo install --git https://github.com/bytecodealliance/wit-bindgen wit-bindgen-cli \
    && cargo install cargo-wasix
RUN curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash \
    && mkdir /opt/spin \
    && mv spin /opt/spin/ \
    && echo 'export PATH=$PATH:/opt/spin' >> ~/.bashrc
RUN cd /opt \
    && wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$wasi_sdk/wasi-sdk-$wasi_sdk.0-linux.tar.gz \
    && tar xvf wasi-sdk-$wasi_sdk.0-linux.tar.gz \
    && rm wasi-sdk-$wasi_sdk.0-linux.tar.gz \
    && echo 'export PATH=$PATH:/opt/wasi-sdk-$wasi_sdk.0' >> ~/.bashrc
RUN cd /opt \
    && wget https://github.com/bytecodealliance/wasm-tools/releases/download/v$wasm_tools/wasm-tools-$wasm_tools-x86_64-linux.tar.gz \
    && tar xvf wasm-tools-$wasm_tools-x86_64-linux.tar.gz \
    && rm wasm-tools-$wasm_tools-x86_64-linux.tar.gz \
    && mv ./wasm-tools-$wasm_tools-x86_64-linux/ ./wasm-tools/ \
    && echo 'export PATH=$PATH:/opt/wasm-tools' >> ~/.bashrc
RUN wget https://packages.microsoft.com/config/ubuntu/$dotnet_repo/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt update \
    && apt install dotnet-sdk-$dotnet_version -y \
    && dotnet workload install wasm-tools \
    && dotnet workload install wasm-experimental \
    && apt install libxml2
RUN curl -sSf https://just.systems/install.sh | bash -s -- --to /opt/just \
    && echo 'export PATH=$PATH:/opt/just' >> ~/.bashrc
RUN apt remove nodejs npm -y \
    && apt update \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$node_major.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt update \
    && apt install nodejs -y \
    && npm install --global http-server
RUN npm install --global @bytecodealliance/jco @bytecodealliance/componentize-js

WORKDIR /root
RUN git clone https://github.com/emscripten-core/emsdk.git \
    && cd emsdk \
    && ./emsdk install latest \
    && ./emsdk activate latest \
    && echo 'export PATH=$PATH:/root/emsdk:/root/emsdk/upstream/emscripten' >> ~/.bashrc \
    && echo 'export EMSDK=/root/emsdk' >> ~/.bashrc \
    && echo 'export EMSDK_NODE=/root/emsdk/node/16.20.0_64bit/bin/node' >> ~/.bashrc
ENV CCWASM /opt/wasi-sdk-$wasi_sdk.0/bin/clang --sysroot=/opt/wasi-sdk-$wasi_sdk.0/share/wasi-sysroot
