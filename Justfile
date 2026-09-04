default:
    @just --list

# Import an existing repository and its authoritative labels into OpenTofu state.
import $repository:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ ! "$repository" =~ ^[A-Za-z0-9._-]+$ ]]; then
      echo "Invalid GitHub repository name: $repository" >&2
      exit 2
    fi

    if [[ ! -f "repos/$repository/main.tf" ]]; then
      echo "No repository module found at repos/$repository/main.tf" >&2
      exit 2
    fi

    module_name="${repository//-/_}"
    module_name="${module_name//./_}"
    repository_address="module.$module_name.module.repository.github_repository.this"
    labels_address="module.$module_name.module.repository.github_issue_labels.this"

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
