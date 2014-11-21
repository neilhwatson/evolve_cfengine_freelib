CF_PROMISES = cf-promises
VERSION = 3.6
CF_REPO = https://github.com/cfengine

eflmaker = ./bin/eflmaker
cfstdlib = \
	test/$(VERSION)/commands.cf \
	test/$(VERSION)/processes.cf \
	test/$(VERSION)/feature.cf \
	test/$(VERSION)/vcs.cf \
	test/$(VERSION)/cfe_internal.cf \
	test/$(VERSION)/reports.cf \
	test/$(VERSION)/guest_environments.cf \
	test/$(VERSION)/bundles.cf \
	test/$(VERSION)/services.cf \
	test/$(VERSION)/common.cf \
	test/$(VERSION)/users.cf \
	test/$(VERSION)/storage.cf \
	test/$(VERSION)/packages.cf \
	test/$(VERSION)/paths.cf \
	test/$(VERSION)/files.cf \
	test/$(VERSION)/databases.cf \
	test/$(VERSION)/edit_xml.cf \
	test/$(VERSION)/examples.cf \
	test/$(VERSION)/monitor.cf \
	test/$(VERSION)/stdlib.cf

masterfiles/evolve_freelib.cf: src/includes/param_parser.cf src/includes/param_file_picker.cf src/masterfiles/evolve_freelib.cf
	cp src/masterfiles/evolve_freelib.cf masterfiles/
	$(eflmaker) --tar masterfiles/evolve_freelib.cf \
		--tag param_parser -i src/includes/param_parser.cf
	$(eflmaker) --tar masterfiles/evolve_freelib.cf \
		--tag param_file_picker -i src/includes/param_file_picker.cf

.PHONY: check
check: $(cfstdlib) masterfiles/evolve_freelib.cf
	printf "Checking...\n"
	cp masterfiles/evolve_freelib.cf test/
	cd test; $(CF_PROMISES) -cf ./promises.cf

$(cfstdlib):
	cd test; svn export $(CF_REPO)/masterfiles/trunk/lib/$(VERSION)

.PHONY: clean
clean:
	rm -fr masterfiles/*
	rm -fr test/$(VERSION)

.PHONY: help
help:
	$(MAKE) --print-data-base --question |           \
		awk '/^[^.%][-A-Za-z0-9_]*:/                  \
			{ print substr($$q, 1, length($$1)-1) }' | \
		sort |                                        \
		pr --omit-pagination --width=80 --columns=4
