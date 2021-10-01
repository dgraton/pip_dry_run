#!/bin/bash

# Perform a "noop" pip install dry-run and display what will change, without actually changing anything

USAGE="Usage:\n
Example1: pip_dry_run.sh requests\n
Example2: pip_dry_run.sh requests==2.25.1\n
Example3: pip_dry_run.sh requests>=2.20,<2.3"

PACKAGE=$1
if [ -z "$1" ]; then
  echo -e $USAGE
  exit 1
fi

export ptmp=/var/tmp/pip_temp
export freeze=$ptmp/pip_freeze.txt
rm -rf $ptmp/
mkdir -p $ptmp/
pip3 freeze > $freeze

installed=`pip3 install --target=$ptmp/ $PACKAGE | tail -n 2 | grep 'Successfully installed' | cut -d' ' -f3-`

for module in $installed
do
  base=`echo $module | rev | cut -d '-' -f2- | rev | cut -d ' ' -f2-`
  current=`grep "$base" $freeze`
  if [ -z "$current" ]; then
    current="(not installed)"
    echo $module will be installed for the first time
  else
    fixed=`echo $current | sed 's/==/-/'`
    if [ "$fixed" != "$module" ]; then
      echo "$current ----> $module"
    fi
  fi
done

rm -rf $ptmp
