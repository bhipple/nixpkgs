{ lib, rustPlatform, fetchFromGitHub, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "hits-of-code";
  version = "0.11.5";

  src = fetchFromGitHub {
    owner = "vbrandl";
    repo = "hoc";
    rev = "v${version}";
    sha256 = "1vsv6gfv47nh93cjjzqwh6kqfkfkjymx7swpk80lnkk99pkhbqpd";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  cargoSha256 = "00f414qqq7l65s8kr74nf06vghr2l9nqars6f7c8xc80kl8hd1bv";

  meta = with lib; {
    description = "Generate Hits-of-Code badges for GitHub repositories";
    homepage = "https://hitsofcode.com";
    license = licenses.mit;
    maintainers = with maintainers; [ vbrandl ];
  };
}
