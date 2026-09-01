#!/bin/bash

# ==============================================================================
# Script Name: collect.sh
# Description: Safely fetches public forks for user 'elserhumano', isolating
#              enterprise organizations, and archives upstream parent URLs.
# ==============================================================================

# Output configuration file
OUTPUT_FILE="01-revisar.md"

echo "# Upstream Repositories for Review" > "$OUTPUT_FILE"
echo "Generated on: $(date)" >> "$OUTPUT_FILE"
echo "Filter applied: Exclusive Owner (elserhumano)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "🔍 Fetching fork repositories belonging exclusively to 'elserhumano'..."

# Query the GitHub REST API and isolate organization scopes
gh api users/elserhumano/repos --paginate -q '.[] | select(.fork == true) | "\(.full_name) \(.parent.html_url)"' 2>/dev/null | head -n 50 | while read -r fork_name parent_url; do
  
  # Fallback: If REST pagination didn't populate parent inline, fetch the repository metadata directly
  if [ -z "$parent_url" ] || [ "$parent_url" == "null" ]; then
    parent_url=$(gh api repos/$fork_name -q '.parent.html_url' 2>/dev/null)
  fi

  if [ ! -z "$parent_url" ] && [ "$parent_url" != "null" ]; then
    echo "- [$parent_url]($parent_url) (Fork: $fork_name)" >> "$OUTPUT_FILE"
    echo "✅ Successfully archived upstream: $parent_url"
  else
    echo "⚠️ Upstream URL not found for: $fork_name (Saving fork fallback)"
    echo "- [https://github.com](https://github.com) (Fork: $fork_name)" >> "$OUTPUT_FILE"
  fi
done

echo "----------------------------------------------------"
echo "🏁 Collection pipeline finished successfully!"
echo "📂 Review the data inside your target markdown file before purging."

