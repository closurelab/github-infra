{
  pkgsFor,
  preCommitFor,
}:

{ system }:

let
  pkgs = pkgsFor { inherit system; };
  preCommit = preCommitFor { inherit pkgs; };
in
pkgs.mkShell {
  name = "github-infra-dev";

  packages = [ pkgs.opentofu ] ++ preCommit.enabledPackages;

  inherit (preCommit) shellHook;
}
