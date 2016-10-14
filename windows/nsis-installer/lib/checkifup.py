import sys
import time
import urllib

resp = ''

if len(sys.argv) < 2:
    raise ValueError('Missing argument host')

host = str(sys.argv[1])

while (resp != 200):
    time.sleep(1)
    try:
        resp = urllib.urlopen(host).getcode()
    except:
        pass
