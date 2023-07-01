#!/bin/bash
#
#################################################################
#                    updateNpmRepos.sh                          #
#                     01.07.2023, 12:33                         #
#               last change 01.07.2023, 12:33                   #
#         script for automating CD of all npm/node repos        #
#tasks:                                                         #
#1. Loop over repo-names and ports                              #
#   2. Update them 						#
#   3. Deploy them   	                                        #
#################################################################
#

source ~/scripts/functions.sh

declare  -r repos=("blog" "mittendrin");
declare  -r ports=(3010 3011);

for ((i=0; i<${#repos[@]}; i++))
do
    echo "-------Now update ${repos[i]} on port ${ports[i]}";
    PullBuildNode ${repos[i]};
    TmuxDeployNode ${repos[i]} ${ports[i]};
done







