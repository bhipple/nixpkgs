{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  libspatialindex,
  numpy,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "rtree";
  version = "1.3.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "Toblerity";
    repo = "rtree";
    tag = version;
    hash = "sha256-yuSPRb8SRz+FRmwFCKDx+gtp9IWaneQ84jDuZP7TX0A=";
  };

  postPatch = ''
    substituteInPlace rtree/finder.py --replace \
      'find_library("spatialindex_c")' '"${libspatialindex}/lib/libspatialindex_c${stdenv.hostPlatform.extensions.sharedLibrary}"'
  '';

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  buildInputs = [ libspatialindex ];

  nativeCheckInputs = [
    numpy
    pytestCheckHook
  ];

  pythonImportsCheck = [ "rtree" ];

  meta = with lib; {
    description = "R-Tree spatial index for Python GIS";
    homepage = "https://github.com/Toblerity/rtree";
    changelog = "https://github.com/Toblerity/rtree/blob/${version}/CHANGES.rst";
    license = licenses.mit;
    maintainers = with maintainers; teams.geospatial.members ++ [ bgamari ];
  };
}
