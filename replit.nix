{ pkgs }: {
  deps = [
    pkgs.python311Packages.mkdocs
    pkgs.jellyfin-ffmpeg
    pkgs.firebase-tools
    pkgs.cowsay
  ];
}