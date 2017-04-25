ifndef FSTAR_HOME
   $(error "Please define the `FSTAR_HOME` variable before including this makefile.")
endif

HINTS_ENABLED?=--use_hints

FSTAR_ALWAYS=$(shell cd $(FSTAR_HOME) && pwd)/bin/fstar.exe $(OTHERFLAGS) $(HINTS_ENABLED)
FSTAR=$(FSTAR_ALWAYS)

CVEREXE_ALWAYS=$(shell cd $(FSTAR_HOME) && pwd)/bin/fabc-make.exe
CVEREXE=$(CVEREXE_ALWAYS)

DG=$(.DEFAULT_GOAL)

BATCH_TMP=$(shell cd $(FSTAR_HOME) && pwd)/tmp
$(BATCH_TMP):
	mkdir -v $(BATCH_TMP)

FABC_HINTS?="-h $(FSTAR_HOME)"

.PHONY : CVERCONFIG
CVERCONFIG: $(BATCH_TMP)
ifndef BATCH_IDS_FILE_ABS
	$(eval export BATCH_IDS_FILE_ABS:=$(shell mktemp -p $(BATCH_TMP)))
	$(CVEREXE) create $(FABC_EXTRA) -i $(shell realpath --relative-to=. $(BATCH_IDS_FILE_ABS))
endif

BATCH_IDS_FILE=$(shell realpath --relative-to=. $(BATCH_IDS_FILE_ABS))

CVERFSTAR=$(CVEREXE) add $(FABC_EXTRA) -i $(BATCH_IDS_FILE) -d 'CURRENT_DIR' -- \$$H/bin/fstar.exe $(OTHERFLAGS) $(HINTS_ENABLED)

.DEFAULT_GOAL := $(DG)
