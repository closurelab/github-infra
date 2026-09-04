{
  git-hooks,
  src,
}:

{ pkgs }:

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

    # OpenTofu/HCL
    terraform-format = {
      enable = true;
      files = "\\.tf(vars)?$";
    };
    terraform-validate.enable = true;
  };
}
