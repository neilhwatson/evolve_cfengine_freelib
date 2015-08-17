# Making the test daemon for efl_service* bundle testing.
# TODO needs a make clean to for efl_service test

test_daemon      = efl_test_daemon
test_systemd_def = $(test_daemon).service
daemon_dir       = $(TEST_DIR)

.PHONY: all
all: /etc/systemd/system/$(test_systemd_def) $(daemon_dir)/$(test_daemon)

.PHONY: clean
clean:
	/bin/systemctl stop $(test_systemd_def)
	rm -f $(daemon_dir)
	rm -f /etc/systemd/system/$(test_systemd_def)

/etc/systemd/system/$(test_systemd_def): $(test_systemd_def)
	cp $< $@

$(daemon_dir)/$(test_daemon): $(test_daemon) $(daemon_dir)
	cp $< $@

$(daemon_dir):
	mkdir -p $@
