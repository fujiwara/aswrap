aswrap: aswrap.pl
	fatpack pack aswrap.pl > aswrap
	chmod 755 aswrap

test:
	perl -wc aswrap.pl

clean:
	rm -f aswrap fatlib

install: aswrap
	install aswrap ~/bin

.PHONY: clean
