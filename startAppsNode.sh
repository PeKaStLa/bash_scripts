#!/bin/bash
#
#################################################################
#                    startAppsNode.sh                           #
#                     01.07.2023, 14:03                         #
#               last change 01.07.2023, 14:03                   #
#    script for automating restart for all npm/node apps        #
#tasks:                                                         #
#1. Loop over repo-names and ports                              #
#   2. check for free port                                      #
#   3. Deploy them                                              #
#################################################################
#

source ~/scripts/functions.sh

declare  -r repos=("blog" "mittendrin");
declare  -r ports=(3010 3011);

for ((i=0; i<${#repos[@]}; i++))
do
    echo "------Now check and deploy ${repos[i]} if not running on port ${ports[i]}";
    IsPortFree ${ports[i]} && TmuxDeployNode ${repos[i]} ${ports[i]};
done



