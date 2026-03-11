# --- BUILD STAGE ---
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential cmake git \
    libjack-jackd2-dev libsndfile1-dev libasound2-dev \
    libavahi-client-dev libicu-dev libreadline-dev \
    libfftw3-dev libxt-dev libudev-dev \
    qtbase5-dev qt5-qmake qttools5-dev qttools5-dev-tools \
    libqt5svg5-dev libqt5websockets5-dev \
    qtwebengine5-dev

# Clone and Build
# NOTE: We keep SC_QT=ON to ensure the Class Library compiles successfully.
RUN git clone --recursive https://github.com/supercollider/supercollider.git /tmp/sc
WORKDIR /tmp/sc
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
    -DNATIVE=ON \
    -DSC_EL=OFF \
    -DSC_IDE=OFF \
    -DSC_QT=ON \
    -DNO_X11=OFF \
    .. && \
    make -j$(nproc) && \
    make install

# --- RUNTIME STAGE ---
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime libs + xvfb (Virtual Framebuffer) + jackd (Audio Stub) + python3
RUN apt-get update && apt-get install -y \
    libjack-jackd2-0 libsndfile1 libasound2 \
    libavahi-client3 libicu70 libreadline8 \
    libfftw3-3 libqt5core5a libqt5gui5 libqt5network5 libqt5widgets5 \
    libqt5svg5 libqt5websockets5 libqt5webenginewidgets5 \
    xvfb jackd2 python3 \
    && rm -rf /var/lib/apt/lists/*

# Setup directory structure
WORKDIR /app
RUN mkdir -p /root/.local/share/SuperCollider/Extensions \
    && mkdir -p /root/.local/share/SuperCollider/downloaded-quarks

# Copy binaries from builder
COPY --from=builder /usr/local /usr/local

# Add the entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Add the syntax checker scripts
COPY check_syntax.scd /app/check_syntax.scd
COPY check_syntax.py /app/check_syntax.py

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["sclang"]
