<#
.SYNOPSIS
    SuperCollider Syntax Checker for Windows
.DESCRIPTION
    Checks SuperCollider code syntax using Docker container.
    Returns structured output indicating success or failure.
.PARAMETER CodeInput
    Either a file path to a .scd file, or inline SuperCollider code as a string.
.EXAMPLE
    .\Check-SCCode.ps1 -CodeInput "{ SinOsc.ar(440) }.play"
.EXAMPLE
    .\Check-SCCode.ps1 -CodeInput "C:\path\to\mycode.scd"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$CodeInput
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CodeInputDir = Join-Path $ScriptDir "code_input"
$ContainerName = "sc_syntax_checker"

# Ensure code_input directory exists
if (-not (Test-Path $CodeInputDir)) {
    New-Item -ItemType Directory -Path $CodeInputDir -Force | Out-Null
}

# Generate temp filename
$TempFileName = "temp_$(Get-Date -Format 'yyyyMMddHHmmssfff').scd"
$TempFilePath = Join-Path $CodeInputDir $TempFileName

try {
    # Check if input is a file or inline code
    if (Test-Path $CodeInput) {
        # It's a file - copy contents
        Copy-Item $CodeInput $TempFilePath
    } else {
        # It's inline code - write to temp file
        $CodeInput | Out-File -FilePath $TempFilePath -Encoding utf8 -NoNewline
    }

    # Run syntax checker in Docker
    $result = docker exec $ContainerName sclang /app/check_syntax.scd "/app/code_input/$TempFileName"
    $exitCode = $LASTEXITCODE

    # Output result
    $result

    exit $exitCode
}
finally {
    # Cleanup temp file
    if (Test-Path $TempFilePath) {
        Remove-Item $TempFilePath -Force
    }
}
