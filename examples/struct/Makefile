# Test the 'include' functionality

FSTAR_HOME=../..
include $(FSTAR_HOME)/src/gmake/fstar.mk

POSTESTS=$(wildcard *.pos)
POSTARGETS=$(addsuffix .pver,$(POSTESTS))

NEGTESTS=$(wildcard *.neg)
NEGTARGETS=$(addsuffix .nver,$(NEGTESTS))

all: uall

uall: $(POSTARGETS) $(NEGTARGETS)

$(POSTARGETS): %.pver: %
	$(FSTAR) --include $(FSTAR_HOME)/ulib --include $(FSTAR_HOME)/ulib/hyperstack --include $^ --odir $^ Test.fst

$(NEGTARGETS): %.nver: %
	! $(FSTAR) --include $(FSTAR_HOME)/ulib --include $(FSTAR_HOME)/ulib/hyperstack --include $^ --odir $^ Test.fst > $^/error.log 2>&1
	@echo $^ failed as expected

clean:
	for f in $(NEGTESTS) ; do rm -f $$f/error.log ; done
