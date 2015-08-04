CF_PROMISES = $(HOME)/bin/cf-promises
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

# 1003_efl_test
tests       =   \
	version      \
	syntax       \
	1001_efl_test \
	1002_efl_test \
	003_efl_test \
	004_efl_test \
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
	019_efl_test \
	020_efl_test \
	021_efl_test \
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
	035_efl_test \
	036_efl_test \
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
	280_efl_test \
	281_efl_test \
	290_efl_test \
	291_efl_test \
	292_efl_test \
	293_efl_test \

test_files = \
	test/020/01_efl_sysctl_live.json \
	test/251/03_cfengine_templates.json \

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

define test_sysctl_live
	/sbin/sysctl vm.swappiness='67'
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $(1)_efl_test
	cd test/serverspec; rspec spec/localhost/019_efl_test_spec.rb
	/sbin/sysctl vm.swappiness='60'
endef

define test_sysclt_conf
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $(1)_efl_test
	cd test/serverspec; rspec spec/localhost/021_efl_test_spec.rb
	echo '07a47f3db13458ebc93b334973cc8720 /etc/sysctl.conf' |md5sum -c 
endef

define 023_024_test
	rm -f $(TEST_DIR)/023_efl_test
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	echo 'a95cee7d8d28c9a1d6f4cd86100d341c $(TEST_DIR)/023_efl_test' |md5sum -c
	echo PASS: $@
endef

define make_link_targets
	for i in 01 02 03; do echo $$i > $(TEST_DIR)_$$i; done
endef

define del_link_targets
	for i in 01 02 03; do rm $(TEST_DIR)_$$i /var$(TEST_DIR)_$${i}_link; done
endef

define 027_028_test
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec; rspec spec/localhost/027_efl_test_spec.rb
	echo PASS: $@
endef

define 029_030_test
	rm -fr $(TEST_DIR)/029 $(TEST_DIR)/030 /tmp/ssh/
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec; rspec spec/localhost/029_efl_test_spec.rb
	$(call md5cmp_two_files,/etc/ssh/ssh_config,/tmp/ssh/ssh_config)
	$(call md5cmp_two_files,$(TEST_DIR)/029/01/a.txt,$(TEST_DIR)/027/02/a.txt)
	$(call md5cmp_two_files,$(TEST_DIR)/029/01/b.txt,$(TEST_DIR)/027/02/b.txt)
	echo PASS $@
endef

define packages_test
	$(APT_GET) install nano
	$(APT_GET) remove e3
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec; rspec spec/localhost/031.elf_test_spec.rb
	$(APT_GET) remove nano e3
	cd test/serverspec; rspec spec/localhost/031.elf_post_test_spec.rb
	echo PASS $@
endef

define 035_036_test
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec; rspec spec/localhost/035_service.rb
	systemctl stop $(test_systemd_def)
	echo PASS: $@
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

define 280_efl_test
	rm -fr /tmp/efl_test/280/*
	test -d /tmp/efl_test/280/sub || mkdir -p /tmp/efl_test/280/sub
	touch /tmp/efl_test/280/a
	touch /tmp/efl_test/280/b
	touch /tmp/efl_test/280/d
	chmod -R 444 /tmp/efl_test/280
	chmod -R 600 /tmp/efl_test/280/sub
	chown -R 12000:12000 /tmp/efl_test/280
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@ -vl > agent.txt
	cd test/serverspec; rspec spec/localhost/280_efl_test.rb
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
all: $(EFL_FILES) $(AUTORUN)

$(EFL_FILES): $(EFL_LIB) src/includes/param_parser.cf src/includes/param_file_picker.cf src/$@
	cp src/$@ $@
	$(eflmaker) --tar $@ \
		--tag param_parser -i src/includes/param_parser.cf
	$(eflmaker) --tar $@ \
		--tag param_file_picker -i src/includes/param_file_picker.cf

$(EFL_LIB):
	mkdir -p $@

$(AUTORUN): src/masterfiles/services/autorun src/$@
	mkdir -p masterfiles/services/autorun
	cp -r src/$@ $@

.PHONY: check
check: test/$(EFL_LIB) $(cfstdlib) $(EFL_FILES) $(tests)
	@echo PASSED ALL TESTS

test/$(EFL_LIB): $(EFL_FILES)
	mkdir -p $@
	cp -r $(EFL_LIB)/* test/$(EFL_LIB)/

$(cfstdlib): .stdlib

.stdlib:
	cd test/masterfiles/lib; svn export --force $(CF_REPO)/masterfiles/trunk/lib/$(VERSION)
	touch $@

.PHONY: version
version:
	$(CF_PROMISES) -V | grep $(VERSION) && echo PASS: $@

.PHONY: syntax
syntax: $(cfstdlib) test/$(EFL_LIB)
	OUTPUT=$$($(CF_PROMISES) -cf ./test/masterfiles/promises.cf 2>&1) ;\
	if [ -z "$$OUTPUT" ] ;\
	then                  \
		echo PASS: $@     ;\
	else                  \
		echo FAIL: $@     ;\
		echo $$OUTPUT     ;\
		exit 1            ;\
	fi                    

#
# Test order of iteration
#
1001_1002_1003_efl_test_result = R: PASS, any, efl_main order 1\nR: PASS, any, efl_main order 2\nR: PASS, any, efl_main order 3\nR: PASS, any, efl_main order 4\nR: PASS, any, efl_main order 5\nR: PASS, any, efl_main order 6\nR: PASS, any, efl_main order 7\nR: PASS, any, efl_main order 8\nR: PASS, any, efl_main order 9\nR: PASS, any, efl_main order 10\nR: PASS, any, efl_main order 11\nR: PASS, any, efl_main order 12\nR: PASS, any, efl_main order 13\nR: PASS, any, efl_main order 14\nR: PASS, any, efl_main order 15\nR: PASS, any, efl_main order 16

.PHONY: 1001_efl_test
1001_efl_test: syntax
	$(call cf_agent_grep_test, $@,$(1001_1002_1003_efl_test_result))

.PHONY: 1002_efl_test
1001_csv_test_files  = $(wildcard test/1001/*.csv)
1002_csv_test_files  = $(subst 1001,1002,$(1001_csv_test_files))
1002_json_test_files = $(patsubst %.csv,%.json,$(1002_csv_test_files))

1002_efl_test: 1001_efl_test test/1002/efl_main.json $(1002_json_test_files)
	$(call cf_agent_grep_test, $@,$(1001_1002_1003_efl_test_result))

test/1002/efl_main.json: test/1001/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,1001,1002,$@) 
	$(call search_and_replace,\.csv,\.json,$@) 

test/1002/%_efl_test_simple.json: test/1001/%_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@

# Disabled due to bug 7372
#.PHONY: 1003_efl_test
#1001_csv_test_files  = $(wildcard test/1001/*.csv)
#1003_csv_test_files  = $(subst 1001,1003,$(1001_csv_test_files))
#1003_yaml_test_files = $(patsubst %.csv,%.yaml,$(1003_csv_test_files))
#
#1003_efl_test: 1001_efl_test test/1003/efl_main.yaml $(1003_yaml_test_files)
#	$(call cf_agent_grep_test, $@,$(1001_1002_1003_efl_test_result))
#
#test/1003/efl_main.yaml: test/1001/efl_main.csv
#	$(CSVTOYAML) -b efl_main < $< > $@
#	$(call search_and_replace,1001,1003,$@) 
#	$(call search_and_replace,\.csv,\.yaml,$@) 
#
#test/1003/%_efl_test_simple.yaml: test/1001/%_efl_test_simple.csv
#	$(CSVTOYAML) -b efl_test_simple < $^ > $@

#
#
#
.PHONY: 004_efl_test
004_efl_test_result = R: PASS, 004_true_true, Class if /bin/true\nR: PASS, 004_true_false, Class if /bin/false\nR: PASS, 004_false_false, Is not true
004_efl_test: 003_efl_test test/004/efl_main.json test/004/01_efl_returnszero.json test/004/02_efl_test_simple.json
	$(call cf_agent_grep_test, $@,$(004_efl_test_result))

test/004/efl_main.json: test/003/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,003,004,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/004/01_efl_returnszero.json: test/003/01_efl_returnszero.csv
	$(CSVTOJSON) -b efl_class_returnszero < $^ > $@
	$(call search_and_replace,003,004,$@) 

test/004/02_efl_test_simple.json: test/003/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,003,004,$@) 

.PHONY: 003_efl_test
003_efl_test_result = R: PASS, 003_true_true, Class if /bin/true\nR: PASS, 003_true_false, Class if /bin/false\nR: PASS, 003_false_false, Is not true
003_efl_test:
	$(call cf_agent_grep_test, $@,$(003_efl_test_result))

005_006_efl_test_result = R: efl_global_lists\.ntp_servers  => \[ntp1\.example\.com\]\nR: efl_global_lists\.ntp_servers  => \[ntp2\.example\.com\]\nR: efl_global_lists\.ntp_servers  => \[ntp3\.example\.com\]\n(R: efl_global_lists\.name_servers => \[10\.0\.0\.\d{1}\]\n){3}(R: efl_global_lists\.web_servers  => \[\d{1}\.example\.com\]\n{0,1}){3}
.PHONY: 006_efl_test
006_efl_test:  005_efl_test test/006/efl_main.json test/006/01_efl_global_slists.json test/006/02_efl_dump_strings.json test/006/name_servers.txt
	$(call cf_agent_grep_test, $@,$(005_006_efl_test_result))

test/006/efl_main.json: test/005/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,005,006,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/006/01_efl_global_slists.json: test/005/01_efl_global_slists.csv
	$(CSVTOJSON) -b efl_global_slists < $^ > $@
	$(call search_and_replace,005,006,$@) 

test/006/02_efl_dump_strings.json: test/005/02_efl_dump_strings.csv
	$(CSVTOJSON) -b efl_dump_strings < $^ > $@
	$(call search_and_replace,005,006,$@) 

test/006/name_servers.txt: test/005/name_servers.txt
	cp test/005/name_servers.txt test/006/

.PHONY: 005_efl_test
005_efl_test: syntax
	$(call cf_agent_grep_test, $@,$(005_006_efl_test_result))

007_008_efl_test_result = R: Name => \[efl_global_strings\.main_efl_dev\] Value => \[Neil H\. Watson \(neil\@watson-wilson\.ca\)\] Promisee => \[efl_development\]\nR: Name => \[efl_global_strings\.gateway\] Value => \[2001:DB8::1\] Promisee => \[efl_development\]\nR: Name => \[efl_global_strings\.cf_major\] Value => \[3\] Promisee => \[efl_development data_expand\]
.PHONY: 008_efl_test
008_efl_test:  007_efl_test test/008/efl_main.json test/008/01_efl_global_strings.json test/008/02_efl_dump_strings.json
	$(call cf_agent_grep_test, $@,$(007_008_efl_test_result))

test/008/efl_main.json: test/007/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,007,008,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/008/01_efl_global_strings.json: test/007/01_efl_global_strings.csv
	$(CSVTOJSON) -b efl_global_strings < $^ > $@
	$(call search_and_replace,007,008,$@) 

test/008/02_efl_dump_strings.json: test/007/02_efl_dump_strings.csv
	$(CSVTOJSON) -b efl_dump_strings < $^ > $@
	$(call search_and_replace,007,008,$@) 

.PHONY: 007_efl_test
007_efl_test:
	$(call cf_agent_grep_test, $@,$(007_008_efl_test_result))

.PHONY: 010_efl_test
010_efl_test: 010_efl_test_result = R: PASS, 010_test_class_01, true if output matches\nR: PASS, 010_test_class_02, true if output does not match\nR: PASS, 010_test_class_03, should not match\nR: PASS, 010_test_class_04, true if output is there

010_efl_test: 009_efl_test test/010/01_efl_class_cmd_regcmp.json test/010/02_efl_test_simple.json test/010/efl_main.json
	$(call cf_agent_grep_test, $@,$(010_efl_test_result))

test/010/efl_main.json: test/009/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,009,010,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/010/01_efl_class_cmd_regcmp.json: test/009/01_efl_class_cmd_regcmp.csv
	$(CSVTOJSON) -b efl_class_cmd_regcmp < $^ > $@
	$(call search_and_replace,009,010,$@) 

test/010/02_efl_test_simple.json: test/009/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,009,010,$@) 

009_efl_test: 009_efl_test_result = R: PASS, 009_test_class_01, true if output matches\nR: PASS, 009_test_class_02, true if output does not match\nR: PASS, 009_test_class_03, should not match\nR: PASS, 009_test_class_04, true if output is there
009_efl_test:
	$(call cf_agent_grep_test, $@,$(009_efl_test_result))

.PHONY: 012_efl_test
012_efl_test: 012_efl_test_result = R: PASS, 012_test_class_01, pass if both classes match\nR: PASS, 012_test_class_02, pass if either class matches\nR: PASS, 012_test_class_03, pass if neither class matches

012_efl_test: 011_efl_test test/012/01_efl_class_expression.json test/012/02_efl_test_simple.json test/012/efl_main.json
	$(call cf_agent_grep_test, $@,$(012_efl_test_result))

test/012/efl_main.json: test/011/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,011,012,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/012/01_efl_class_expression.json: test/011/01_efl_class_expression.csv
	$(CSVTOJSON) -b efl_class_expression < $^ > $@
	$(call search_and_replace,011,012,$@) 

test/012/02_efl_test_simple.json: test/011/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,011,012,$@) 

.PHONY: 011_efl_test
011_efl_test: 011_efl_test_result = R: PASS, 011_test_class_01, pass if both classes match\nR: PASS, 011_test_class_02, pass if either class matches\nR: PASS, 011_test_class_03, pass if neither class matches
011_efl_test:
	$(call cf_agent_grep_test, $@,$(011_efl_test_result))

.PHONY: 014_efl_test
014_efl_test: 014_efl_test_result = R: PASS, 014_test_class_01, pass\nR: PASS, 014_test_class_02, pass\nR: PASS, 014_test_class_03, pass if class never matches
014_efl_test: 013_efl_test test/014/01_efl_class_classmatch.json test/014/02_efl_test_simple.json test/014/efl_main.json
	$(call cf_agent_grep_test, $@,$(014_efl_test_result))

test/014/efl_main.json: test/013/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,013,014,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/014/01_efl_class_classmatch.json: test/013/01_efl_class_classmatch.csv
	$(CSVTOJSON) -b efl_class_classmatch< $^ > $@
	$(call search_and_replace,013,014,$@) 

test/014/02_efl_test_simple.json: test/013/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,013,014,$@) 

.PHONY: 013_efl_test
013_efl_test: 013_efl_test_result = R: PASS, 013_test_class_01, pass\nR: PASS, 013_test_class_02, pass\nR: PASS, 013_test_class_03, pass if class never matches
013_efl_test:
	$(call cf_agent_grep_test, $@,$(013_efl_test_result))

.PHONY: 016_efl_test
016_efl_test: 016_efl_test_result = R: PASS, 016_test_class_01, pass ipv4\nR: PASS, 016_test_class_03, pass if class never matches
# For when ipv6 support in iprange is available: https://dev.cfengine.com/issues/6875
#016_efl_test: 016_efl_test_result = R: PASS, 016_test_class_01, pass ipv4\nR: PASS, 016_test_class_02, pass ipv6\nR: PASS, 016_test_class_03, pass if class never matches
016_efl_test: 015_efl_test test/016/01_efl_class_iprange.json test/016/02_efl_test_simple.json test/016/efl_main.json
	$(call cf_agent_grep_test, $@,$(016_efl_test_result))

test/016/efl_main.json: test/015/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,015,016,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/016/01_efl_class_iprange.json: test/015/01_efl_class_iprange.csv
	$(CSVTOJSON) -b efl_class_iprange< $^ > $@
	$(call search_and_replace,015,016,$@) 

test/016/02_efl_test_simple.json: test/015/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,015,016,$@) 

.PHONY: 015_efl_test
015_efl_test: 015_efl_test_result = R: PASS, 015_test_class_01, pass ipv4\nR: PASS, 015_test_class_03, pass if class never matches
# For when ipv6 support in iprange is available: https://dev.cfengine.com/issues/6875
#015_efl_test: 015_efl_test_result = R: PASS, 015_test_class_01, pass ipv4\nR: PASS, 015_test_class_02, pass ipv6\nR: PASS, 015_test_class_03, pass if class never matches
015_efl_test:
	$(call cf_agent_grep_test, $@,$(015_efl_test_result))

.PHONY: 017_efl_test
017_efl_test: 017_efl_test_result = R: PASS, 017_test_class, pass efl_class_hostname\nR: PASS, never, pass if never defined
017_efl_test:
	$(call cf_agent_grep_test, $@,$(017_efl_test_result))

.PHONY: 018_efl_test
018_efl_test: 018_efl_test_result = R: PASS, 018_test_class_01, pass efl_class_hostname2 01\nR: PASS, 018_test_class_02, pass efl_class_hostname2 02\nR: PASS, never, pass if never defined
018_efl_test:
	$(call cf_agent_grep_test, $@,$(018_efl_test_result))

.PHONY: 020_efl_test
020_efl_test: 019_efl_test test/020/01_efl_sysctl_live.json
	$(call test_sysctl_live,020)
	echo PASS: $@

test/020/01_efl_sysctl_live.json: test/019/01_efl_sysctl_live.csv
	$(CSVTOJSON) -b efl_sysctl_live < $^ > $@
	$(call search_and_replace,019,020,$@) 

.PHONY: 019_efl_test
019_efl_test:
	$(call test_sysctl_live,019)
	echo PASS: $@

.PHONY: 022_efl_test
022_efl_test: 021_efl_test test/022/01_efl_sysctl_conf_file.json
	$(call test_sysctl_conf,022)
	echo PASS: $@

test/022/01_efl_sysctl_conf_file.json: test/021/01_efl_sysctl_conf_file.csv
	$(CSVTOJSON) -b efl_sysctl_conf_file < $^ > $@

.PHONY: 021_efl_test
021_efl_test:
	$(call test_sysctl_conf,021)
	echo PASS: $@

.PHONY: 024_efl_test
024_efl_test: 023_efl_test test/024/01_efl_command.json
	$(call 023_024_test)

test/024/01_efl_command.json: test/023/01_efl_command.csv
	$(CSVTOJSON) -b efl_command < $^ > $@

.PHONY: 023_efl_test
023_efl_test: syntax $(TEST_DIR)
	$(call 023_024_test)

.PHONY: 026_efl_test
026_efl_test: 025_efl_test test/026/01_efl_link.json
	$(call make_link_targets)
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec; rspec spec/localhost/025_efl_test_spec.rb
	$(call del_link_targets)
	echo PASS: $@

test/026/01_efl_link.json: test/025/01_efl_link.csv
	$(CSVTOJSON) -b efl_link < $^ > $@

.PHONY: 025_efl_test
025_efl_test:
	$(call make_link_targets)
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec; rspec spec/localhost/025_efl_test_spec.rb
	$(call del_link_targets)
	echo PASS: $@

.PHONY: 028_efl_test
028_efl_test: 027_efl_test test/028/01_efl_delete_files.json
	$(call 027_028_test)

test/028/01_efl_delete_files.json: test/027/01_efl_delete_files.csv
	$(CSVTOJSON) -b efl_delete_files < $^ > $@

027_testdir = $(TEST_DIR)/027
027_01_files = $(027_testdir)/01/a.txt $(027_testdir)/01/b.txt \
	$(027_testdir)/01/c.html
027_02_files = $(027_testdir)/02/a.txt $(027_testdir)/02/b.txt \
	$(027_testdir)/02/c.html
027_03_files = $(027_testdir)/03/a.txt $(027_testdir)/03/b.txt \
	$(027_testdir)/03/c.html $(027_testdir)/03/sub/d.json

.PHONY: 027_efl_test
027_efl_test: $(027_01_files) $(027_02_files) $(027_03_files) \
	$(027_testdir)/04/a.txt $(027_testdir)/04/b.json
	$(call 027_028_test)

$(027_01_files) $(027_02_files) $(027_03_files): $(027_testdir)/01/. \
	$(027_testdir)/02/. $(027_testdir)/03/sub/.
	echo $@ > $@

$(027_testdir)/04/a.txt: $(027_testdir)/04/.
	echo $@ > $@
	touch -t 201301011313 $@

$(027_testdir)/04/b.json: $(027_testdir)/04/.
	echo $@ > $@

$(027_testdir)/01/. $(027_testdir)/02/. $(027_testdir)/03/sub/. $(027_testdir)/04/.:
	test -d $@ || mkdir -p $@

PHONY: 030_efl_test
030_efl_test: 029_efl_test test/030/01_efl_copy_files.json
	$(call 029_030_test)

test/030/01_efl_copy_files.json: test/029/01_efl_copy_files.csv
	$(CSVTOJSON) -b efl_copy_files < $^ > $@

PHONY: 029_efl_test
029_efl_test: $(027_02_files)
	$(call 029_030_test)

PHONY: 032_efl_test
032_efl_test: 031_efl_test test/032/01_packages.json
	$(packages_test)

PHONY: 031_efl_test
031_efl_test:
	$(packages_test)

PHONY: 031a_efl_test
031a_efl_test:
	$(packages_test)

PHONY: 031b_efl_test
031b_efl_test: 033_efl_test test/031b/01_packages.json
	$(packages_test)

PHONY: 034_efl_test
034_efl_test: 033_efl_test test/032/01_packages.json
	$(packages_test)

PHONY: 033_efl_test
033_efl_test:
	$(packages_test)

test/032/01_packages.json: test/031/01_packages.csv
	$(CSVTOJSON) -b efl_packages < $^ > $@

test/031b/01_packages.json: test/031a/01_packages.csv
	$(CSVTOJSON) -b efl_packages < $^ > $@

test_daemon          = efl_test_daemon
test_daemon_src      = test/035/$(test_daemon)
test_systemd_def     = $(test_daemon).service
test_systemd_def_src = test/035/$(test_daemon).service
test_daemon_files    = /etc/systemd/system/$(test_systemd_def) $(TEST_DIR)/$(test_daemon)

PHONY: 036_efl_test
036_efl_test: 035_efl_test test/036/01_efl_start_service.json
	$(call 035_036_test)

test/036/01_efl_start_service.json: test/035/01_efl_start_service.csv
	$(CSVTOJSON) -b efl_start_service < $^ > $@

PHONY: 035_efl_test
035_efl_test: $(test_daemon_files)
	$(call 035_036_test)

/etc/systemd/system/$(test_systemd_def): $(test_systemd_def_src)
	cp $^ $@

$(TEST_DIR)/$(test_daemon): $(test_daemon_src) $(TEST_DIR)
	cp $< $@

$(TEST_DIR):
	mkdir -p $@

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

PHONY: 280_efl_test
280_efl_test: syntax
	$(call 280_efl_test)

PHONY: 281_efl_test
281_efl_test: syntax test/281/01_efl_file_perms.json
	$(call 280_efl_test)

test/281/01_efl_file_perms.json: test/280/01_efl_file_perms.csv
	$(CSVTOJSON) -b efl_file_perms < $< > $@

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

.PHONY: clean
clean:
	/bin/systemctl stop $(test_systemd_def); \
	rm -fr masterfiles/*
	rm -f .stdlib
	rm -fr test/$(EFL_LIB)
	rm -fr $(TEST_DIR)
	rm -f /tmp/ssh/ssh_config
	rm -f /etc/systemd/system/$(test_systemd_def)
	rm -f $(test_files)


.PHONY: help
help:
	$(MAKE) --print-data-base --question |           \
		awk '/^[^.%][-A-Za-z0-9_]*:/                  \
			{ print substr($$q, 1, length($$1)-1) }' | \
		sort |                                        \
		pr --omit-pagination --width=80 --columns=4
