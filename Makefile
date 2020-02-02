T    := paratest
PATH := $(PATH):UTIL
SRC  := $(T:%=%.pl)

all: $T

$T: %: %.pl *.pl | CONFIG.pl
	perlpp $< > $@
	@chmod 755 $@

CONFIG.pl: $(SRC) Makefile
	mkversionpl | grep -v MKDIR > $@.bkp; mv $@.bkp $@

install: all
	makeinstall -f $T

clean:
	rm -f $T

include ~/.github/Makefile.git
