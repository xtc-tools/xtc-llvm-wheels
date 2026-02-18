# LLVM Wheels

This is a simple python package wrapper for prebuilt LLVM libraries.

The actual gitlab wheels can then be viewd from: https://gitlab.inria.fr/groups/CORSE/-/packages

## Installing the LLVM wheels for some project

The minimal required python version is: `python >= 3.10`

In a python environment setup for instance with:

    python3 -m venv .venv
    source .venv/bin/activate

One can install the llvm libraries `19.1.*` with for instance:

    pip3 install llvm~=19.1.0 \
    -i https://gitlab.inria.fr/api/v4/projects/57611/packages/pypi/simple

Or one can add in a `requirements.txt` file for instance:

    --extra-index-url https://gitlab.inria.fr/api/v4/projects/57611/packages/pypi/simple
    llvm~=19.1.0

And run:

    pip3 install -r requirements.txt
    ...
    Successfully installed llvm-19.1.7.2025011201+cd708029

## Using llvm installed tools

To get the path to llvm tools, for instance run `llvm-config`:

    LLVM_PREFIX=$(python -c 'import llvm;print(llvm.__path__[0])')
    $LLVM_PREFIX/bin/llvm-config --version
    14.0.6

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
- in `setup.py`: update the variable `PACKAGE_VERSION = "vx.y.z.X>"`
  where `vx.y.z` is the LLVM last tag for this revision.
  The 'X' part is actually the part identifying the revision of the wheel,
  should start by 1 at each new LLVM revision.

Then run the cibuildwheel which will create the wheels to install in `wheelhouse/`:

     ./checkout-llvm.sh
     ./build-wheels.sh

Once built, one may publish to the project repository with:

    python -m twine upload -u '<user>' -p '<token>' \
    --repository-url https://gitlab.inria.fr/api/v4/projects/57611/packages/pypi \
    wheelhouse/*.whl
