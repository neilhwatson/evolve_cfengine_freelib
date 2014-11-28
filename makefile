CF_PROMISES = cf-promises
VERSION = 3.6
LIB = lib/$(VERSION)
CF_REPO = https://github.com/cfengine
DEST    = masterfiles/$(LIB)/EFL
eflmaker = ./bin/eflmaker
cfstdlib = \
	test/$(DEST)/commands.cf \
	test/$(DEST)/processes.cf \
	test/$(DEST)/feature.cf \
	test/$(DEST)/vcs.cf \
	test/$(DEST)/cfe_internal.cf \
	test/$(DEST)/reports.cf \
	test/$(DEST)/guest_environments.cf \
	test/$(DEST)/bundles.cf \
	test/$(DEST)/services.cf \
	test/$(DEST)/common.cf \
	test/$(DEST)/users.cf \
	test/$(DEST)/storage.cf \
	test/$(DEST)/packages.cf \
	test/$(DEST)/paths.cf \
	test/$(DEST)/files.cf \
	test/$(DEST)/databases.cf \
	test/$(DEST)/edit_xml.cf \
	test/$(DEST)/examples.cf \
	test/$(DEST)/monitor.cf \
	test/$(DEST)/stdlib.cf

$(DEST)/evolve_freelib.cf: src/includes/param_parser.cf src/includes/param_file_picker.cf src/$(DEST)/evolve_freelib.cf
	cp src/$(DEST)/evolve_freelib.cf $(DEST)
	$(eflmaker) --tar $(DEST)/evolve_freelib.cf \
		--tag param_parser -i src/includes/param_parser.cf
	$(eflmaker) --tar $(DEST)/evolve_freelib.cf \
		--tag param_file_picker -i src/includes/param_file_picker.cf

.PHONY: check
check: $(cfstdlib) $(DEST)/evolve_freelib.cf
	printf "Checking...\n"
	$(CF_PROMISES) -V | grep $(VERSION) && echo PASS
	cp $(DEST)/evolve_freelib.cf test/$(DEST)/
	cd test/masterfiles; $(CF_PROMISES) -cf ./promises.cf && echo PASS

$(cfstdlib): .stdlib

.stdlib:
	cd test/masterfiles/lib; svn export --force $(CF_REPO)/masterfiles/trunk/lib/$(VERSION)
	touch $@

.PHONY: clean
clean:
	rm -fr masterfiles/*
	rm -fr test/$(DEST)

.PHONY: help
help:
	$(MAKE) --print-data-base --question |           \
		awk '/^[^.%][-A-Za-z0-9_]*:/                  \
			{ print substr($$q, 1, length($$1)-1) }' | \
		sort |                                        \
		pr --omit-pagination --width=80 --columns=4
