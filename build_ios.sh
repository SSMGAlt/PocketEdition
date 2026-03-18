#!/bin/bash

# Get the SDK version
SDK_VERSION=$(xcrun -sdk iphoneos --show-sdk-version)

# Check for armv7 support
if [[ $SDK_VERSION < "7.0" ]]; then
    echo "The SDK version is not supported for armv7 architecture."
    exit 1
fi

# Build for simulator and device
if [ "$1" == "sim" ]; then
    xcodebuild -project YourProject.xcodeproj -scheme YourScheme -sdk iphonesimulator -arch x86_64 build
else
    xcodebuild -project YourProject.xcodeproj -scheme YourScheme -sdk iphoneos -arch armv7 build
fi
