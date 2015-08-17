# Making the test daemon for efl_service* bundle testing.
# TODO needs a make clean to for efl_service test

test_daemon      = efl_test_daemon
test_systemd_def = $(test_daemon).service

.PHONY: all
all: /etc/systemd/system/$(test_systemd_def) $(TEST_DIR)/$(test_daemon)

.PHONY: clean
clean:
	/bin/systemctl stop $(test_systemd_def)
	rm -f $(TEST_DIR)/$(test_daemon)
	rm -f /etc/systemd/system/$(test_systemd_def)

/etc/systemd/system/$(test_systemd_def): $(test_systemd_def)
	cp $^ $@

$(TEST_DIR)/$(test_daemon): $(test_daemon)
	cp $< $@

