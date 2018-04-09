#!python3.5/python.exe
import os
import sys

from openquake.commands import __main__ as main

installdir = os.path.dirname(os.path.dirname(__file__))
pkgdir = os.path.join(installdir, os.path.join('lib', 'site-packages'))
sys.path.insert(0, pkgdir)
os.environ['PYTHONPATH'] = pkgdir + os.pathsep + os.environ.get('PYTHONPATH',
                                                                '')

# Allowing .dll files in Python directory to be found
os.environ['PATH'] += ';' + os.path.dirname(sys.executable)

if __name__ == '__main__':
    main.oq()
