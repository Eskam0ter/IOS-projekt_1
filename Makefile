#!/bin/sh
all :
	git add -A
	git commit -m "Update"
	git push
	echo $(PATH)	
