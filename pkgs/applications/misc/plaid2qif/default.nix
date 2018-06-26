{ lib, buildPythonApplication, fetchPypi, plaid-python, python-dateutil, docopt, wheel }:

buildPythonApplication rec {
  pname = "plaid2qif";
  version = "1.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0s2wah7wxwla9k04kh6q4v5rf51419ilv0a57xmh9vbsdbz2y0ia";
  };

  # setup.py reads requirements.txt from the src repo; twine is only needed to upload to pypi
  patchPhase = ''
    sed -i '/twine/d' plaid2qif.egg-info/requires.txt
    substituteInPlace setup.py --replace requirements.txt plaid2qif.egg-info/requires.txt
  '';

  # No tests upstream
  doCheck = false;

  propagatedBuildInputs = [ plaid-python python-dateutil docopt wheel ];

  meta = {
    description = "Download financial transactions from Plaid as QIF files";
    homepage = https://github.com/ebridges/plaid2qif;
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ bhipple ];
  };
}
