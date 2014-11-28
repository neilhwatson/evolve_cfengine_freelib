CF_PROMISES = cf-promises
VERSION     = 3.6
LIB         = lib/$(VERSION)
EFL_LIB     = masterfiles/$(LIB)/EFL
CF_REPO     = https://github.com/cfengine
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

$(EFL_LIB)/evolve_freelib.cf: src/includes/param_parser.cf src/includes/param_file_picker.cf src/$(EFL_LIB)/evolve_freelib.cf $(EFL_LIB)
	cp src/$(EFL_LIB)/evolve_freelib.cf $@
	$(eflmaker) --tar $@ \
		--tag param_parser -i src/includes/param_parser.cf
	$(eflmaker) --tar $@ \
		--tag param_file_picker -i src/includes/param_file_picker.cf

$(EFL_LIB):
	mkdir -p $@

.PHONY: check
check: test/$(EFL_LIB) $(cfstdlib) $(EFL_LIB)/evolve_freelib.cf
	printf "Checking...\n"
	$(CF_PROMISES) -V | grep $(VERSION) && echo PASS
	cp $(EFL_LIB)/evolve_freelib.cf test/$(EFL_LIB)/
	cd test/masterfiles; $(CF_PROMISES) -cf ./promises.cf && echo PASS

test/$(EFL_LIB):
	mkdir -p $@

# TODO this is not working
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
