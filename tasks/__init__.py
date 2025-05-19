import test

import build
import install
from invoke import Collection

ns = Collection()
ns.add_collection(Collection.from_module(build, name="build"))
ns.add_collection(Collection.from_module(install, name="install"))
ns.add_collection(Collection.from_module(test, name="test"))
