{ pkgs }:
let configure_ac = ./configure.ac;
    versionNumber = pkgs.runCommand "hellohydra_version" { } ''
      ${pkgs.python.interpreter} > $out <<EOT
      import re
      import os

      with open(os.environ.get('out'), 'w') as outf:
          outf.write(
              re.search(
                  "AC_INIT\(\[(?P<name>[^\]]*)\],\s*\[(?P<version>[^\]]*)\]",
                  open("${configure_ac}").read()).group('version').strip())
      EOT
    '';
in builtins.readFile versionNumber
