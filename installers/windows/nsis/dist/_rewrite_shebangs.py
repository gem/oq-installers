# Original source:
#    https://github.com/takluyver/pynsist/blob/80392f24d664b08eb7f0b7e45a408575e55810fc/nsist/_rewrite_shebangs.py
# Copyright (c) 2014-2017 Thomas Kluyver under MIT license:
#   https://github.com/takluyver/pynsist/blob/e01d6f08eb71bc5aa2d294f5369a736e59becd09/LICENSE
"""This is run during installation to rewrite the shebang (#! headers) of script
files.
"""
import glob
import os.path
import sys

if sys.version_info[0] >= 3:
    # What do we do if the path contains characters outside the system code page?!
    b_python_exe = sys.executable.encode(sys.getfilesystemencoding())
else:
    b_python_exe = sys.executable

def rewrite(path):
    with open(path, 'rb') as f:
        contents = f.readlines()

    if not contents:
        return
    if contents[0].strip() != b'#!python':
        return

    contents[0] = b'#!"' + b_python_exe + b'"\n'

    with open(path, 'wb') as f:
        f.writelines(contents)

def main(argv=None):
    if argv is None:
        argv = sys.argv
    target_dir = argv[1]
    for path in glob.glob(os.path.join(target_dir, '*-script.py')):
        rewrite(path)

if __name__ == '__main__':
    main()
