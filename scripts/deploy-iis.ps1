# =============================================================================
# Red Taxi Platform - IIS Deployment Script (Local/Staging)
# Usage: .\scripts\deploy-iis.ps1 [-SkipBuild] [-Configuration Release]
# =============================================================================
param(
    [switch]$SkipBuild,
    [string]$Configuration = "Release",
    [string]$PublishPath = "C:\inetpub\redtaxi",
    [string]$ApiAppPool = "RedTaxiAPI",
    [string]$BlazorAppPool = "RedTaxiBlazor",
    [string]$ApiSiteName = "RedTaxi API",
    [string]$BlazorSiteName = "RedTaxi Blazor"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Write-Step($message) {
    Write-Host "`n[STEP] $message" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "[OK]   $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "[WARN] $message" -ForegroundColor Yellow
}

function Write-Fail($message) {
    Write-Host "[FAIL] $message" -ForegroundColor Red
}

# ---------------------------------------------------------------------------
# Validate prerequisites
# ---------------------------------------------------------------------------
Write-Step "Validating prerequisites..."

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Fail "dotnet SDK not found in PATH."
    exit 1
}

# Check if running as Administrator (required for IIS management)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Fail "This script must be run as Administrator for IIS management."
    exit 1
}

# Import WebAdministration module
try {
    Import-Module WebAdministration -ErrorAction Stop
    Write-Success "WebAdministration module loaded."
} catch {
    Write-Fail "WebAdministration module not available. Ensure IIS is installed."
    exit 1
}

# ---------------------------------------------------------------------------
# Build and publish .NET projects
# ---------------------------------------------------------------------------
$ApiPublishPath = Join-Path $PublishPath "api"
$BlazorPublishPath = Join-Path $PublishPath "blazor"

if (-not $SkipBuild) {
    Write-Step "Restoring NuGet packages..."
    dotnet restore "$ProjectRoot\src\RedTaxi.sln"
    if ($LASTEXITCODE -ne 0) { Write-Fail "Restore failed."; exit 1 }

    Write-Step "Building solution ($Configuration)..."
    dotnet build "$ProjectRoot\src\RedTaxi.sln" -c $Configuration --no-restore
    if ($LASTEXITCODE -ne 0) { Write-Fail "Build failed."; exit 1 }

    Write-Step "Publishing API to $ApiPublishPath..."
    dotnet publish "$ProjectRoot\src\RedTaxi.API" -c $Configuration -o $ApiPublishPath --no-build
    if ($LASTEXITCODE -ne 0) { Write-Fail "API publish failed."; exit 1 }
    Write-Success "API published."

    Write-Step "Publishing Blazor to $BlazorPublishPath..."
    dotnet publish "$ProjectRoot\src\RedTaxi.Blazor" -c $Configuration -o $BlazorPublishPath --no-build
    if ($LASTEXITCODE -ne 0) { Write-Fail "Blazor publish failed."; exit 1 }
    Write-Success "Blazor published."
} else {
    Write-Warning "Skipping build (--SkipBuild flag set)."
}

# ---------------------------------------------------------------------------
# Manage IIS App Pools and Sites
# ---------------------------------------------------------------------------
function Ensure-AppPool($poolName) {
    if (-not (Test-Path "IIS:\AppPools\$poolName")) {
        Write-Step "Creating app pool: $poolName"
        New-WebAppPool -Name $poolName
        Set-ItemProperty "IIS:\AppPools\$poolName" -Name "managedRuntimeVersion" -Value ""
        Set-ItemProperty "IIS:\AppPools\$poolName" -Name "startMode" -Value "AlwaysRunning"
    }
    return $poolName
}

function Stop-AppPoolSafe($poolName) {
    if (Test-Path "IIS:\AppPools\$poolName") {
        $state = (Get-WebAppPoolState -Name $poolName).Value
        if ($state -eq "Started") {
            Write-Step "Stopping app pool: $poolName"
            Stop-WebAppPool -Name $poolName
            # Wait for the pool to stop
            $retries = 30
            while ((Get-WebAppPoolState -Name $poolName).Value -ne "Stopped" -and $retries -gt 0) {
                Start-Sleep -Seconds 1
                $retries--
            }
            Write-Success "App pool stopped: $poolName"
        }
    }
}

function Start-AppPoolSafe($poolName) {
    if (Test-Path "IIS:\AppPools\$poolName") {
        $state = (Get-WebAppPoolState -Name $poolName).Value
        if ($state -ne "Started") {
            Write-Step "Starting app pool: $poolName"
            Start-WebAppPool -Name $poolName
            Write-Success "App pool started: $poolName"
        }
    }
}

# Ensure app pools exist
Ensure-AppPool $ApiAppPool
Ensure-AppPool $BlazorAppPool

# Stop app pools before deploying
Write-Step "Stopping app pools for deployment..."
Stop-AppPoolSafe $ApiAppPool
Stop-AppPoolSafe $BlazorAppPool

# Short delay to ensure file locks are released
Start-Sleep -Seconds 2

# ---------------------------------------------------------------------------
# Create IIS sites if they do not exist
# ---------------------------------------------------------------------------
if (-not (Get-Website -Name $ApiSiteName -ErrorAction SilentlyContinue)) {
    Write-Step "Creating IIS site: $ApiSiteName"
    New-Website -Name $ApiSiteName `
        -PhysicalPath $ApiPublishPath `
        -ApplicationPool $ApiAppPool `
        -Port 5001 `
        -Force
    Write-Success "Site created: $ApiSiteName on port 5001"
} else {
    Set-ItemProperty "IIS:\Sites\$ApiSiteName" -Name "physicalPath" -Value $ApiPublishPath
}

if (-not (Get-Website -Name $BlazorSiteName -ErrorAction SilentlyContinue)) {
    Write-Step "Creating IIS site: $BlazorSiteName"
    New-Website -Name $BlazorSiteName `
        -PhysicalPath $BlazorPublishPath `
        -ApplicationPool $BlazorAppPool `
        -Port 5002 `
        -Force
    Write-Success "Site created: $BlazorSiteName on port 5002"
} else {
    Set-ItemProperty "IIS:\Sites\$BlazorSiteName" -Name "physicalPath" -Value $BlazorPublishPath
}

# ---------------------------------------------------------------------------
# Restart app pools
# ---------------------------------------------------------------------------
Write-Step "Starting app pools..."
Start-AppPoolSafe $ApiAppPool
Start-AppPoolSafe $BlazorAppPool

# ---------------------------------------------------------------------------
# Health checks
# ---------------------------------------------------------------------------
Write-Step "Running health checks..."
Start-Sleep -Seconds 5

try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5001/health" -UseBasicParsing -TimeoutSec 10
    if ($apiResponse.StatusCode -eq 200) {
        Write-Success "API health check: PASSED"
    } else {
        Write-Warning "API health check returned: $($apiResponse.StatusCode)"
    }
} catch {
    Write-Fail "API health check: FAILED - $_"
}

try {
    $blazorResponse = Invoke-WebRequest -Uri "http://localhost:5002/health" -UseBasicParsing -TimeoutSec 10
    if ($blazorResponse.StatusCode -eq 200) {
        Write-Success "Blazor health check: PASSED"
    } else {
        Write-Warning "Blazor health check returned: $($blazorResponse.StatusCode)"
    }
} catch {
    Write-Fail "Blazor health check: FAILED - $_"
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Host "`n=========================================" -ForegroundColor Green
Write-Host "  IIS Deployment Complete!" -ForegroundColor Green
Write-Host "  API:    http://localhost:5001" -ForegroundColor Green
Write-Host "  Blazor: http://localhost:5002" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
