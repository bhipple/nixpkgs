{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, liblapack
, numpy
, blas
, scipy
, scs
  # check inputs
, nose
}:

buildPythonPackage rec {
  pname = "scs";
  version = "2.1.1";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "bodono";
    repo = "scs-python";
    rev = "f02abdc0e2e0a5851464e30f6766ccdbb19d73f0"; # need to choose commit manually, untagged
    sha256 = "01ghvyylxql7jvdcwy65wf7y5qykqyqkbysy402zfhgmm9dxizgv";
    fetchSubmodules = true;
  };

  # Upstream ships a git submodule for the C module and tries to build it from
  # src. For the Nix distribution, ensure that we use the same version.
  preConfigure = ''
    rm -r scs
    ln -s ${scs.src} scs
  '';

  buildInputs = [
    liblapack
    blas
  ];

  propagatedBuildInputs = [
    numpy
    scipy
  ];

  checkInputs = [ nose ];
  checkPhase = ''
    nosetests
  '';
  pythonImportsCheck = [ "scs" ];

  meta = with lib; {
    description = "Python interface for SCS: Splitting Conic Solver";
    longDescription = ''
      Solves convex cone programs via operator splitting.
      Can solve: linear programs (LPs), second-order cone programs (SOCPs), semidefinite programs (SDPs),
      exponential cone programs (ECPs), and power cone programs (PCPs), or problems with any combination of those cones.
    '';
    homepage = "https://github.com/cvxgrp/scs"; # upstream C package
    downloadPage = "https://github.com/bodono/scs-python";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
