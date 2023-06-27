{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      perSystem = {pkgs, ...}: {
        packages = let
          version = "0.2.0";

          sf-pro-src = {
            url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
            hash = "sha256-WG0nLn/Giiv0DT8zUwTiWuv/I23RqMSxJsGUbrQzCqc=";
          };
          sf-compact-src = {
            url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
            hash = "sha256-uMGSFvqAfTdUWhNE6D6RyLKCrt4VXrUNZppvTHM7Igg=";
          };
          sf-mono-src = {
            url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
            hash = "sha256-pqkYgJZttKKHqTYobBUjud0fW79dS5tdzYJ23we9TW4=";
          };
          sf-arabic-src = {
            url = "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg";
            hash = "sha256-V5JgeM13NUMnRFa0Xb90eo3jAq3hYYsek+1gCiIfFF4=";
          };
          ny-src = {
            url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
            hash = "sha256-XOiWc4c7Yah+mM7axk8g1gY12vXamQF78Keqd3/0/cE=";
          };

          makeAppleFont = pname: pkgName: src:
            pkgs.stdenv.mkDerivation {
              inherit pname src version;

              unpackPhase = ''
                undmg $src
                7z x '${pkgName}'
                7z x 'Payload~'
              '';

              buildInputs = [pkgs.p7zip pkgs.undmg];
              setSourceRoot = "sourceRoot=`pwd`";

              installPhase = ''
                mkdir -p $out/share/fonts
                mkdir -p $out/share/fonts/opentype
                mkdir -p $out/share/fonts/truetype
                find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
                find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
              '';
            };
        in {
          sf-pro = makeAppleFont "sf-pro" "SF Pro Fonts.pkg" (pkgs.fetchurl sf-pro-src);
          sf-compact = makeAppleFont "sf-compact" "SF Compact Fonts.pkg" (pkgs.fetchurl sf-compact-src);
          sf-mono = makeAppleFont "sf-mono" "SF Mono Fonts.pkg" (pkgs.fetchurl sf-mono-src);
          sf-arabic = makeAppleFont "sf-arabic" "SF Arabic Fonts.pkg" (pkgs.fetchurl sf-arabic-src);
          ny = makeAppleFont "ny" "NY Fonts.pkg" (pkgs.fetchurl ny-src);
        };
      };
    };
}
