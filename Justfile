default:
    @just --list

# Create a pull request using the first commit for its title and body.
pr:
    gh pr create --fill-first

# Import an existing repository and its authoritative labels into OpenTofu state.
import $repository:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ ! "$repository" =~ ^[A-Za-z0-9._-]+$ ]]; then
      echo "Invalid GitHub repository name: $repository" >&2
      exit 2
    fi

    if [[ ! -f "repos/$repository.json" ]]; then
      echo "No repository descriptor found at repos/$repository.json" >&2
      exit 2
    fi

    repository_address="module.repositories[\"$repository\"].github_repository.this"
    labels_address="module.repositories[\"$repository\"].github_issue_labels.this"

    import_if_missing() {
      local address="$1"

      if tofu state show "$address" >/dev/null 2>&1; then
        echo "Already tracked: $address"
      else
        tofu import "$address" "$repository"
      fi
    }

    import_if_missing "$repository_address"
    import_if_missing "$labels_address"

    echo "Import complete. Review the result with: tofu plan"
