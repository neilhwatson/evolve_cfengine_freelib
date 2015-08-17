CF_AGENT    = $(HOME)/bin/cf-agent
VERSION     = 3.7
LIB         = lib/$(VERSION)
EFL_LIB     = masterfiles/$(LIB)/EFL
CF_REPO     = https://github.com/cfengine
CSVTOJSON   = ./bin/eflconvert -i csv -o json
CSVTOYAML   = ./bin/eflconvert -i csv -o yaml
APT_GET     = /usr/bin/apt-get --quiet --yes

# Don't changes this, it's hard coded in some CF policy data
TEST_DIR    = /tmp/efl_test

EFL_FILES   = \
	$(EFL_LIB)/efl_common.cf \
	$(EFL_LIB)/evolve_freelib.cf \
	$(EFL_LIB)/efl_update.cf

EFL_TEST_FILES   = \
	test/$(EFL_LIB)/efl_common.cf \
	test/$(EFL_LIB)/evolve_freelib.cf \
	test/$(EFL_LIB)/efl_update.cf

AUTORUN = masterfiles/services/autorun/efl.cf

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

tests       =   \
	005_efl_test \
	006_efl_test \
	007_efl_test \
	008_efl_test \
	009_efl_test \
	010_efl_test \
	011_efl_test \
	012_efl_test \
	013_efl_test \
	014_efl_test \
	015_efl_test \
	016_efl_test \
	017_efl_test \
	018_efl_test \
	022_efl_test \
	023_efl_test \
	024_efl_test \
	025_efl_test \
	026_efl_test \
	027_efl_test \
	028_efl_test \
	029_efl_test \
	030_efl_test \
	031_efl_test \
	031a_efl_test \
	031b_efl_test \
	032_efl_test \
	033_efl_test \
	034_efl_test \
	037_efl_test \
	038_efl_test \
	039_efl_test \
	250_efl_test \
	251_efl_test \
	252_efl_test \
	260_efl_test \
	261_efl_test \
	262_efl_test \
	264_efl_test \
	265_efl_test \
	266_efl_test \
	270_efl_test \
	271_efl_test \
	272_efl_test \
	273_efl_test \
	290_efl_test \
	291_efl_test \
	292_efl_test \
	293_efl_test \

test_files = test/251/03_cfengine_templates.json 

# $(call cf_agent_grep_test ,target_class,result_string)
define cf_agent_grep_test 
 	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $1 | \
	perl -e '                            \
	while (<STDIN>) { $$OUTPUT .= $$_  } \
		if ( $$OUTPUT =~ m|\A$2\Z| )      \
			{ print "PASS: $@\n" }         \
		else                              \
			{ die "FAIL: $@" }'
endef

# $(call search_and_replace,search_regex replace_string target_file)
define search_and_replace
	perl -pi -e 's/$1/$2/' $3
endef
	
define md5cmp_two_files
	ONE=$$(md5sum $1|awk '{print $$1}')  \
	TWO=$$(md5sum $2|awk '{print $$1}'); \
	for i in $1 $2; do \
		if [ ! -f $1 ]; then echo "FAIL $@ $1 does not exist"; exit 1; fi \
	done; \
	if [ "0$$ONE" = "0$$TWO" ]; then \
		echo "PASS $1 ($$ONE) == $2 ($$TWO)"; \
	else \
		echo "FAIL $@ $1 ($$ONE) != $2 ($$TWO)"; \
		exit 1; \
	fi
endef

define 037_efl_test
	echo foo > $(TEST_DIR)/037/01/a.txt 
	/bin/systemctl start $(test_systemd_def)
	if [ -f $(TEST_DIR)/$1/01/restarted ]; then rm $(TEST_DIR)/$1/01/restarted; fi
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec/; rspec spec/localhost/$1_efl_test.rb
	echo PASS: $@
endef

define 038_efl_test
	/bin/systemctl stop $(test_systemd_def)
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $1_efl_test
	cd test/serverspec/; rspec spec/localhost/$1_efl_test.rb
	echo PASS: $@
endef

define 250_efl_test
	rm -f $(TEST_DIR)/250/cfengine_template
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	$(call md5cmp_two_files,$(TEST_DIR)/250/cfengine_template,test/250/cfengine_template)
	echo PASS: $@
endef

define 260_efl_test
	echo foo > $(TEST_DIR)/260/cfengine_template
	/bin/systemctl start $(test_systemd_def)
	if [ -f $(TEST_DIR)/260/restarted ]; then rm $(TEST_DIR)/260/restarted; fi
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec/; rspec spec/localhost/260_efl_test.rb
	echo PASS: $@
endef

define 270_efl_test
	cp $(test_daemon_src) $(TEST_DIR)/
	cp $(test_systemd_def_src) /etc/systemd/system/
	systemctl disable $(test_systemd_def)
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	systemctl is-enabled $(test_systemd_def)
	rm /etc/systemd/system/$(test_systemd_def)
	echo PASS: $@
endef

define 272_efl_test
	cp $(test_daemon_src) $(TEST_DIR)/
	cp $(test_systemd_def_src) /etc/systemd/system/
	systemctl enable $(test_systemd_def)
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	systemctl is-enabled $(test_systemd_def) |grep disabled
	rm /etc/systemd/system/$(test_systemd_def)
	echo PASS: $@
endef

define 290_efl_test
	rm -fr $(TEST_DIR)/290_master
	git clone https://github.com/neilhwatson/vim_cf3.git $(TEST_DIR)/290_master
	cd $(TEST_DIR)/290_master; git status > $(TEST_DIR)/290_master.status
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@ 
	cd $(TEST_DIR)/290_test; git status > $(TEST_DIR)/290_test.status
	$(call md5cmp_two_files,$(TEST_DIR)/290_test.status,$(TEST_DIR)/290_master.status)
	echo PASS: $@
endef

define 291_efl_test
	rm -f $(TEST_DIR)/290_test.status*
	rm -f $(TEST_DIR)/290_test/README*
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd $(TEST_DIR)/290_test; git status > $(TEST_DIR)/290_test.status
	$(call md5cmp_two_files,$(TEST_DIR)/290_test.status,$(TEST_DIR)/290_master.status)
	echo PASS: $@
endef

print-%: ; @echo $* is $($*)

.PHONY: all
all: $(EFL_FILES) $(AUTORUN) $(EFL_TEST_FILES)

$(EFL_FILES): $(EFL_LIB) src/includes/param_parser.cf src/includes/param_file_picker.cf src/$@
	cp src/$@ $@
	$(eflmaker) --tar $@ \
		--tag param_parser -i src/includes/param_parser.cf
	$(eflmaker) --tar $@ \
		--tag param_file_picker -i src/includes/param_file_picker.cf

$(EFL_TEST_FILES): $(EFL_FILES) $(cfstdlib) test/$(EFL_LIB)
	cp -r $(EFL_LIB)/$(notdir $@) test/$(EFL_LIB)

$(TEST_DIR):
	mkdir -p $@

$(EFL_LIB):
	mkdir -p $@

test/$(EFL_LIB):
	mkdir -p $@

$(AUTORUN): src/masterfiles/services/autorun src/$@
	mkdir -p masterfiles/services/autorun
	cp -r src/$@ $@

$(cfstdlib): .stdlib

.stdlib:
	cd test/masterfiles/lib; svn export --force $(CF_REPO)/masterfiles/trunk/lib/$(VERSION)
	touch $@

#
# Test, tests, and more tests
#
.PHONY: version
version:
	prove t/00_version.t

.PHONY: syntax
syntax: $(cfstdlib) test/$(EFL_LIB) $(EFL_TEST_FILES)
	prove t/01_syntax.t

#
# For converting csv files
#
test/masterfiles/efl_data/efl_test_classes/%.json:
	CSVTOJSON="../../../../$(CSVTOJSON)" \
	$(MAKE) --directory=test/masterfiles/efl_data/efl_test_classes \
		$*.json

test/masterfiles/efl_data/efl_test_vars/%.json:
	CSVTOJSON="../../../../$(CSVTOJSON)" \
	$(MAKE) --directory=test/masterfiles/efl_data/efl_test_vars\
		$*.json

# TODO does this ensure efl_main.json is made?
test/masterfiles/efl_data/efl_main.json: \
  test/masterfiles/efl_data/efl_main.csv
	CSVTOJSON="../../../$(CSVTOJSON)" \
	$(MAKE) --directory=test/masterfiles/efl_data/ efl_main.json

test/masterfiles/efl_data/%.json:
	CSVTOJSON="../../../$(CSVTOJSON)" \
	$(MAKE) --directory=test/masterfiles/efl_data/ $*.json

#
# Calculate json dependencies
#  TODO yaml
efl_data_csv_files  = $(wildcard test/masterfiles/efl_data/*.csv)
efl_data_json_files = $(patsubst %.csv,%.json,$(efl_data_csv_files))

efl_test_classes_csv_files  = \
	  $(wildcard test/masterfiles/efl_data/efl_test_classes/*.csv)
efl_test_classes_json_files = \
	  $(patsubst %.csv,%.json,$(efl_test_classes_csv_files))

efl_test_vars_csv_files  = \
	  $(wildcard test/masterfiles/efl_data/efl_test_vars/*.csv)
efl_test_vars_json_files = \
	  $(patsubst %.csv,%.json,$(efl_test_vars_csv_files))

#
# iteration order tests 
#
# TODO yaml order test

io_csv_test_files = \
test/masterfiles/efl_data/efl_test_classes/01_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/02_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/03_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/04_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/05_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/06_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/07_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/08_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/09_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/10_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/11_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/12_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/13_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/14_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/15_iteration_order.csv \
test/masterfiles/efl_data/efl_test_classes/16_iteration_order.csv
io_json_test_files = $(subst csv,json,$(io_csv_test_files))
.PHONY: iteration_order
iteration_order: version syntax test/masterfiles/efl_data/efl_main.json \
  $(io_json_test_files)
	prove t/iteration_order.t

#
# Test bundles that test other bundles
#
.SECONDEXPANSION:
efl_test_bundles = efl_test_classes efl_test_vars
.PHONY: $(efl_test_bundles)
$(efl_test_bundles): version syntax \
  test/masterfiles/efl_data/efl_main.json \
  test/masterfiles/efl_data/$$@/$$@.json
	prove t/*$@*.t

#
# Testing class generation bundles
#
test_bundles_with_efl_test_classes = \
  efl_class_returnszero \
  efl_class_cmd_regcmp \
  efl_class_expression \
  efl_class_classmatch \
  efl_class_iprange
.PHONY: $(test_bundles_with_efl_test_classes)
$(test_bundles_with_efl_test_classes): version syntax $(efl_test_bundles) \
  test/masterfiles/efl_data/efl_main.json \
  test/masterfiles/efl_data/$$@.json \
  test/masterfiles/efl_data/efl_test_classes/$$@.json
	prove t/$@_csv.t
	prove t/$@_json.t

##
.PHONY: efl_class_hostname
efl_class_hostname: version syntax $(efl_test_bundles) \
  test/masterfiles/efl_data/efl_main.json \
  test/masterfiles/efl_data/efl_class_hostname-017_test_class.txt \
  test/masterfiles/efl_data/efl_test_classes/$$@.json
	prove t/$@_csv.t
	prove t/$@_json.t

##
.PHONY: efl_class_hostname2
efl_class_hostname2: version syntax $(efl_test_bundles) \
  test/masterfiles/efl_data/efl_main.json \
  test/masterfiles/efl_data/efl_class_hostname2.json \
  test/masterfiles/efl_data/efl_test_classes/$$@.json
	prove t/$@_csv.t
	prove t/$@_json.t

##
test_bundles_with_efl_test_vars = efl_global_strings

.PHONY: $(test_bundles_with_efl_test_vars)
$(test_bundles_with_efl_test_vars): version syntax $(efl_test_bundles) \
  test/masterfiles/efl_data/efl_main.json \
  test/masterfiles/efl_data/$$@.json \
  test/masterfiles/efl_data/efl_test_vars/$$@.json
	prove t/$@_csv.t
	prove t/$@_json.t

##
.PHONY: efl_global_slists
efl_global_slists: version syntax \
  test/masterfiles/efl_data/efl_main.json \
  test/masterfiles/efl_data/efl_global_slists.json 
	prove t/efl_global_slists.t

#
# Testing normal agent bundles
#
test_efl_bundles = \
	efl_file_perms \
	efl_sysctl_live \
	efl_sysctl_conf_file \
	efl_command \
	efl_link \
	efl_delete_files \
	efl_copy_files 

.PHONY: $(test_efl_bundles)
$(test_efl_bundles): version syntax \
  test/masterfiles/efl_data/efl_main.json \
  test/masterfiles/efl_data/$$@.json
	prove t/$@.t

test_efl_packages_bundles = \
	efl_packages \
	efl_packages_via_cmd \
	efl_packages_new

.PHONY: $(test_efl_packages_bundles)
$(test_efl_packages_bundles): version syntax \
  test/masterfiles/efl_data/efl_main.json \
  test/masterfiles/efl_data/efl_packages.json \
  test/masterfiles/efl_data/efl_packages_new.json
	prove t/efl_packages.t :: --bundle $@

#
# efl_service* bundles testing
#
test_daemon:
	TEST_DIR=$(TEST_DIR) \
	$(MAKE) --directory=test/test_daemon all

test_efl_service_bundles = \
	efl_start_service \
	efl_service_recurse

.PHONY: $(test_efl_service_bundles)
$(test_efl_service_bundles): version syntax test_daemon \
  test/masterfiles/efl_data/efl_main.json \
  test/masterfiles/efl_data/$$@.json 
	prove t/$@.t

#
# TODO
#

PHONY: 039_efl_test
039_efl_test: 037_efl_test test/039/01_efl_service_recurse.json
	echo Starting test $@
	$(call 037_efl_test,037)

test/039/01_efl_service_recurse.json: test/037/01_efl_service_recurse.csv
	$(CSVTOJSON) -b efl_service_recurse < $^ > $@

037_src_files = $(TEST_DIR)/037/src/a.txt $(TEST_DIR)/037/src/b.txt \
	$(TEST_DIR)/037/src/c.html
PHONY: 037_efl_test # Test if service is restarted
037_efl_test: $(037_src_files) $(TEST_DIR)/037/01/ $(test_daemon_files)
	$(call 037_efl_test,037)

PHONY: 038_efl_test # Test if service is started
038_efl_test: $(037_src_files) $(TEST_DIR)/037/01/ $(test_daemon_files)
	$(call 038_efl_test,037)

$(037_src_files): $(TEST_DIR)/037/src/
	echo $@ >  $@

$(TEST_DIR)/037/src/ $(TEST_DIR)/037/01/:
	mkdir -p	$@

PHONY: 251_efl_test
251_efl_test: 250_efl_test test/251/03_cfengine_templates.json
	$(call 250_efl_test)

test/251/03_cfengine_templates.json: test/250/03_cfengine_templates.csv
	$(CSVTOJSON) -b efl_edit_template < $^ > $@

PHONY: 250_efl_test
250_efl_test: syntax $(TEST_DIR)/250/cfengine_template.tmp $(TEST_DIR)/250/
	$(call 250_efl_test)

$(TEST_DIR)/250/cfengine_template.tmp: $(TEST_DIR)/250/
	cp test/250/cfengine_template.tmp $^

$(TEST_DIR)/250/:
	mkdir -p $@

PHONY: 252_efl_test
252_efl_test: 250_efl_test $(TEST_DIR)/252 $(TEST_DIR)/252/cfengine_template.mustache
	rm -f $(TEST_DIR)/252/cfengine_template
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D 250_efl_test
	$(call md5cmp_two_files,$(TEST_DIR)/252/cfengine_template,test/250/cfengine_template)
	echo PASS: $@

$(TEST_DIR)/252/cfengine_template.mustache: $(TEST_DIR)/252
	cp test/250/cfengine_template.mustache $^

$(TEST_DIR)/252/:
	mkdir -p $@

PHONY: 260_efl_test Test if service is restarted
260_efl_test: syntax $(TEST_DIR)/260/cfengine_template.tmp $(TEST_DIR)/260/ $(test_daemon_files)
	$(call 260_efl_test)

$(TEST_DIR)/260/cfengine_template.tmp: $(TEST_DIR)/260/
	cp test/260/cfengine_template.tmp $@

PHONY: 261_efl_test Test if service is started
261_efl_test: 260_efl_test 
	$(call 038_efl_test,260)

$(TEST_DIR)/260/:
	mkdir -p	$@

PHONY: 262_efl_test # Test if service template config is promised
262_efl_test: 260_efl_test 
	$(call md5cmp_two_files,$(TEST_DIR)/260/cfengine_template,test/260/cfengine_template)
	echo PASS: $@

PHONY: 264_efl_test
264_efl_test: test/264/01_efl_service.json
	$(call 260_efl_test)

test/264/01_efl_service.json: test/260/01_efl_service.csv
	$(CSVTOJSON) -b efl_service < $^ > $@

PHONY: 265_efl_test
265_efl_test: 264_efl_test
	$(call md5cmp_two_files,$(TEST_DIR)/260/cfengine_template,test/260/cfengine_template)

PHONY: 266_efl_test
266_efl_test: syntax $(test_daemon_files) $(TEST_DIR)/266/cfengine_template.mustache
	$(call 260_efl_test)
	$(call md5cmp_two_files,$(TEST_DIR)/260/cfengine_template,test/260/cfengine_template)

$(TEST_DIR)/266/cfengine_template.mustache: $(TEST_DIR)/266
	cp test/260/cfengine_template.mustache $@

$(TEST_DIR)/266:
	mkdir -p	$@

PHONY: 270_efl_test
270_efl_test: syntax $(test_daemon_files)
	$(call 270_efl_test)

PHONY: 271_efl_test
271_efl_test: 270_efl_test test/271/01_efl_enable_service.json
	$(call 270_efl_test)

test/271/01_efl_enable_service.json: test/270/01_efl_enable_service.csv
	$(CSVTOJSON) -b efl_enable_service < $< > $@

PHONY: 272_efl_test
272_efl_test: 270_efl_test
	$(call 272_efl_test)

PHONY: 273_efl_test
273_efl_test: 272_efl_test
	$(call 272_efl_test)

PHONY: 290_efl_test
290_efl_test: syntax
	$(call 290_efl_test)

PHONY: 291_efl_test
291_efl_test: syntax 290_efl_test
	$(call 291_efl_test)

PHONY: 292_efl_test
292_efl_test: syntax test/292/01_efl_rcs_pull.json
	$(call 290_efl_test)

PHONY: 293_efl_test
293_efl_test: syntax 292_efl_test test/292/01_efl_rcs_pull.json
	$(call 291_efl_test)

test/292/01_efl_rcs_pull.json: test/290/01_efl_rcs_pull.csv
	$(CSVTOJSON) -b efl_rcs_pull < $< > $@

.PHONY: check
# TODO how to make all json and yaml files here?
check: test/$(EFL_LIB) $(cfstdlib) $(EFL_FILES) \
  $(io_json_test_files) \
  $(efl_data_json_files) \
  $(efl_test_classes_json_files) \
  $(efl_test_vars_json_files)
	prove t/*.t

.PHONY: clean
clean:
	/bin/systemctl stop $(test_systemd_def); \
	rm -fr masterfiles/*
	rm -f .stdlib
	rm -fr test/$(EFL_LIB)
	$(MAKE) --directory=test/masterfiles/efl_data/ clean
	$(MAKE) --directory=test/masterfiles/efl_data/efl_test_classes clean
	$(MAKE) --directory=test/masterfiles/efl_data/efl_test_vars clean
	$(MAKE) --directory=test/test_daemon clean
	rm -fr $(TEST_DIR)
	rm -f /tmp/ssh/ssh_config
	rm -f $(test_files)


.PHONY: help
help:
	$(MAKE) --print-data-base --question |           \
		awk '/^[^.%][-A-Za-z0-9_]*:/                  \
			{ print substr($$q, 1, length($$1)-1) }' | \
		sort |                                        \
		pr --omit-pagination --width=80 --columns=4
