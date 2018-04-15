#!/bin/sh
path=${1#file://}

if [ -d $path ]
then
    /usr/bin/kitty /usr/bin/ranger $path
else
    /usr/bin/kitty /usr/bin/ranger --selectfile=$path
fi
