FROM ubuntu:24.04

ENV DEBIAN_FRONTEND="noninteractive"

# Prerequisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bison flex gettext texinfo libncurses5-dev libncursesw5-dev xxd curl ca-certificates \
    git gperf automake libtool pkg-config build-essential gperf genromfs \
    libgmp-dev libmpc-dev libmpfr-dev libisl-dev binutils-dev libelf-dev \
    libexpat1-dev gcc-multilib g++-multilib picocom u-boot-tools util-linux \
    python3 python3-pip ccache bear clangd clang-format openocd gdb-multiarch kconfig-frontends \
    ripgrep fd-find && \
    ln -s $(which fdfind) /usr/local/bin/fd && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --break-system-packages esptool kconfiglib

# RISCV toolchain
RUN mkdir -p /tools/riscv-none-elf-gcc && \
    curl -s -L "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz" \
    | tar -C /tools/riscv-none-elf-gcc --strip-components 1 -xz

ENV PATH="/tools/riscv-none-elf-gcc/bin:$PATH"

# Configure ccache
RUN mkdir -p /ccache && \
    chmod 666 /ccache && \
    mkdir -p /tools/ccache/bin && \
    ln -sf $(which ccache) /tools/ccache/bin/riscv-none-elf-gcc && \
    ln -sf $(which ccache) /tools/ccache/bin/riscv-none-elf-g++

ENV PATH="/tools/ccache/bin:$PATH" \
    CCACHE_DIR="/ccache"

RUN mkdir -p /workspace

WORKDIR /workspace

CMD ["/bin/bash"]
