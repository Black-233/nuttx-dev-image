# Containerfile
# author: melon

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Prerequisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bison flex gettext texinfo libncurses5-dev libncursesw5-dev xxd \
    curl ca-certificates \
    git gperf automake libtool pkg-config build-essential genromfs \
    libgmp-dev libmpc-dev libmpfr-dev libisl-dev binutils-dev libelf-dev \
    libexpat1-dev gcc-multilib g++-multilib picocom u-boot-tools util-linux \
    python3 python3-pip python3-venv \
    ccache bear clangd clang-format openocd gdb-multiarch \
    ripgrep fd-find && \
    ln -sf "$(which fdfind)" /usr/local/bin/fd && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir esptool kconfiglib
ENV PATH="/opt/venv/bin:$PATH"

# RISC-V toolchain
RUN mkdir -p /tools/riscv-none-elf-gcc && \
    curl -fL "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz" \
    | tar -C /tools/riscv-none-elf-gcc --strip-components 1 -xz

ENV PATH="/tools/riscv-none-elf-gcc/bin:$PATH"

# ccache
RUN mkdir -p /ccache /tools/ccache/bin && \
    chmod 777 /ccache && \
    ln -sf /usr/bin/ccache /tools/ccache/bin/riscv-none-elf-gcc && \
    ln -sf /usr/bin/ccache /tools/ccache/bin/riscv-none-elf-g++

ENV PATH="/tools/ccache/bin:$PATH" \
    CCACHE_DIR="/ccache"

WORKDIR /workspace

CMD ["/bin/bash"]
