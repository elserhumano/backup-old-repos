# GitHub Profile Cleanup & Reference Backup

A structured DevOps automation approach to decluttering a GitHub profile by purging hundreds of old fork repositories while safely preserving their original upstream references for future reading and documentation.

## 🚀 The Problem
Having hundreds of public forks (e.g., from old courses, tutorials, or dependencies) dilutes an engineer's technical brand. It acts like an unorganized storage room rather than a professional showcase. However, destroying these forks manually takes hours, and deleting them outright causes a loss of valuable references to the upstream repositories.

## 🛠️ The Solution (DevOps Approach)
We leveraged the **GitHub CLI (`gh`)** inside a **Rocky Linux 9 (WSL2)** environment to orchestrate a safe, multi-stage cleanup pipeline:
1. **Isolated Scoping:** Filtered queries strictly to the `elserhumano` owner namespace to completely isolate and protect any corporate/enterprise organizations.
2. **Control-Led Backup:** Extracted the metadata and parent URLs of the forks using the GitHub API and batched them into 7 distinct Markdown control files (`01-revisar.md` through `07-revisar.md`).
3. **Privilege Elevation:** Upgraded the GitHub CLI authentication session dynamically with the explicit `delete_repo` scope.
4. **Interactive Batch Purging:** Developed an interactive Bash script acting as a gatekeeper. It reads a chosen control list, asks for manual confirmation (operator approval), and safely deletes the targeted forks via a programmatic loop.

---

## 📂 Backup Batches & Control Lists
The references to all original repositories were systematically divided into the following localized batch files. You can navigate through them to review the saved upstream links before or after the purge:

*   [Lote 01 - Reference List](./01-revisar.md)
*   [Lote 02 - Reference List](./02-revisar.md)
*   [Lote 03 - Reference List](./03-revisar.md)
*   [Lote 04 - Reference List](./04-revisar.md)
*   [Lote 05 - Reference List](./05-revisar.md)
*   [Lote 06 - Reference List](./06-revisar.md)
*   [Lote 07 - Reference List](./07-revisar.md)

---

## ⚙️ Core Automation Scripts

### 1. The Isolation & Extraction Engine
This script queried the GitHub REST API, isolated corporate organizations, and formatted the output into markdown lists mapping the fork to its original parent:
```bash
gh api users/elserhumano/repos --paginate -q '.[] | select(.fork == true) | "\(.full_name) \(.parent.html_url)"' | while read -r fork_name parent_url; do
  if [ -z "\(parent_url" ] \vert{}\vert{} [ "\)parent_url" == "null" ]; then
    parent_url=\$(gh api repos/\$fork_name -q '.parent.html_url' 2>/dev/null)
  fi
  echo "- [\$parent_url](\(parent_url) (Fork:\)fork_name)" >> X-revisar.md
done
```

### 2. Interactive Operator-Approved Purge Script
The defensive gatekeeper script used to process a single chosen control file after confirmation:
```bash
read -p "📁 Enter the control file to process (e.g., 01-revisar.md): " target_file
read -p "❓ Are you sure everything is OK in '\$target_file'? (y/n): " confirmation

if [[ "\(confirmation" =~ ^[Yy]\) ]]; then
    grep "(Fork:" "\$target_file" | sed -n 's/.*(Fork: .*)/\1/p' | while read -r repo; do
        gh repo delete "\$repo" --yes
    done
fi
```

---
*Maintained with 💻 inside WSL2 (Rocky Linux 9).*

