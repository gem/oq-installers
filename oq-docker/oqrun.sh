#!/bin/bash

if [ -t 1 ]; then
    # TTY mode
    oq webui start 0.0.0.0:8800 &> /tmp/webui.log &
    /bin/bash
else
    # Headless mode
    oq webui start 0.0.0.0:8800 &> /tmp/webui.log
fi
