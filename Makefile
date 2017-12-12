aswrap: aswrap.pl
	fatpack pack aswrap.pl > aswrap
	chmod 755 aswrap

clean:
	rm -f aswrap

install: aswrap
	install aswrap ~/bin

.PHONY: clean
