{
  pkgsFor,
  preCommitFor,
}:

{ system }:

let
  pkgs = pkgsFor { inherit system; };
  preCommit = preCommitFor { inherit pkgs; };
  tofu = pkgs.opentofu.withPlugins (providers: [ providers.integrations_github ]);
in
pkgs.mkShell {
  name = "github-infra-dev";

  packages = [ tofu ] ++ preCommit.enabledPackages;

  inherit (preCommit) shellHook;
}
