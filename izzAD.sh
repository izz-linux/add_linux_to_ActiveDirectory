#!/bin/bash

## wrapper script for addtoAD.sh

while read line
do
    scp addto* $line:/home/izz/
    ssh -n $line "sudo ./addtoAD.sh"
#    ssh $line "sudo ./addtoAD2.sh"
    ssh -n $line "rm -rf ./addtoAD.sh"
done < linuxhosts
