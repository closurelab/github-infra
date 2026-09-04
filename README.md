# closurelab GitHub infrastructure

This repository is the source of truth for the `closurelab` GitHub
organization. It uses [OpenTofu](https://opentofu.org/) and the
[GitHub provider](https://github.com/integrations/terraform-provider-github) to
declare repositories and their shared settings as code.

The current configuration manages:

- the `github-infra` repository;
- its standard issue labels;
- whether GitHub Projects and the wiki are enabled; and
- optionally, its default branch when explicitly enabled.

OpenTofu is the community-driven infrastructure-as-code tool descended from
Terraform. You describe the desired result in `.tf` files, OpenTofu compares
that description with GitHub, and then it shows or applies the difference.

## Project layout

```text
.
├── github-org.tf                 # Composes the organization from repo modules
├── providers.tf                  # Configures the closurelab GitHub provider
├── versions.tf                   # Pins OpenTofu and provider versions
├── .terraform.lock.hcl           # Locks the selected provider build
├── Justfile                      # Short, documented operator commands
├── repos/
│   └── github-infra/
│       └── main.tf               # Declares the real github-infra repository
├── policies/
│   ├── repository/               # Shared repository resource and defaults
│   ├── labels/                   # Standard label names, descriptions, colors
│   └── commit-prefixes/          # Checks labels against .gitlint prefixes
├── nix/
│   ├── dev-shell.nix             # OpenTofu development environment
│   └── pre-commit.nix            # Formatting, validation, and lint hooks
├── flake.nix                     # Nix development shell and checks
├── .gitlint                      # Allowed commit prefixes
└── AGENTS.md                     # Rules for automated contributors
```

The main composition file is `github-org.tf`. It adds each repository module
under `repos/` to the organization:

```hcl
module "github_infra" {
  source = "./repos/github-infra"

  providers = {
    github = github
  }
}
```

There is no special file that OpenTofu executes first. It loads all `.tf` files
in the project root as one **root module**. Splitting that module into
`github-org.tf`, `providers.tf`, and `versions.tf` is for clarity.

Each directory directly under `repos/` represents one real GitHub repository.
Its `main.tf` calls the shared `policies/repository` module. The shared policy
creates the repository, applies the standard labels, and can manage its default
branch when explicitly requested.

The repository policy defaults are:

| Setting                          | Default     |
| -------------------------------- | ----------- |
| Visibility                       | `private`   |
| Default branch                   | `master`    |
| Manage repository default branch | disabled    |
| GitHub Projects                  | disabled    |
| Wiki                             | disabled    |
| Pull request merge method        | squash only |
| Delete branch after merge        | enabled     |

A repository can override any of these defaults in its own module.

## Important OpenTofu concepts

### Configuration

The tracked `.tf` files describe the desired GitHub configuration. Edit these
files instead of making the same changes manually in GitHub.

### Plan

`tofu plan` compares the configuration, OpenTofu's state, and the current
GitHub settings. It previews what would change but does not change GitHub.

The most common plan markers are:

| Marker | Meaning             |
| ------ | ------------------- |
| `+`    | create              |
| `~`    | update in place     |
| `-`    | destroy             |
| `-/+`  | destroy and replace |

Read the entire plan, especially any destroy or replacement action.

### Apply

`tofu apply` changes GitHub to match the reviewed plan. Unlike `plan`, this is
a real infrastructure mutation. Do not run it merely to test configuration.

### State

State records the connection between resources in these files and objects on
GitHub. This project currently uses local state, stored in
`terraform.tfstate` after the first apply.

The state file is ignored by Git because it can contain sensitive data. It is
also essential: do not delete it or run applies from different copies of this
repository with unrelated state. Configure a shared remote state backend before
multiple people or automation begin applying changes.

State is different from these generated files:

- `.terraform.lock.hcl` selects a compatible provider build and is committed;
- `.terraform/` caches initialized modules and providers and is ignored; and
- `*.tfplan` contains a saved plan and is ignored.

Saved plans and state files can contain sensitive values. Do not share or
commit them.

## First-time setup

You need Git and [Nix with flakes enabled](https://nixos.wiki/wiki/Flakes).
The Nix development shell supplies the compatible `tofu` executable, GitHub
provider, GitHub CLI (`gh`), command runner (`just`), formatters, and Git hooks.

Enter the development shell from the repository root:

```console
$ nix develop
```

If you use direnv, the checked-in `.envrc` can enter it automatically:

```console
$ direnv allow
```

The development shell installs the repository's pre-commit hooks. It does not
authenticate you to GitHub.

### Authenticate to GitHub

The provider is configured to manage the `closurelab` organization. Authenticate
with a GitHub account or app that has enough organization and repository
permissions for the proposed operations.

The development shell includes the GitHub CLI, and the provider can use its
authenticated session:

```console
$ gh auth login
$ gh auth status
```

Alternatively, provide a token through the environment:

```console
$ export GITHUB_TOKEN="..."
```

Never put a token in a `.tf` file or commit it to Git.

### Initialize the working directory

Run this after cloning the repository and whenever OpenTofu says the provider,
module, or backend configuration has changed:

```console
$ tofu init
```

Initialization creates the ignored `.terraform/` cache. It is safe to run
`tofu init` repeatedly.

Run `just` to list the project-specific convenience commands:

```console
$ just
Available recipes:
    default
    import $repository # Import an existing repository and its authoritative labels into OpenTofu state.
```

## Importing an existing repository

Import binds an existing GitHub object to its address in OpenTofu state. It
does not create or modify the GitHub repository, but it does change the state.

The `just import` recipe imports both the repository and its authoritative label
set. For example:

```console
$ just import github-infra
```

The recipe expects `repos/github-infra/main.tf` to exist and maps the repository
name `github-infra` to the root module name `github_infra`. It safely skips each
resource that is already present in state, so it can resume a partial import.

After importing, always inspect the proposed reconciliation:

```console
$ tofu state list
$ tofu plan
```

Do not apply until every proposed change is understood. In particular, the
label resource is authoritative and may propose removing unmanaged labels.

## Routine workflow

1. Enter the development shell.

   ```console
   $ nix develop
   ```

1. Edit the appropriate repository or policy files.

1. Format and validate the OpenTofu configuration.

   ```console
   $ tofu fmt -recursive
   $ tofu validate
   ```

1. Preview the proposed GitHub changes.

   ```console
   $ tofu plan
   ```

   Planning is read-only. Check that the organization is `closurelab`, the
   resource names are correct, and no unexpected resources will be destroyed
   or replaced.

1. Stage every intended file before evaluating the Nix flake.

   ```console
   $ git add README.md path/to/changed-file.tf
   $ nix flake check
   ```

   Git-backed flakes omit untracked files. Never work around this with a
   `path:` or `path://` flake URL: doing so can copy large ignored or untracked
   files into the Nix store.

1. Review and commit the staged diff.

   ```console
   $ git diff --cached
   $ git commit -m 'infra: describe the change.'
   ```

Running a plan is safe and does not require an apply. Stop after the plan when
you only want to inspect a change.

## Applying a reviewed change

An apply changes the live GitHub organization. Only apply when you intend to
make the proposed changes and have the correct state file.

For an explicit plan-then-apply workflow:

```console
$ tofu plan -out=github-infra.tfplan
$ tofu apply github-infra.tfplan
```

Passing a saved plan to `tofu apply` is itself approval to execute that exact
plan, so OpenTofu does not ask for another confirmation. Avoid
`-auto-approve`, and delete the local plan file when it is no longer needed.

Automated agents may run read-only commands such as `tofu plan`. They must not
run `apply`, `destroy`, imports, or other state-changing commands without an
explicit instruction.

## Adding a repository

Suppose the new GitHub repository should be named `example`.

1. Create `repos/example/main.tf`:

   ```hcl
   terraform {
     required_providers {
       github = {
         source = "integrations/github"
       }
     }
   }

   module "repository" {
     source = "../../policies/repository"

     name        = "example"
     description = "What this repository is for."

     providers = {
       github = github
     }
   }
   ```

1. Compose it from `github-org.tf`:

   ```hcl
   module "example" {
     source = "./repos/example"

     providers = {
       github = github
     }
   }
   ```

1. Run formatting, validation, and `tofu plan`. A normal new-repository plan
   should propose creations, not changes to unrelated repositories.

The directory name, module name, and `name` value should all clearly correspond
to the real repository. Only real repositories belong under `repos/`; reusable
logic belongs under `policies/`.

### Overriding defaults

Set an override in the repository's call to `policies/repository`. For example:

```hcl
module "repository" {
  source = "../../policies/repository"

  name         = "example"
  description  = "A public repository with its wiki enabled."
  visibility   = "public"
  has_wiki     = true
  has_projects = false

  providers = {
    github = github
  }
}
```

Available inputs are documented in `policies/repository/variables.tf`. Keep an
override only when the repository intentionally differs from organization
policy.

### Pull request merge policy

Repositories permit squash merges only. Merge commits and rebase merges are
disabled, making squash the effective merge default and keeping merges made
through GitHub pull requests linear. GitHub automatically deletes the pull
request's head branch after it is merged.

Each setting can be overridden for an exceptional repository with
`allow_merge_commit`, `allow_rebase_merge`, `allow_squash_merge`, or
`delete_branch_on_merge`.

This repository-level policy controls GitHub's pull request merge methods. It
does not prevent someone with direct push access from pushing a locally created
merge commit; strict enforcement against direct pushes requires a branch rule
that requires linear history.

### Default branch policy

The organization-wide default branch for newly created repositories has been
manually set to `master`. The GitHub provider can read that organization
setting, but cannot manage it declaratively.

Repository-level default-branch management is therefore disabled by default.
New repositories inherit the organization setting when their first branch is
created. To make an explicit exception for an existing repository and branch,
set these inputs in its repository module:

```hcl
default_branch        = "some-existing-branch"
manage_default_branch = true
```

GitHub cannot select a branch that does not exist. Create or push the branch
before enabling this override.

## Labels and commit prefixes

The standard labels correspond to the allowed commit prefixes in `.gitlint`:
`chore`, `doc`, `fix`, `feat`, `infra`, `refac`, and `revert`.

`policies/labels` defines their descriptions and color-blind-friendly colors.
`policies/commit-prefixes` checks that those label names remain synchronized
with `.gitlint`. The repository policy manages this set authoritatively, so a
plan may remove unmanaged labels from a managed repository.

When adding or renaming a prefix, update both `.gitlint` and
`policies/labels/main.tf`, then inspect the plan carefully.

## Useful commands

| Command               | Purpose                              | Changes GitHub? |
| --------------------- | ------------------------------------ | --------------- |
| `tofu fmt -recursive` | Format all OpenTofu files            | No              |
| `tofu validate`       | Check configuration structure        | No              |
| `tofu plan`           | Preview drift and proposed changes   | No              |
| `tofu show`           | Inspect current state                | No              |
| `tofu state list`     | List state-managed resources         | No              |
| `just import <repo>`  | Import a repository and its labels   | State only      |
| `tofu apply`          | Apply proposed changes               | **Yes**         |
| `tofu destroy`        | Propose and remove managed resources | **Yes**         |
| `nix flake check`     | Run all repository checks            | No              |

Use `tofu destroy` with extreme care: for this project it can delete GitHub
repositories and their contents.

For more detail, see the official OpenTofu documentation for
[`init`](https://opentofu.org/docs/cli/init/),
[`plan`](https://opentofu.org/docs/cli/commands/plan/), and
[`apply`](https://opentofu.org/docs/cli/commands/apply/).
