# LLVM Wheels

This is a simple python package wrapper for prebuilt LLVM tools/libraries and dev files

The actual wheels are available on pypi.org as:
- xtc-llvm-tools : LLVM tools and shared libraries;
- xtc-llvm-dev: LLVM dev include, archive and cmake files.


## Installing the LLVM wheels for some project

The minimal required python version is: `python >= 3.10`

In a python environment setup for instance with:

    python3 -m venv .venv
    source .venv/bin/activate

One can install the llvm libraries `21.1.2.*` with for instance:

    pip3 install xtc-llvm-tools~=21.1.2.0 xtc-llvm-dev~=21.1.2.0 \

Or one can add in a `requirements.txt` file for instance:

    xtc-llvm-tools~=21.1.2.0
    xtc-llvm-dev~=21.1.2.0

And run:

    pip3 install -r requirements.txt
    ...
    Successfully installed xtc-llvm-tools-21.1.2.5
    Successfully installed xtc-llvm-dev-21.1.2.5

## Using llvm installed tools

To get the path to llvm tools, for instance run `llvm-config`:

    LLVM_PREFIX=$(python -c 'import llvm;print(llvm.__path__[0])')
    $LLVM_PREFIX/bin/llvm-config --version
    21.1.2

## Maintenance

The following section is for the owners of the repository who maintain the published
packages.

### Publish new versions

Ensure that your current python version is 3.10.x, otherwise the installed packages
will not be available for this version.

Then install dependencies for the build script:

    pip install -r requirements.txt

Update the version for LLVM:
- in `llvm_revision.txt`: put the full sha1 of the new revision to publish
- in `version.txt`: update the content `x.y.z.X`
  where `x.y.z` is the LLVM last tag for this revision.
  The 'X' part is actually the part identifying the revision of the wheel,
  should start by 1 at each new LLVM revision.

Then run the cibuildwheel which will create the wheels to install in `wheelhouse/`:

     ./checkout-llvm.sh
     ./build-wheels-tools.sh
     ./build-wheels-dev.sh

Once built, one may publish to some pypi repository with (here `test.pypi.org`):

    python -m twine upload -u '<user>' -p '<token>' \
    --repository-url https://test.pypi.org/legacy/ \
    wheelhouse/*.whl
