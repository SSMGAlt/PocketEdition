# Minecraft: Pocket Edition (2013 Source Code Archive)

This repository contains the archived source code for a 2013 version of Minecraft: Pocket Edition. The source code comes from the February 28th, 2026 Minecraft LCE source code leak. It includes platform-specific code for both Android and iOS, offering a historical snapshot of the game's development during that era.

> [!NOTE]
> From now on, i will accept pull requests aiming to improve the code, as long as they are correct, and thourough.

## Current State
*   **Core Source Code:** Present, covering the main game logic (`/handheld` directory).
*   **Platform Support:** Contains both Android and iOS specific code.
*   **Build System:** Basic build scripts are provided, but are a **work in progress (WIP)**.
*   **CIs:** Initial CI configuration is present (`.github/workflows/debug.yml`) but is also a **WIP** and may not successfully build the project.

## Getting Started

Attempting to build this project requires setting up a legacy development environment. The instructions below are basic and do not guarantee a path to a working binary.

### Prerequisites

The exact toolchain versions from 2013 are ideal but may be difficult to obtain. You will likely need:

*   **For Android:**
    *   A legacy Android SDK (recommended: API 14 to 19, check source for better info)
    *   A legacy Android NDK. (recommended: r9 or r10, check source for better info)
    *   Apache Ant for building.
*   **For iOS:**
    *   A macOS system with an older version of Xcode (e.g., Xcode 4 or 5) capable of targeting iOS 6 or 7.
    *   The iOS SDKs that shipped with that Xcode version.

### Building

The root of the repository contains platform-specific build scripts. These scripts are the primary entry point for attempting a build.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/SSMGAlt/PocketEdition.git
    cd PocketEdition
    ```

2.  **Attempt an Android build:**
    The `build_android.sh` script is intended to initiate the Android build process. You may need to edit it to set the correct paths for your legacy Android SDK/NDK.
    ```bash
    # Make the script executable
    chmod +x build_android.sh
    # Run the script (expect errors related to the WIP build system)
    ./build_android.sh
    ```

3.  **Attempt an iOS build:**
    Similarly, `build_ios.sh` is provided for iOS. This would typically need to be run on a macOS system with the legacy Xcode environment configured.
    ```bash
    chmod +x build_ios.sh
    ./build_ios.sh
    ```

> [!NOTE]
> These build scripts are not yet complete. They represent the initial structure and will likely fail due to unresolved paths, missing dependencies, or incomplete build configurations. Contributions to fix and complete the build process are welcome.
> And please read the instructions inside the build scripts, it will save you a bit of time.

## Repository Structure

A brief overview of the key directories:

*   `/handheld`: The main source code for the game, shared across platforms. This is where the core C++ game logic resides.
*   `/docs`: Contains documentation files from the original source archive.
*   `/tools`: Likely contains helper tools or utilities used in the development or build process (e.g., for data processing).
*   `/.github/workflows`: Contains GitHub Actions CI workflow definitions, which are currently a work in progress.
*   `build_android.sh` / `build_ios.sh`: Shell scripts intended to orchestrate the platform-specific builds.

## Contributing

Contributions are focused on the archival and restoration effort. Specifically, help is needed with:

*   **Fixing the Build System:** Correcting paths, dependencies, and script logic to make the project buildable with legacy toolchains.
*   **Improving CI:** Configuring the GitHub Actions workflows to successfully build the project in a CI environment (if possible with legacy dependencies).
*   **Documentation:** Adding information about the code structure, dependencies, and known issues.

If you choose to contribute, please base your work on the main branch and clearly describe the changes you have made.

## Legal Notice

I am not responsible for any damages you cause with this source code. This repository is only an archive of the source.
