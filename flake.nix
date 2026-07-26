{
  description = "Codex-only Virtual Monorepo";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      version = "0.3.1";
      release = {
        x86_64-linux = {
          platform = "linux_amd64";
          hash = "sha256-/ObbPEeox7bNV1VYAgJNXdeyJ3JwOp5yivLYJkyTgvE=";
        };
        aarch64-linux = {
          platform = "linux_arm64";
          hash = "sha256-fnY9Q7gvyvPp8F/5IFM9h4XUOVlKrBOkJ8W+gFOItwc=";
        };
        x86_64-darwin = {
          platform = "darwin_amd64";
          hash = "sha256-3jVuvrCCKulA5gmIkRpYM7sZ6pNzrqVHSw9y+G8ASM4=";
        };
        aarch64-darwin = {
          platform = "darwin_arm64";
          hash = "sha256-lSHsqDm8wXjVYO7HLR3CJmnrLKf1QMrNEJR6LZITBeA=";
        };
      };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          asset = release.${system};
          vmr = pkgs.stdenvNoCC.mkDerivation {
            pname = "vmr";
            inherit version;

            src = pkgs.fetchurl {
              url = "https://github.com/uta8a/vmr/releases/download/v${version}/vmr_${version}_${asset.platform}.tar.gz";
              inherit (asset) hash;
            };

            sourceRoot = ".";

            installPhase = ''
              runHook preInstall
              install -Dm755 vmr "$out/bin/vmr"
              runHook postInstall
            '';

            meta = {
              description = "Virtual Monorepo control plane";
              homepage = "https://github.com/uta8a/vmr";
              license = pkgs.lib.licenses.mit;
              mainProgram = "vmr";
              platforms = supportedSystems;
            };
          };
        in
        {
          inherit vmr;
          default = vmr;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              self.packages.${system}.vmr
              pkgs.git
              pkgs.gh
              pkgs.python3
              pkgs.python3Packages.pyyaml
              pkgs.ripgrep
            ];
          };
        }
      );

      checks = forAllSystems (system: {
        inherit (self.packages.${system}) vmr;
      });
    };
}
