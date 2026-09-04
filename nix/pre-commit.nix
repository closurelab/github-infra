{
  git-hooks,
  src,
}:

{ pkgs }:

let
  tofu = pkgs.opentofu.withPlugins (providers: [ providers.integrations_github ]);
in
git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
  inherit src;

  hooks = {
    # Nix
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;

    # Commit messages
    gitlint.enable = true;

    # Markdown
    mdformat = {
      package = pkgs.mdformat.withPlugins (
        ps: with ps; [
          mdformat-myst
          mdformat-gfm
        ]
      );
      enable = true;
    };

    # JSON
    pretty-format-json = {
      enable = true;
      files = "^repos/[^/]+\\.json$";
      settings = {
        autofix = true;
        indent = 2;
      };
    };

    # Just
    just-format = {
      enable = true;
      entry = "${pkgs.just}/bin/just --fmt --check";
      files = "(^|/)Justfile$";
      pass_filenames = false;
    };

    # OpenTofu/HCL
    terraform-format = {
      enable = true;
      files = "\\.tf(vars)?$";
      package = tofu;
    };
    terraform-validate = {
      enable = true;
      package = tofu;
    };
  };
}
