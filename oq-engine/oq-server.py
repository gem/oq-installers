#!python2.7-32
import sys
import os
scriptdir, script = os.path.split(__file__)
pkgdir = os.path.join(scriptdir, 'pkgs')
sys.path.insert(0, pkgdir)
os.environ['PYTHONPATH'] = (pkgdir + os.pathsep
                            + os.environ.get('PYTHONPATH', ''))

# APPDATA should always be set, but in case it isn't, try user home
# If none of APPDATA, HOME, USERPROFILE or HOMEPATH are set, this will fail.
appdata = os.environ.get('APPDATA', None) or os.path.expanduser('~')

if 'pythonw' in sys.executable:
    # Running with no console - send all stdstream output to a file.
    kw = {'errors': 'replace'} if (sys.version_info[0] >= 3) else {}
    sys.stdout = sys.stderr = open(os.path.join(appdata, script+'.log'),
                                   'w', **kw)
else:
    # In a console. But if the console was started just for this program, it
    # will close as soon as we exit, so write the traceback to a file as well.
    def excepthook(etype, value, tb):
        "Write unhandled exceptions to a file and to stderr."
        import traceback
        traceback.print_exception(etype, value, tb)
        with open(os.path.join(appdata, script+'.log'), 'w') as f:
            traceback.print_exception(etype, value, tb, file=f)
    sys.excepthook = excepthook


from openquake.server.dbserver import runserver
from openquake.engine.logs import dbcmd


def _help():
    print("Usage: %s <dbserver|webui> <start|stop>" % sys.argv[0])


if __name__ == '__main__':
    if sys.argv[1] == 'dbserver':
        if sys.argv[2] == 'start':
            runserver()
        elif sys.argv[2] == 'stop':
            dbcmd('stop')
        else:
            _help()
    elif sys.argv[1] == 'webui':
        if sys.argv[2] == 'start':
            from django.core.management import execute_from_command_line
            from openquake.server import executor
            from openquake.engine import logs

            os.environ.setdefault(
                "DJANGO_SETTINGS_MODULE", "openquake.server.settings")
            # check the database version
            logs.dbcmd('check_outdated')
            # reset is_running
            logs.dbcmd('reset_is_running')
            with executor:
                execute_from_command_line(sys.argv)
        else:
            _help()
    else:
        _help()
