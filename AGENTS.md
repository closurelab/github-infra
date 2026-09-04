# AGENTS.md

## Purpose

`github-infra` is the source of truth for declaratively managing the
`closurelab` GitHub organization with OpenTofu and the GitHub provider.

The current scope is the organization's repositories, their labels, and
explicit per-repository default-branch overrides.

## Nix workflow

- Always stage every intended flake input with Git before evaluating the
  flake. Git-backed flakes do not include untracked files.
- Run flake commands against the repository's Git-backed flake, such as
  `nix flake check` from the repository root.
- Never use a `path:` or `path://` flake URL. Path-backed flakes can copy large
  untracked or ignored files into the Nix store and waste substantial space.
- Use the `system` package-set attribute. This project does not cross-compile.

## OpenTofu

- Use `tofu`, not `terraform`, for all infrastructure commands.
- Declare managed GitHub settings in OpenTofu. Do not make equivalent ad hoc
  changes with the GitHub UI, `gh`, or direct API calls.
- Keep repository resources, labels, and any explicit default-branch overrides
  in the declarative configuration.
- Agents may run read-only OpenTofu commands, including `tofu plan`, without
  confirmation.
- Never run `tofu apply`, `tofu destroy`, `tofu import`, state-changing
  commands, or equivalent infrastructure mutations without explicit user
  instructions.

## Repository defaults

- The organization-wide default branch for new repositories is manually set to
  `master`. The GitHub provider cannot manage that organization setting.

- Do not manage a repository's default branch by default. Set
  `manage_default_branch = true` only when an explicit per-repository override
  is required and the target branch already exists.

- Disable GitHub Projects and the wiki by default. Declare any exception
  explicitly in the repository configuration.

- Permit squash merging only: enable squash merges and disable merge commits
  and rebase merges. This makes squash the effective default and keeps pull
  request merges linear.

- Delete pull request head branches automatically after merging.

- The allowed commit prefixes in `.gitlint` are the source of truth for the
  standard repository labels. Manage that label set authoritatively.

- Use this color-blind-friendly label palette, expressed as six-character hex
  values without `#`:

  | Label    | Color    |
  | -------- | -------- |
  | `chore`  | `000000` |
  | `doc`    | `56B4E9` |
  | `fix`    | `D55E00` |
  | `feat`   | `009E73` |
  | `infra`  | `0072B2` |
  | `refac`  | `CC79A7` |
  | `revert` | `E69F00` |

## Quality

- Use `nix develop` for the project toolchain and Git hooks.
- Run the narrowest relevant check first, then `nix flake check` before
  finishing a change. Stage intended flake inputs before either evaluation.
- Use the configured hooks to format and validate Nix, Markdown, and OpenTofu
  files and to lint commit messages.
- Commit titles must be at most 72 characters, end in a period, and match
  `^(chore|doc|fix|feat|infra|refac|revert): .+\.$`.
- Report what passed and anything that could not run.
