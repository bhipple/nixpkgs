{ stdenv
, fetchurl
, fetchpatch
, cmake
, pkgconfig
, hidapi
, libcbor
, openssl
, udev
}:

stdenv.mkDerivation rec {
  pname = "libfido2";
  version = "1.4.0";
  src = fetchurl {
    url = "https://developers.yubico.com/${pname}/Releases/${pname}-${version}.tar.gz";
    sha256 = "0v1a3n0qljmrp8y9pmnmbsdsy79l3z84qmhyjx50xdsbgnz1z4md";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ hidapi libcbor openssl ]
    ++ stdenv.lib.optionals stdenv.isLinux [ udev ];

  cmakeFlags = [
    "-DUDEV_RULES_DIR=${placeholder "out"}/etc/udev/rules.d"
    "-DUSE_HIDAPI=1"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = with stdenv.lib; {
    description = ''
    Provides library functionality for FIDO 2.0, including communication with a device over USB.
    '';
    homepage = "https://github.com/Yubico/libfido2";
    license = licenses.bsd2;
    maintainers = with maintainers; [ dtzWill prusnak ];
    platforms = platforms.unix;
  };
}
