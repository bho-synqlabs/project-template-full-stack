# PowerShell script to generate TypeScript types from ASP.NET Core API (.NET 9)
param(
    [string]$OutputPath = $null,
    [string]$Environment = "Development",
    [string]$ConfigFile = $null,
    [switch]$CopyToFrontend
)

Write-Host "🔧 Starting TypeScript type generation..."

# Determine configuration file to use
if ($ConfigFile) {
    $nswagConfig = $ConfigFile
} elseif (Test-Path "src/Web.Api/nswag.local.json") {
    $nswagConfig = "nswag.local.json"
    Write-Host "📋 Using local configuration: nswag.local.json"
} else {
    $nswagConfig = "nswag.json"
    Write-Host "📋 Using default configuration: nswag.json"
}

# Check for environment variable for output path
if (-not $OutputPath) {
    if ($env:FRONTEND_TYPES_PATH) {
        $OutputPath = $env:FRONTEND_TYPES_PATH
        Write-Host "🌍 Using environment variable FRONTEND_TYPES_PATH: $OutputPath"
    }
}

# Change to Web.Api directory
Set-Location "src/Web.Api"

try {
    # Build the project first
    Write-Host "📦 Building the Web.Api project..."
    dotnet build --configuration Debug

    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ Build failed. Please fix build errors before generating types."
        exit 1
    }

    # Generate TypeScript types using NSwag
    Write-Host "🚀 Generating TypeScript types..."
    dotnet tool restore
    
    # Temporarily modify output path if specified
    if ($OutputPath) {
        Write-Host "📝 Temporarily updating output path to: $OutputPath"
        $configContent = Get-Content $nswagConfig -Raw | ConvertFrom-Json
        $originalOutput = $configContent.codeGenerators.openApiToTypeScriptClient.output
        $configContent.codeGenerators.openApiToTypeScriptClient.output = $OutputPath
        $tempConfig = "nswag.temp.json"
        $configContent | ConvertTo-Json -Depth 20 | Set-Content $tempConfig
        $nswagConfig = $tempConfig
    }
    
    dotnet nswag run $nswagConfig

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ TypeScript types generated successfully!"
        
        if ($OutputPath) {
            Write-Host "📁 Generated to: $OutputPath"
        } else {
            Write-Host "📁 Generated to default location (check nswag.json output setting)"
        }
        
        if ($CopyToFrontend -and $env:FRONTEND_REPO_PATH) {
            $frontendTypesPath = Join-Path $env:FRONTEND_REPO_PATH "src/types/api-types.ts"
            Write-Host "📋 Copying to frontend: $frontendTypesPath"
            Copy-Item ($OutputPath ?? "./generated/api-types.ts") $frontendTypesPath -Force
            Write-Host "✅ Copied to frontend successfully!"
        }
        
        Write-Host "🎉 Generation complete!"
    } else {
        Write-Error "❌ Type generation failed. Check the output above for errors."
        exit 1
    }
}
catch {
    Write-Error "❌ An error occurred: $_"
    exit 1
}
finally {
    # Clean up temporary config file
    if ($OutputPath -and (Test-Path "nswag.temp.json")) {
        Remove-Item "nswag.temp.json" -Force
    }
    
    # Return to root directory
    Set-Location "../.."
}
