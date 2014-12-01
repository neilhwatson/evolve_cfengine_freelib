CF_PROMISES = cf-promises
CF_AGENT    = cf-agent
VERSION     = 3.6
LIB         = lib/$(VERSION)
EFL_LIB     = masterfiles/$(LIB)/EFL
CF_REPO     = https://github.com/cfengine

EFL_FILES   = \
	$(EFL_LIB)/efl_common.cf \
	$(EFL_LIB)/evolve_freelib.cf

eflmaker    = ./bin/eflmaker
cfstdlib    = \
	test/$(LIB)/commands.cf \
	test/$(LIB)/processes.cf \
	test/$(LIB)/feature.cf \
	test/$(LIB)/vcs.cf \
	test/$(LIB)/cfe_internal.cf \
	test/$(LIB)/reports.cf \
	test/$(LIB)/guest_environments.cf \
	test/$(LIB)/bundles.cf \
	test/$(LIB)/services.cf \
	test/$(LIB)/common.cf \
	test/$(LIB)/users.cf \
	test/$(LIB)/storage.cf \
	test/$(LIB)/packages.cf \
	test/$(LIB)/paths.cf \
	test/$(LIB)/files.cf \
	test/$(LIB)/databases.cf \
	test/$(LIB)/edit_xml.cf \
	test/$(LIB)/examples.cf \
	test/$(LIB)/monitor.cf \
	test/$(LIB)/stdlib.cf

tests       =    \
	version       \
	syntax        \
	001_efl_test

	
.PHONY: all
all: $(EFL_FILES)

$(EFL_FILES): $(EFL_LIB) src/includes/param_parser.cf src/includes/param_file_picker.cf src/$@
	cp src/$@ $@
	$(eflmaker) --tar $@ \
		--tag param_parser -i src/includes/param_parser.cf
	$(eflmaker) --tar $@ \
		--tag param_file_picker -i src/includes/param_file_picker.cf

$(EFL_LIB):
	mkdir -p $@

.PHONY: check
check: test/$(EFL_LIB) $(cfstdlib) $(EFL_FILES) $(tests)

.PHONY: version
version:
	$(CF_PROMISES) -V | grep $(VERSION) && echo PASS: $@

.PHONY: syntax
syntax:
	cd test/masterfiles; $(CF_PROMISES) -cf ./promises.cf && echo PASS: $@

.PHONY: 001_efl_test
001_efl_test: 
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@ | \
		pcregrep --quiet --multiline 'R: PASS, any, efl_main order 1\
R: PASS, any, efl_main order 2\
R: PASS, any, efl_main order 3\
R: PASS, any, efl_main order 4\
R: PASS, any, efl_main order 5' && echo PASS: $@

# TODO create macros or vars to duplicate test for csv and json input?
# TODO build csv of json automatically using the other?
test/$(EFL_LIB):
	mkdir -p $@
	cp -r $(EFL_LIB)/* test/$(EFL_LIB)/

$(cfstdlib): .stdlib

.stdlib:
	cd test/masterfiles/lib; svn export --force $(CF_REPO)/masterfiles/trunk/lib/$(VERSION)
	touch $@

.PHONY: clean
clean:
	rm -fr masterfiles/*
	rm -f .stdlib
	rm -fr test/$(EFL_LIB)

.PHONY: help
help:
	$(MAKE) --print-data-base --question |           \
		awk '/^[^.%][-A-Za-z0-9_]*:/                  \
			{ print substr($$q, 1, length($$1)-1) }' | \
		sort |                                        \
		pr --omit-pagination --width=80 --columns=4
