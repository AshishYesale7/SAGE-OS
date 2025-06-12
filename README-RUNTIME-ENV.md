# OpenHands Runtime Environment Replica

This creates a Docker environment that exactly matches the OpenHands runtime environment where SAGE OS development takes place.

## Environment Specifications

**Target Environment:**
- **OS**: Debian GNU/Linux 12 (bookworm)
- **Architecture**: x86_64
- **CPU**: AMD EPYC 9B14 (4 cores simulated)
- **Memory**: 16GB (host), configurable for SAGE OS
- **Kernel**: Linux 5.15.0-1078-gke (containerized equivalent)

## Quick Start

1. **Build and run the environment:**
   ```bash
   ./run-runtime-environment.sh deploy
   ```

2. **Connect via VNC:**
   - URL: `vnc://localhost:5901`
   - Password: `sageos`

3. **SAGE OS will start automatically in the environment**

## Usage Examples

```bash
# Build the environment image
./run-runtime-environment.sh build

# Run with specific configuration
./run-runtime-environment.sh run -a x86_64 -m 256M -d vnc

# Open shell in running container
./run-runtime-environment.sh shell

# Show environment information
./run-runtime-environment.sh info

# View logs
./run-runtime-environment.sh logs

# Stop and clean up
./run-runtime-environment.sh stop
./run-runtime-environment.sh clean
```

## Architecture Support

- **i386**: x86 32-bit (default)
- **x86_64**: x86 64-bit
- **aarch64**: ARM 64-bit
- **arm**: ARM 32-bit
- **riscv64**: RISC-V 64-bit

## Display Modes

- **vnc**: VNC server (recommended)
- **graphics**: Direct QEMU window
- **text**: Terminal only

## Environment Features

✅ **Exact OS Match**: Debian 12 (bookworm)  
✅ **Architecture Match**: x86_64  
✅ **CPU Simulation**: AMD EPYC 9B14  
✅ **Development Tools**: Full build environment  
✅ **QEMU Support**: All architectures  
✅ **VNC Access**: Remote desktop capability  
✅ **Python Environment**: Matching OpenHands setup  
✅ **Container Tools**: Docker-in-Docker support  

## File Structure

```
├── Dockerfile.runtime-env          # Main environment definition
├── run-runtime-environment.sh      # Deployment script
├── README-RUNTIME-ENV.md           # This file
└── SAGE-OS/                        # Mount your SAGE OS source here
```

## Troubleshooting

**Container won't start:**
```bash
# Check Docker
docker info

# Rebuild image
./run-runtime-environment.sh clean
./run-runtime-environment.sh build
```

**VNC connection fails:**
```bash
# Check container status
./run-runtime-environment.sh logs

# Test VNC port
telnet localhost 5901
```

**SAGE OS not found:**
```bash
# Ensure SAGE-OS source is in current directory or ./SAGE-OS/
# The script will auto-mount the source code
```

## Comparison with Original Environment

| Component | Original | Replica |
|-----------|----------|---------|
| OS | Debian 12 (bookworm) | ✅ Exact match |
| Architecture | x86_64 | ✅ Exact match |
| CPU | AMD EPYC 9B14 | ✅ Simulated |
| Kernel | 5.15.0-1078-gke | ✅ Compatible |
| Memory | 16GB | ✅ Host-dependent |
| Python | 3.12 | ✅ Available |
| QEMU | Available | ✅ Full support |
| Docker | Available | ✅ Docker-in-Docker |

This environment provides an identical development experience to the original OpenHands runtime.
