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

          unpackPhase = pkgName: ''
            undmg $src
            7z x '${pkgName}'
            7z x 'Payload~'
          '';
          commonInstall = ''
            mkdir -p $out/share/fonts
            mkdir -p $out/share/fonts/opentype
            mkdir -p $out/share/fonts/truetype
          '';
          commonBuildInputs = with pkgs; [undmg p7zip];
          makeAppleFont = name: pkgName: src:
            pkgs.stdenv.mkDerivation {
              inherit name src version;

              unpackPhase = unpackPhase pkgName;

              buildInputs = commonBuildInputs;
              setSourceRoot = "sourceRoot=`pwd`";

              installPhase =
                commonInstall
                + ''
                  find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
                  find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
                '';
            };
          makeNerdAppleFont = name: pkgName: src:
            pkgs.stdenv.mkDerivation {
              inherit name src;

              unpackPhase = unpackPhase pkgName;

              buildInputs = with pkgs;
                commonBuildInputs ++ [parallel nerd-font-patcher];
              setSourceRoot = "sourceRoot=`pwd`";

              buildPhase = ''
                find -name \*.ttf -o -name \*.otf -print0 | parallel -j $NIX_BUILD_CORES -0 nerd-font-patcher -c {}
              '';

              installPhase =
                commonInstall
                + ''
                  find -name \*.otf -maxdepth 1 -exec mv {} $out/share/fonts/opentype/ \;
                  find -name \*.ttf -maxdepth 1 -exec mv {} $out/share/fonts/truetype/ \;
                '';
            };
        in {
          sf-pro = makeAppleFont "sf-pro" "SF Pro Fonts.pkg" (pkgs.fetchurl sf-pro-src);
          sf-pro-nerd = makeNerdAppleFont "sf-pro-nerd" "SF Pro Fonts.pkg" (pkgs.fetchurl sf-pro-src);

          sf-compact = makeAppleFont "sf-compact" "SF Compact Fonts.pkg" (pkgs.fetchurl sf-compact-src);
          sf-compact-nerd = makeNerdAppleFont "sf-compact-nerd" "SF Compact Fonts.pkg" (pkgs.fetchurl sf-compact-src);

          sf-mono = makeAppleFont "sf-mono" "SF Mono Fonts.pkg" (pkgs.fetchurl sf-mono-src);
          sf-mono-nerd = makeNerdAppleFont "sf-mono-nerd" "SF Mono Fonts.pkg" (pkgs.fetchurl sf-mono-src);

          sf-arabic = makeAppleFont "sf-arabic" "SF Arabic Fonts.pkg" (pkgs.fetchurl sf-arabic-src);
          sf-arabic-nerd = makeNerdAppleFont "sf-arabic-nerd" "SF Arabic Fonts.pkg" (pkgs.fetchurl sf-arabic-src);

          ny = makeAppleFont "ny" "NY Fonts.pkg" (pkgs.fetchurl ny-src);
          ny-nerd = makeNerdAppleFont "ny-nerd" "NY Fonts.pkg" (pkgs.fetchurl ny-src);
        };
      };
    };
}
