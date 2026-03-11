# Plan for running SuperCollider in Docker (Debugging focus) - REVISED

This plan outlines how to create a Docker environment for building and running **sclang** in a headless mode. 

**Revisions Note:** This plan has been updated to include a **Virtual Framebuffer (Xvfb)** and a **Dummy Audio Driver**. This is strictly necessary because the standard SuperCollider Class Library dependencies (GUI classes) and Server boot sequence often crash in a purely "naked" headless environment.

## Key Objectives
- **Full Class Library Support**: Ensure `sclang` compiles the library without errors by mocking the GUI layer (QT).
- **Audio Server Stub**: Allow `s.boot` and `Ndef` usage by mocking the audio hardware via JACK dummy driver.
- **Debugging Tools**: Include necessary utilities for code inspection.
- **Quarks & Extensions**: Persistence for package management.

## Configuration Files

### 1. [Dockerfile](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/Dockerfile)

**Changes:**
- **Build Stage**: Now compiles with `-DSC_QT=ON` to prevent class library missing symbol errors.
- **Runtime Stage**: Installs `xvfb` (X Virtual Framebuffer) and `jackd2`.
- **Entrypoint**: Uses a wrapper script to handle the virtual environment setup.

```dockerfile
# --- BUILD STAGE ---
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential cmake git \
    libjack-jackd2-dev libsndfile1-dev libasound2-dev \
    libavahi-client-dev libicu-dev libreadline-dev \
    libfftw3-dev libxt-dev libudev-dev \
    qtbase5-dev qt5-qmake qttools5-dev qttools5-dev-tools \
    libqt5svg5-dev libqt5websockets5-dev

# Clone and Build
# NOTE: We keep SC_QT=ON to ensure the Class Library compiles successfully.
RUN git clone --recursive [https://github.com/supercollider/supercollider.git](https://github.com/supercollider/supercollider.git) /tmp/sc
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

# Install runtime libs + xvfb (Virtual Framebuffer) + jackd (Audio Stub)
RUN apt-get update && apt-get install -y \
    libjack-jackd2-0 libsndfile1 libasound2 \
    libavahi-client3 libicu70 libreadline8 \
    libfftw3-3 libqt5core5a libqt5gui5 libqt5network5 libqt5widgets5 \
    libqt5svg5 libqt5websockets5 \
    xvfb jackd2 \
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

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["sclang"]
2. [NEW] entrypoint.sh
Purpose: This script handles the "mocking" of hardware. It starts a dummy audio server and wraps the SuperCollider execution in a virtual display so that GUI code doesn't crash the container.

Bash
#!/bin/bash
set -e

# 1. Start a dummy audio server (so s.boot works without a soundcard)
# -r = realtime, -d dummy = no hardware output
jackd -r -d dummy -r 44100 -p 1024 &
JACK_PID=$!

# 2. Wait a moment for JACK to be ready
sleep 2

# 3. Run the command passed to docker (default: sclang)
# xvfb-run wraps execution to provide a fake display for QT
exec xvfb-run -a "$@"
3. docker-compose.yml
Changes:

Added tty and stdin_open to keep the container alive for interactive debugging.

Mapped volumes for extensions and debugging scripts.

YAML
version: '3.8'
services:
  sc-debug:
    build: .
    image: supercollider-debug
    container_name: sc_debug_instance
    volumes:
      # Scripts to debug
      - ./debug_scripts:/app/scripts
      # Persistence for user extensions
      - ./user_extensions:/root/.local/share/SuperCollider/Extensions
      # Persistence for downloaded quarks
      - ./quarks:/root/.local/share/SuperCollider/downloaded-quarks
      # Optional: Config persistence
      - ./config:/root/.config/SuperCollider
    environment:
      # Helps QT know we are headless (though xvfb handles the heavy lifting)
      - QT_QPA_PLATFORM=offscreen
    # Keep container alive for interactive attachment
    tty: true 
    stdin_open: true
Verification Plan
Automated Tests
Build Test: Run docker build -t supercollider-debug ..

Audio Stub Test: Run a one-liner to verify scsynth can boot on the dummy driver.

Command: docker run --rm supercollider-debug sclang -e "s.waitForBoot { 'Server booted!'.postln; 0.exit }"

Success Condition: Output contains "Server booted!".

GUI Class Test: Verify that accessing a GUI class doesn't segfault (thanks to Xvfb).

Command: docker run --rm supercollider-debug sclang -e "Window.new.close; 'GUI OK'.postln; 0.exit"

Success Condition: Output contains "GUI OK".

Quark Test: Run a script via sclang that attempts to load a basic Quark and verify it works.
