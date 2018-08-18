{ stdenv, fetchFromGitHub, cmake, python, numpy, scipy
,  mkl # TODO: Make this parameterizable and null by default
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

  # Actually link mkl, instead of relying on devs to set LD_LIBRARY_PATH manually
  patches = [
    ./0001-Link-mkl-and-openmp-dependencies.patch
  ];

  buildInputs = [ cmake python numpy scipy mkl ];

  # MKL Pardiso requires the proprietary Intel MKL libraries
  cmakeFlags = [
    "-DUNITTESTS=ON"
    "-DENABLE_MKL_PARDISO=ON"
  ];

  doCheck = true;
  checkPhase = ''
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
