{ stdenv
, buildPythonApplication
, fetchpatch
, lib
, python
, fetchFromGitHub
, lame
, mplayer
, libpulseaudio
, pyqtwebengine
, decorator
, beautifulsoup4
, sqlalchemy
, pyaudio
, requests
, markdown
, matplotlib
, pytest
, glibcLocales
, nose
, jsonschema
, setuptools
, send2trash
, CoreAudio
# This little flag adds a huge number of dependencies, but we assume that
# everyone wants Anki to draw plots with statistics by default.
, plotsSupport ? true
# manual
, asciidoc
}:

let
    # when updating, also update rev-manual to a recent version of
    # https://github.com/dae/ankidocs
    # The manual is distributed independently of the software.
    version = "2.1.23";
    sha256-pkg = "12h0dzrpahp3mp3rmrz5yd72y8r5298qf0n147cizah4xhqjhsb5";
    rev-manual = "515132248c0ccb1e0ddbaf44fbe9bdb67a24742f";
    sha256-manual = "1hrhs20cd6sbkfjxc45q8clmfai5nwwv27lhgnv46x1qnwimj8np";

    manual = stdenv.mkDerivation {
      pname = "anki-manual";
      inherit version;

      src = fetchFromGitHub {
        owner = "ankitects";
        repo = "anki-docs";
        rev = rev-manual;
        sha256 = sha256-manual;
      };

      phases = [ "unpackPhase" "patchPhase" "buildPhase" ];
      nativeBuildInputs = [ asciidoc ];
      patchPhase = ''
        # rsync isnt needed
        # WEB is the PREFIX
        # We remove any special ankiweb output generation
        # and rename every .mako to .html
        sed -e 's/rsync -a/cp -a/g' \
            -e "s|\$(WEB)/docs|$out/share/doc/anki/html|" \
            -e '/echo asciidoc/,/mv $@.tmp $@/c \\tasciidoc -b html5 -o $@ $<' \
            -e 's/\.mako/.html/g' \
            -i Makefile
        # patch absolute links to the other language manuals
        sed -e 's|https://apps.ankiweb.net/docs/|link:./|g' \
            -i {manual.txt,manual.*.txt}
        # there’s an artifact in most input files
        sed -e '/<%def.*title.*/d' \
            -i *.txt
        mkdir -p $out/share/doc/anki/html
      '';
    };

in
buildPythonApplication rec {
    pname = "anki";
    inherit version;

    src = fetchFromGitHub {
      owner = "ankitects";
      repo = "anki";
      rev = version;
      sha256 = sha256-pkg;
    };

    outputs = [ "out" "doc" "man" ];

    propagatedBuildInputs = [
      pyqtwebengine sqlalchemy beautifulsoup4 send2trash pyaudio requests decorator
      markdown jsonschema setuptools
    ]
      ++ lib.optional plotsSupport matplotlib
      ++ lib.optional stdenv.isDarwin [ CoreAudio ]
      ;

    checkInputs = [ pytest glibcLocales nose ];

    nativeBuildInputs = [ pyqtwebengine.wrapQtAppsHook ];
    buildInputs = [ lame mplayer libpulseaudio  ];

    patches = [
      # Disable updated version check.
      ./no-version-check.patch
    ];

    # Anki does not use setup.py
    dontBuild = true;

    # Hitting F1 should open the local manual
    postPatch = ''
      substituteInPlace pylib/anki/consts.py \
        --replace 'HELP_SITE=.*' \
                  'HELP_SITE="${manual}/share/doc/anki/html/manual.html"'
    '';

    # UTF-8 locale needed for testing
    LC_ALL = "en_US.UTF-8";

    checkPhase = ''
      # - Anki writes some files to $HOME during tests
      # - Skip tests using network
      HOME=$TMP pytest --ignore tests/test_sync.py
    '';

    installPhase = ''
      pp=$out/lib/${python.libPrefix}/site-packages

      mkdir -p $out/bin
      mkdir -p $out/share/applications
      mkdir -p $doc/share/doc/anki
      mkdir -p $man/share/man/man1
      mkdir -p $out/share/mime/packages
      mkdir -p $out/share/pixmaps
      mkdir -p $pp

      cat > $out/bin/anki <<EOF
      #!${python}/bin/python
      import aqt
      aqt.run()
      EOF
      chmod 755 $out/bin/anki

      cp -v qt/anki.desktop $out/share/applications/
      cp -v README* LICENSE* $doc/share/doc/anki/
      cp -v qt/anki.1 $man/share/man/man1/
      cp -v qt/anki.xml $out/share/mime/packages/
      cp -v qt/anki.{png,xpm} $out/share/pixmaps/
      cp -rv qt/pqt pylib/anki $pp/

      # copy the manual into $doc
      cp -r ${manual}/share/doc/anki/html $doc/share/doc/anki
    '';

    # now wrapPythonPrograms from postFixup will add both python and qt env variables
    dontWrapQtApps = true;

    preFixup = ''
      makeWrapperArgs+=(
        "''${qtWrapperArgs[@]}"
        --prefix PATH ':' "${lame}/bin:${mplayer}/bin"
      )
    '';

    passthru = {
      inherit manual;
    };

    meta = with lib; {
      homepage = "https://apps.ankiweb.net/";
      description = "Spaced repetition flashcard program";
      longDescription = ''
        Anki is a program which makes remembering things easy. Because it is a lot
        more efficient than traditional study methods, you can either greatly
        decrease your time spent studying, or greatly increase the amount you learn.

        Anyone who needs to remember things in their daily life can benefit from
        Anki. Since it is content-agnostic and supports images, audio, videos and
        scientific markup (via LaTeX), the possibilities are endless. For example:
        learning a language, studying for medical and law exams, memorizing
        people's names and faces, brushing up on geography, mastering long poems,
        or even practicing guitar chords!
      '';
      license = licenses.agpl3Plus;
      broken = stdenv.hostPlatform.isAarch64;
      platforms = platforms.mesaPlatforms;
      maintainers = with maintainers; [ oxij the-kenny Profpatsch enzime ];
    };
}
