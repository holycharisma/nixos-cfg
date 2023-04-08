{ stdenv
, lib
, fetchFromGitHub
, bash
, makeWrapper
}:
stdenv.mkDerivation {
  pname = "emojify";
  version = "6dc2c1d";
  src = fetchFromGitHub {
    # https://github.com/mrowa44/emojify 
    owner = "mrowa44";
    repo = "emojify";
    rev = "6dc2c1df9a484cf01e7f48e25a1e36e328c32816";
    sha256 = "sha256-6cV+S8wTqJxPGsxiJ3hP6/CYPMWdF3qnz4ddL+F/oJU=";
  };
  buildInputs = [ bash ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp emojify $out/bin/emojify
    wrapProgram $out/bin/emojify \
      --prefix PATH : ${lib.makeBinPath [ bash ]}
  '';
}
