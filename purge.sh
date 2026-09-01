#!/bin/bash

# ==============================================================================
# Script Name: purge.sh
# Description: Interactive operator-approved script that reads a markdown list
#              and batch-deletes target public forks via GitHub CLI.
# ==============================================================================

echo "===================================================="
echo "🚨 DEVOPS CONTROLLED BATCH PURGE PIPELINE 🚨"
echo "===================================================="

# List available control files in the current working directory
echo "Available reference backup files:"
ls -1 *-revisar.md 2>/dev/null
echo "----------------------------------------------------"

# Prompt the operator for target input file
read -p "📁 Enter the exact name of the file you want to process: " target_file

# Check if the file exists on the system
if [ ! -f "$target_file" ]; then
    echo "❌ Error: File '$target_file' not found in this directory."
    exit 1
fi

echo "----------------------------------------------------"
echo "Target file loaded successfully: $target_file"
echo "⚠️ WARNING: Forks contained EXCLUSIVELY in this batch will be purged."
echo "----------------------------------------------------"

# Quality Gate: Manual operator approval required
read -p "❓ Have you verified that everything is OK in '$target_file'? (y/n): " confirmation

if [[ "$confirmation" =~ ^[Yy]$ ]]; then
    echo "🚀 Initiating batch deletion workflow..."
    
    # Process only the repositories tracked inside the selected control file
    grep "(Fork:" "$target_file" | sed -n 's/.*(Fork: \(.*\))/\1/p' | while read -r repo; do
        if [ ! -z "$repo" ]; then
            echo "🔥 Deleting fork from profile: $repo"
            gh repo delete "$repo" --yes
        fi
    done
    echo "🏁 Purge operations for batch '$target_file' completed successfully!"
else
    echo "❌ Operation aborted by the operator. No infrastructure modifications were made."
fi

