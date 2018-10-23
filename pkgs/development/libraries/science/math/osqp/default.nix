{ stdenv, writeText, fetchFromGitHub, cmake
, python, numpy, scipy, mkl
, withMkl ? false
}:

stdenv.mkDerivation rec {
  name = "osqp-${version}";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "oxfordcontrol";
    repo = "osqp";
    rev = "v${version}";
    sha256 = "0jm8ic55knm68rhy68gkpv73bqd91schkzc7g9cghxgdp651x12f";
    fetchSubmodules = true;
  };

  buildInputs = [ cmake python numpy scipy mkl ];
  propagatedBuildInputs = [ mkl ];

  # MKL Pardiso requires the proprietary Intel MKL libraries
  cmakeFlags = [
    "-DUNITTESTS=ON"
    ("-DENABLE_MKL_PARDISO=" + (if withMkl then "ON" else "OFF"))
  ];

  doCheck = true;
  checkPhase = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${mkl}/lib
    ./out/osqp_demo
    ./out/osqp_tester
  '';

  meta = with stdenv.lib; {
    description = "Operator Splitting Quadratic Program Solver";
    homepage = https://osqp.org;
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = [ maintainers.bhipple ];
  };
}
