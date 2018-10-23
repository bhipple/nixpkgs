{ pkgs, buildPythonPackage, fetchPypi, numpy, cython }:

buildPythonPackage rec {
  pname = "pystan";
  version = "2.18.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "594c1523fd5cd6034ba1b58b1a0741f7e753c819d17745395defa25e526115ce";
  };

  propagatedBuildInputs = [ numpy cython ];

  meta = with pkgs.lib; {
    description = "Python interface to Stan, a package for Bayesian inference";
    homepage = https://github.com/stan-dev/pystan;
    license = licenses.gpl3;
    maintainers = [ maintainers.bhipple ];
  };
}
