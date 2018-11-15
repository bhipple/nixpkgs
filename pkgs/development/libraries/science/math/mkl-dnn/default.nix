{ stdenv, fetchFromGitHub, cmake, doxygen }:

stdenv.mkDerivation rec {
  name = "mkl-dnn-${version}";
  version = "0.17-rc";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "mkl-dnn";
    rev= "v${version}";
    #sha256 = "1bs4c147pixg30kp51dnm5cyh2x0hb77q1qs13mdvw86ncf6f5kr";
    sha256 = "1sx7rn28mnb37c5a010gnv71h3nsddi7m282954jdcmd0sg892ad";
  };

  buildInputs = [ cmake doxygen ];

  # Contains optimizations for the native CPU architecture
  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Intel(R) Math Kernel Library for Deep Neural Networks (Intel(R) MKL-DNN)";
    homepage = https://01.org/mkl-dnn;
    license = licenses.asl20;
    maintainers = [ maintainers.bhipple ];
  };
}
