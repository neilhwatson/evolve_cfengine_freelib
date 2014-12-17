CF_PROMISES = cf-promises
CF_AGENT    = cf-agent
VERSION     = 3.6
LIB         = lib/$(VERSION)
EFL_LIB     = masterfiles/$(LIB)/EFL
CF_REPO     = https://github.com/cfengine
CSVTOJSON   = ./bin/csvtojson
APT_GET     = /usr/bin/apt-get --quiet --yes

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
	001_efl_test  \
	002_efl_test  \
	003_efl_test  \
	004_efl_test  \
	005_efl_test  \
	006_efl_test  \
	007_efl_test  \
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
	032_efl_test \
	033_efl_test \
	034_efl_test 

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
	rm -f /tmp/023_efl_test
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	echo 'a95cee7d8d28c9a1d6f4cd86100d341c /tmp/023_efl_test' |md5sum -c
	echo PASS: $@
endef

define make_link_targets
	for i in 01 02 03; do echo $$i > /tmp/efl_test_$$i; done
endef

define del_link_targets
	for i in 01 02 03; do rm /tmp/efl_test_$$i /var/tmp/efl_test_$${i}_link; done
endef

define 027_028_test
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec; rspec spec/localhost/027_efl_test_spec.rb
	echo PASS: $@
endef

define 029_030_test
	rm -fr /tmp/efl_test/029 /tmp/efl_test/030 /tmp/ssh/
	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $@
	cd test/serverspec; rspec spec/localhost/029_efl_test_spec.rb
	$(call md5cmp_two_files,/etc/ssh/ssh_config,/tmp/ssh/ssh_config)
	$(call md5cmp_two_files,/tmp/efl_test/029/01/a.txt,/tmp/efl_test/027/02/a.txt)
	$(call md5cmp_two_files,/tmp/efl_test/029/01/b.txt,/tmp/efl_test/027/02/b.txt)
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
	@echo PASSED ALL TESTS

test/$(EFL_LIB):
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
syntax:
	OUTPUT=$$($(CF_PROMISES) -cf ./test/masterfiles/promises.cf 2>&1) ;\
	if [ -z "$$OUTPUT" ] ;\
	then                  \
		echo PASS: $@     ;\
	else                  \
		echo FAIL: $@     ;\
		echo $$OUTPUT     ;\
		exit 1            ;\
	fi                    

001_002_efl_test_result = R: PASS, any, efl_main order 1\nR: PASS, any, efl_main order 2\nR: PASS, any, efl_main order 3\nR: PASS, any, efl_main order 4\nR: PASS, any, efl_main order 5
.PHONY: 002_efl_test
001_csv_test_files  = $(wildcard test/001/*.csv)
002_csv_test_files  = $(patsubst test/001%,test/002%,$(001_csv_test_files))
002_json_test_files = $(patsubst %.csv,%.json,$(002_csv_test_files))
002_efl_test: 001_efl_test test/002/efl_main.json $(002_json_test_files)
	$(call cf_agent_grep_test, $@,$(001_002_efl_test_result))

test/002/efl_main.json: test/001/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,001,002,$@) 
	$(call search_and_replace,\.csv,\.json,$@) 

test/002/%_efl_test_simple.json: test/001/%_efl_test_simple.csv
	echo 002_json_test_files $@
	$(CSVTOJSON) -b efl_test_simple < $^ > $@

.PHONY: 001_efl_test
001_efl_test: 
	$(call cf_agent_grep_test, $@,$(001_002_efl_test_result))

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
005_efl_test:
	$(call cf_agent_grep_test, $@,$(005_006_efl_test_result))

007_008_efl_test_result = R: Name => \[efl_global_strings\.main_efl_dev\] Value => \[Neil H\. Watson \(neil\@watson-wilson\.ca\)\] Promisee => \[efl_development\]\nR: Name => \[efl_global_strings\.gateway\] Value => \[2001:DB8::1\] Promisee => \[efl_development\]
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
023_efl_test:
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

027_testdir = /tmp/efl_test/027
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

$(027_01_files): $(027_testdir)/01/.
	echo $@ > $@

$(027_02_files): $(027_testdir)/02/.
	echo $@ > $@

$(027_03_files): $(027_testdir)/03/sub/.
	echo $@ > $@

$(027_testdir)/04/a.txt: $(027_testdir)/04/.
	echo $@ > $@
	touch -t 201301011313 $@

$(027_testdir)/04/b.json: $(027_testdir)/04/.
	echo $@ > $@

$(027_testdir)/01/.:
	test -d $(027_testdir)/01 || mkdir -p $(027_testdir)/01

$(027_testdir)/02/.:
	test -d $(027_testdir)/02 || mkdir -p $(027_testdir)/02

$(027_testdir)/03/sub/.:
	test -d $(027_testdir)/03/sub || mkdir -p $(027_testdir)/03/sub

$(027_testdir)/04/.:
	test -d $(027_testdir)/04 || mkdir -p $(027_testdir)/04

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

PHONY: 034_efl_test
034_efl_test: 033_efl_test test/032/01_packages.json
	$(packages_test)

PHONY: 033_efl_test
033_efl_test:
	$(packages_test)

test/032/01_packages.json: test/031/01_packages.csv
	$(CSVTOJSON) -b efl_packages < $^ > $@

.PHONY: clean
clean:
	rm -fr masterfiles/*
	rm -f .stdlib
	rm -fr test/$(EFL_LIB)
	rm -fr /tmp/*efl_test* 
	rm -f /tmp/ssh/ssh_config


.PHONY: help
help:
	$(MAKE) --print-data-base --question |           \
		awk '/^[^.%][-A-Za-z0-9_]*:/                  \
			{ print substr($$q, 1, length($$1)-1) }' | \
		sort |                                        \
		pr --omit-pagination --width=80 --columns=4
