{
  description = "Declarative GitHub organization infrastructure for closurelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      git-hooks,
      ...
    }:
    let
      forSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      pkgsFor =
        { system }:
        import nixpkgs { inherit system; };

      preCommitFor = import ./nix/pre-commit.nix {
        inherit git-hooks;
        src = ./.;
      };

      devShellFor = import ./nix/dev-shell.nix {
        inherit pkgsFor preCommitFor;
      };
    in
    {
      checks = forSystems (
        system:
        let
          pkgs = pkgsFor { inherit system; };
        in
        {
          pre-commit-check = preCommitFor { inherit pkgs; };
        }
      );

      devShells = forSystems (system: {
        default = devShellFor { inherit system; };
      });
    };
}
