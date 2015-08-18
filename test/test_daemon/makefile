# Making the test daemon for efl_service* bundle testing.
# TODO needs a make clean to for efl_service test

daemon      = efl_test_daemon
systemd_def = $(daemon).service
daemon_dir  = $(TEST_DIR)
daemon_exec = $(daemon_dir)/$(daemon)


.PHONY: all
all: /etc/systemd/system/$(systemd_def) $(daemon_exec)
	/bin/systemctl daemon-reload

.PHONY: clean
clean:
	/bin/systemctl stop $(systemd_def); /bin/true
	/bin/systemctl disable $(systemd_def); /bin/true
	/bin/systemctl reset-failed
	rm -f $(daemon_exec)
	rm -f /etc/systemd/system/$(systemd_def)
	/bin/systemctl daemon-reload
	/bin/systemctl reset-failed

/etc/systemd/system/$(systemd_def): $(systemd_def)
	cp $< $@

$(daemon_exec): $(daemon) $(daemon_dir)
	cp $< $@

$(daemon_dir):
	mkdir -p $@
