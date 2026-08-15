#!/bin/bash

py_versions=("3.11.15" "3.12.13" "3.13.15" "3.14.6")

# Array to store the results (pass or fail)
results=()

# Using pure text Unicode symbols (✓ and ✗)
# '38;5;46' is neon green, '38;5;196' is bright red. '1;' makes it bold.
GREEN_CHECK="\033[1;38;5;46m✓\033[0m"
RED_CROSS="\033[1;38;5;196m✗\033[0m"

# Verify that the current directory is correct before proceeding
if [ "$(basename "$PWD")" != "SpreadSheetDiff" ] || [ ! -d "spreadsheetdiff" ]; then
    echo "Error: Not in the SpreadSheetDiff directory. Exiting..."
    exit 1
fi

# Iterate over each Python version in the array
for py_version in "${py_versions[@]}"; do
    echo "================================================="
    echo "Starting installation for Python $py_version..."
    echo "================================================="

    # Remove the existing environment if it exists
    # '|| true' prevents early exit if the environment does not exist
    mamba remove -n ssd --all --yes || true

    # forcefully remove the environment directory to prevent 'prefix already exists'
    MAMBA_BASE=$(mamba info --base 2>/dev/null)
    if [ -n "$MAMBA_BASE" ] && [ -d "$MAMBA_BASE/envs/ssd" ]; then
        rm -rf "$MAMBA_BASE/envs/ssd"
    fi

    # 3. Hardcoded absolute fallback based on your specific error output
    if [ -d "$HOME/anaconda3/envs/ssd" ]; then
        rm -rf "$HOME/anaconda3/envs/ssd"
    fi

    # Flag to track if the current installation is successful
    success=true

    # Attempt to create the environment
    if ! mamba create -c conda-forge -n ssd pip python=="$py_version" --yes; then
        success=false
    fi

    # Attempt to install the package if environment creation succeeded
    if [ "$success" = true ]; then
        if ! mamba run -n ssd pip install .; then
            success=false
        fi
    fi

    # Record the final status for this version
    if [ "$success" = true ]; then
        results+=("$GREEN_CHECK")
    else
        results+=("$RED_CROSS")
    fi
done

# Print the ASCII summary table
echo ""
echo "+----------------+--------+"
echo "| Python Version | Status |"
echo "+----------------+--------+"

# Loop through the array indices to print the rows
for i in "${!py_versions[@]}"; do
    # Print the version padded to 14 characters and the corresponding status symbol
    printf "| %-14s |   %b    |\n" "${py_versions[$i]}" "${results[$i]}"
done

echo "+----------------+--------+"
