#!/bin/bash
# mkws128.sh <área> <fichero>...: área de porte a mano sobre la 128 + parches de bc (portgd sin commits + add128). MOTOR-32.
A=$1; shift; STEP=1 /tmp/claude-0/port/portgd.sh $A >/dev/null 2>&1; /tmp/claude-0/port/add128.sh $A "$@"
