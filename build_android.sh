#!/bin/bash

# Build script for Android with improved error handling and architecture support

set -e

# Function to check Application.mk
check_application_mk() {
    if [ ! -f "Application.mk" ]; then
        echo "Error: Application.mk not found!"
        exit 1
    fi
}

# Function to build for a specific architecture
build_for_arch() {
    local arch=$1
    echo "Building for architecture: $arch"
    # Add build command here (example: ndk-build APP_ABI=$arch)
}

# Main script execution

# Check if Application.mk exists
check_application_mk

# Verify specified architectures (e.g., arm64-v8a, armeabi-v7a, x86)
architectures=(arm64-v8a armeabi-v7a x86)

# Create output directory
output_dir="build_output"
mkdir -p $output_dir

# Build for each architecture
for arch in "${architectures[@]}"; do
    build_for_arch $arch > "$output_dir/build_$arch.log" 2>&1
    if [ $? -ne 0 ]; then
        echo "Build failed for architecture: $arch. Check log: $output_dir/build_$arch.log"
        exit 1
    fi
    echo "Build successful for architecture: $arch"
done

echo "All builds completed successfully!"