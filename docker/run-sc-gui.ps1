# SuperCollider GUI Docker Launcher for Windows
# This script sets up X11 forwarding and launches the SuperCollider IDE in Docker

param(
    [switch]$Build,
    [switch]$Rebuild,
    [string]$Command = "scide"
)

$ErrorActionPreference = "Stop"

Write-Host "SuperCollider Docker GUI Launcher" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Detect DISPLAY configuration for X11 forwarding
# Try WSLg first (Windows 11), then fall back to manual IP detection for VcXsrv

function Get-WSL2HostIP {
    # Get the host IP that WSL2 can reach
    $wslHostIP = (Get-NetIPAddress -InterfaceAlias "vEthernet (WSL*)" -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
    if (-not $wslHostIP) {
        # Alternative: use ipconfig to find the WSL adapter
        $ipconfigOutput = ipconfig | Select-String -Pattern "vEthernet \(WSL" -Context 0,5
        if ($ipconfigOutput) {
            $ipLine = $ipconfigOutput.Context.PostContext | Select-String -Pattern "IPv4.*: (\d+\.\d+\.\d+\.\d+)"
            if ($ipLine) {
                $wslHostIP = $ipLine.Matches.Groups[1].Value
            }
        }
    }
    return $wslHostIP
}

# Check for WSLg (Windows 11 built-in X server)
$wslgSocket = "\\wsl$\Ubuntu\mnt\wslg\.X11-unix"
$useWSLg = Test-Path $wslgSocket -ErrorAction SilentlyContinue

if ($useWSLg) {
    Write-Host "Detected WSLg (Windows 11) - using built-in X server" -ForegroundColor Green
    $env:DISPLAY = ":0"
} else {
    # Use VcXsrv or other X server
    Write-Host "WSLg not detected - using VcXsrv/X server" -ForegroundColor Yellow
    
    # Try to detect the host IP for Docker Desktop
    $hostIP = "host.docker.internal"
    $env:DISPLAY = "${hostIP}:0.0"
    
    Write-Host "Please ensure VcXsrv is running with 'Disable access control' enabled" -ForegroundColor Yellow
}

Write-Host "DISPLAY set to: $($env:DISPLAY)" -ForegroundColor Green

# Change to docker directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Build if requested or if image doesn't exist
$imageExists = docker images -q supercollider-gui 2>$null
if ($Build -or $Rebuild -or (-not $imageExists)) {
    Write-Host "`nBuilding SuperCollider Docker image..." -ForegroundColor Cyan
    Write-Host "This may take 30-60 minutes on first build." -ForegroundColor Yellow
    
    $buildArgs = @("compose", "-f", "docker-compose.gui.yml", "build")
    if ($Rebuild) {
        $buildArgs += "--no-cache"
    }
    
    & docker @buildArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Docker build failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "Build completed successfully!" -ForegroundColor Green
}

# Run the container
Write-Host "`nStarting SuperCollider IDE..." -ForegroundColor Cyan
Write-Host "Command: $Command" -ForegroundColor Gray

docker compose -f docker-compose.gui.yml run --rm supercollider-gui $Command

Write-Host "`nSuperCollider session ended." -ForegroundColor Cyan
