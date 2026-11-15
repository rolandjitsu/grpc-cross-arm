# AGENTS.md

Welcome! This guide is intended for AI agents and automated tools working on the **`grpc-cross-arm`** repository.

---

## 1. Repository Overview

This repository demonstrates how to cross-compile a C++ [gRPC](https://grpc.io/) application for ARM architectures without requiring physical ARM hardware, using Docker, Docker Buildx, and CMake toolchains.

The repository compiles a simple client-server Greeter application defined in [src/hello.proto](file:///Users/roland.groza/Work/grpc-cross-arm/src/hello.proto) into ARM binaries (`bin/hello_server` and `bin/hello_client`).

### Key Technologies
- **Docker & Docker Buildx**: Multi-stage container builds exporting local binaries via `scratch`.
- **CMake**: Build automation and cross-compilation toolchain management.
- **gRPC & Protocol Buffers**: RPC framework and code generators (`protoc`, `grpc_cpp_plugin`).
- **QEMU User Emulation**: Emulating ARM target binaries on x86_64 host machines for verification and CI testing.

---

## 2. Repository Layout

```
.
├── .clang-format              # Code formatting guidelines (Google style, C++/Proto)
├── .editorconfig              # Code formatting guidelines (2-space indent, UTF-8)
├── .github/
│   └── workflows/
│       └── test.yml           # CI test workflow using QEMU emulation
├── .gitignore                 # Ignored files (binaries, caches, editor files)
├── arm.toolchain.cmake        # CMake toolchain file for cross-compilation
├── bin/                       # Output directory for compiled binaries
│   └── .gitkeep
├── docker-bake.hcl            # Docker Buildx Bake configuration
├── Dockerfile                 # Multi-stage Docker build definition
├── LICENSE                    # MIT License
├── README.md                  # Human-facing project documentation
└── src/
    ├── CMakeLists.txt         # CMake build configuration for the demo app
    ├── hello.proto            # Protobuf definition (Greeter service)
    ├── hello_client.cc        # gRPC client demo
    └── hello_server.cc        # gRPC server demo
```

---

## 3. Architecture & Build Pipeline

Cross-compiling gRPC in C++ requires a two-step compilation approach:
1. **Host Build**: gRPC code generators (`protoc` and `grpc_cpp_plugin`) must be compiled natively for the host architecture (`x86_64`) so they can execute during the build to generate C++ protobuf and gRPC stub files (`hello.pb.cc`, `hello.grpc.pb.cc`).
2. **Target Cross Build**: gRPC libraries, Abseil, and runtime dependencies are compiled using the cross-toolchain (e.g. `arm-linux-gnueabihf-gcc` / `g++` or `aarch64-linux-gnu-gcc` / `g++`) and staged in a sysroot prefix (`CROSS_STAGING_PREFIX`).
3. **Application Build**: The application CMake build loads target libraries from the staging prefix while executing host `protoc` and `grpc_cpp_plugin` to produce the final ARM executables.
4. **Binary Export**: The final Docker stage (`FROM scratch`) copies the compiled binaries back to the host filesystem under `./bin`.

---

## 4. Common Commands & Workflows

### Building with Docker Buildx Bake (Recommended)
```bash
# Default build (armhf binaries into ./bin)
docker buildx bake

# Build for 32-bit ARM (output to ./bin/armhf)
docker buildx bake armhf

# Build for 64-bit ARM (output to ./bin/aarch64)
docker buildx bake aarch64

# Build both armhf and aarch64 in parallel
docker buildx bake all

# Build legacy gRPC v1.37.1 on Debian Bullseye
docker buildx bake legacy-armhf
docker buildx bake legacy-aarch64
docker buildx bake legacy

# Build with custom cache destination
CACHE=/tmp/grpc-cross-cache docker buildx bake
```

### Building with Docker Buildx directly
```bash
# Standard build exporting to ./bin
docker buildx build -f Dockerfile -o type=local,dest=./bin .

# Bust Docker layer cache
docker buildx build --no-cache -f Dockerfile -o type=local,dest=./bin .
```

### Building with Podman or Buildah
Podman and Buildah use [Containerfile](file:///Users/roland.groza/Work/grpc-cross-arm/Containerfile) and export binaries using `--output type=local`:
```bash
# Podman build (armhf)
podman build -o type=local,dest=./bin .

# Podman build (aarch64)
podman build --build-arg GNU_HOST=aarch64-linux-gnu -o type=local,dest=./bin/aarch64 .

# Buildah build
buildah build --output type=local,dest=./bin .
```

### Verifying Binaries with QEMU (Linux/CI)
When cross-compiling for 32-bit ARM (`arm-linux-gnueabihf`):
```bash
# Start server in background
qemu-arm -L /usr/arm-linux-gnueabihf/ ./bin/hello_server &
SERVER_PID=$!
sleep 1

# Execute client
out=$(qemu-arm -L /usr/arm-linux-gnueabihf/ ./bin/hello_client John)
echo "$out"  # Expected: "Hello, John!"

# Stop server
kill $SERVER_PID 2>/dev/null || true
```

---

## 5. Coding Standards & Conventions

- **ClangFormat**: Google C++ style, 2-space indentation (see `.clang-format`).
- **EditorConfig**: 2-space indentation, trimmed trailing whitespace, newline at EOF (see `.editorconfig`).
- **CMake**: Target-oriented CMake. Use `target_link_libraries`, `target_include_directories`, and `set(CMAKE_CXX_STANDARD 17)` rather than manually manipulating compiler flag strings.
- **C++**: Modern C++ (C++17). Follow standard C++ naming and RAII resource management.
- **Git Hygiene & Commits**:
  - Never commit build artifacts (`hello_server`, `hello_client`) to `bin/`. Only `bin/.gitkeep` should be tracked.
  - Conventional Commits, subject in imperative present tense: `feat:`, `fix:`, `chore:`, `ci:`, `docs:`, `build:`.
  - Keep the commit body minimal, or omit it. Add a body only for non-obvious *why* or trade-offs. Never restate the diff.
  - Disclose AI with an `Assisted-by: <Provider>:<model-id>` trailer (e.g. `Assisted-by: Antigravity:gemini-3.8-flash` or `Assisted-by: Claude:claude-opus-4-8`), following the Linux kernel AI-assistants guide format. Never `Co-Authored-By`, and never add a human `Signed-off-by`.

---

## 6. Important Caveats & Guidance for Agents

- **Glibc Compatibility**: The glibc version in the Docker container's sysroot must be older than or equal to the glibc version on the test runner or host system where `qemu-arm` runs with the host sysroot (`-L /usr/arm-linux-gnueabihf/`). If the container glibc is newer than the host runner's glibc, QEMU will fail with version mismatch errors (e.g. `GLIBC_X.XX not found`).
- **QEMU Process Management**: Always track backgrounded server process IDs (`$!`) during tests to terminate them cleanly upon completion.
- **Docker Build Isolation**: Commands run inside Docker without network access during the build stage unless specified. Dependencies (like gRPC submodules) must be cloned recursively during image build.
