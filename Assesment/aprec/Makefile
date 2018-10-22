phoney: none

help:
	@echo "== MAKEFILE COMMANDS =="
	@echo "make a -- Stage all tracked files for commit"
	@echo "make clr -- Remove all cav files"
	@echo "make p -- sync w' remote"
	@echo "make s -- List git status"

p:
	git pull
	git push

clr:
	rm *.csv

s:
	git status

a:
	git add -u
