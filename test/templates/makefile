# Making the test daemon for efl_service* bundle testing.
# TODO needs a make clean to for efl_service test

template_dir   = $(TEST_DIR)/templates
template_files = \
	$(template_dir)/config \
	$(template_dir)/config.mus \
	$(template_dir)/config.tmp

.PHONY: all
all: $(template_files)

.PHONY: clean
clean:
	rm -fr $(template_dir)

$(template_dir)/config: config $(template_dir)
	cp $< $@

$(template_dir)/config.mus: config.mus $(template_dir)
	cp $< $@

$(template_dir)/config.tmp: config.tmp $(template_dir)
	cp $< $@

$(template_dir):
	mkdir -p $@
