# Hydra evaluation error

I am setting up an hydra server in house to run build and package our products.
This repository provides a simple reproduction of the problem I encounter.

## What I want to do

I am packaging an autotools based project. There is a line in the
`configure.ac` that tells the tools what it the project name, what is the
project version and who bugs should be sent to. It looks like:

```
AC_INIT([hellohydra], [0.1], [me@somewhere.tld])
```

Somewhere in the nix-derivation function used to build this project, we should
specify the name of the derivation and its version:

```nix
mkDrivation rec {
  name = "hellohydra-${version}";
  version = "0.1";
  …
}
```

Basically, I do wand to remove the repetition between those two files in order
to only have one file to update when I release a new version.

## Hacky solution

To do that, I have use a small python script wrapped in `runCommand` used to
parse the `configure.ac` file and extract the version information I am looking
for. It is done in the [`get_version.nix`](get_version.nix) file. I then just
have to call that function in my nix expression like this:

```nix
mkDrivation rec {
  name = "hellohydra-${version}";
  version = import ./get_version.nix { inherit pkgs; };
  …
}
```

Locally, it works perfectly. I can use a simple [`release.nix`](release.nix) to
describe what hydra would have to do and launch it:

```bash
$ NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz:hellohydra=https://github.com/lsix/hellohydra/archive/master.tar.gz nix-build -A hellohydra release.nix
downloading ‘https://github.com/lsix/hellohydra/archive/master.tar.gz’... [0/0 KiB, 0.0 KiB/s]
unpacking ‘https://github.com/lsix/hellohydra/archive/master.tar.gz’...
downloading ‘https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz’... [0/0 KiB, 0.0  [10839/11102 KiB, 279.4 KiB/s]
…
/nix/store/z5k8r5kwhzwhqxqg2k54yfjn7agslhzz-hellohydra-0.1
```

Everything is great before I set foot on hydra…

## Evaluating the jobset with hydra

Next step: create and evaluate the jobset in a hydra instance. The jobset
creation is quite steight forward, here are the parameters I used:

| param          | value                           |
|----------------|---------------------------------|
| …              | …                               |
| Nix expression | release.nix in input hellohydra |
| …              | …                               |

| Input name | Type         | Values                                                             |
|------------|--------------|--------------------------------------------------------------------|
| hellohydra | Git checkout | https://github.com/lsix/hellohydra.git master                      |
| nixpkgs    | Git checkout | https://github.com/NixOS/nixpkgs-channels.git nixos-unstable-small |

When hydra evaluates the jobset, it gives me the following error:

```
in job ‘hellohydra’:
the string ‘hellohydra-0.1’ is not allowed to refer to a store path (such as ‘!out!/nix/store/ixiqwfgyiizvqfjqszs2hv09cvalq525-hellohydra_version.drv’)
```

## Question

So yes, I fully understand that `hydra-evaluator`'s job is definitevely not to
instanciate the derivations. It planns everything and queues jobs. But for this
kind of scenario, where I only rely on really small helper functions to
actually fully describe my jobset, it would be apprecible to let the evaluator
do this simple task (and it actually does it since it have correctly evaluated
the derivation name).

Is there a way to acheive what I want to do?

I know I could opt for another solution: have the version in a `version` file,
and read from both [`configure.ac`](configure.ac) and
[`default.nix`](default.nix) (see
[here](http://stackoverflow.com/questions/8559456/read-a-version-number-from-a-file-in-configure-ac)
for a solution) but I wold prefer that the nix related logic do not interfere
with the original project.

I am open to any succestion.
