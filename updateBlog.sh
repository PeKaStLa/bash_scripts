#!/bin/bash
#
#################################################################
#								#
#                       updateBlog.sh				#
#                     05.06.2023, 11:11				#
#                     last change 29.06.2023			#
#         script for automating CD of the blog-WebApp.  	#
#tasks:								#
#								#
#1. compare latest local and remote git commit hash		#
#2. git pull							#
#3. npm run build						#
#4. kill old tmux process					#
#5. start detached tmux-session					#
#6. start new node-server in detached tmux-session		#
#								#
#files/project/webapp needed:					#
#/home/ec2-user/blog (git & npm directory)			#
#~/blog/build/index.js (Build directory 'build')		#	
#								#
#################################################################

source ~/scripts/functions.sh

PullBuildTmuxDeploy blog 3010;






