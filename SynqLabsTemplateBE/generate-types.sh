#!/bin/bash

# Bash script to generate TypeScript types from ASP.NET Core API (.NET 9)
OUTPUT_PATH=$1
ENVIRONMENT=${2:-"Development"}
CONFIG_FILE=$3
COPY_TO_FRONTEND=${4:-false}

echo "🔧 Starting TypeScript type generation..."

# Determine configuration file to use
if [ -n "$CONFIG_FILE" ]; then
    NSWAG_CONFIG="$CONFIG_FILE"
elif [ -f "src/Web.Api/nswag.local.json" ]; then
    NSWAG_CONFIG="nswag.local.json"
    echo "📋 Using local configuration: nswag.local.json"
else
    NSWAG_CONFIG="nswag.json"
    echo "📋 Using default configuration: nswag.json"
fi

# Check for environment variable for output path
if [ -z "$OUTPUT_PATH" ] && [ -n "$FRONTEND_TYPES_PATH" ]; then
    OUTPUT_PATH="$FRONTEND_TYPES_PATH"
    echo "🌍 Using environment variable FRONTEND_TYPES_PATH: $OUTPUT_PATH"
fi

# Change to Web.Api directory
cd src/Web.Api

# Build the project first
echo "📦 Building the Web.Api project..."
dotnet build --configuration Debug

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please fix build errors before generating types."
    exit 1
fi

# Generate TypeScript types using NSwag
echo "🚀 Generating TypeScript types..."
dotnet tool restore

# Temporarily modify output path if specified
if [ -n "$OUTPUT_PATH" ]; then
    echo "📝 Temporarily updating output path to: $OUTPUT_PATH"
    # Create temporary config with modified output path
    TEMP_CONFIG="nswag.temp.json"
    jq --arg output "$OUTPUT_PATH" '.codeGenerators.openApiToTypeScriptClient.output = $output' "$NSWAG_CONFIG" > "$TEMP_CONFIG"
    NSWAG_CONFIG="$TEMP_CONFIG"
fi

dotnet nswag run "$NSWAG_CONFIG"

if [ $? -eq 0 ]; then
    echo "✅ TypeScript types generated successfully!"
    
    if [ -n "$OUTPUT_PATH" ]; then
        echo "📁 Generated to: $OUTPUT_PATH"
    else
        echo "📁 Generated to default location (check nswag.json output setting)"
    fi
    
    if [ "$COPY_TO_FRONTEND" = "true" ] && [ -n "$FRONTEND_REPO_PATH" ]; then
        FRONTEND_TYPES_PATH="$FRONTEND_REPO_PATH/src/types/api-types.ts"
        echo "📋 Copying to frontend: $FRONTEND_TYPES_PATH"
        cp "${OUTPUT_PATH:-./generated/api-types.ts}" "$FRONTEND_TYPES_PATH"
        echo "✅ Copied to frontend successfully!"
    fi
    
    echo "🎉 Generation complete!"
else
    echo "❌ Type generation failed. Check the output above for errors."
    exit 1
fi

# Clean up temporary config file
if [ -n "$OUTPUT_PATH" ] && [ -f "nswag.temp.json" ]; then
    rm "nswag.temp.json"
fi

# Return to root directory
cd ../..
