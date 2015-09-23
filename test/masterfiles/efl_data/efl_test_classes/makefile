%.json: %.csv
	$(CSVTOJSON) -b efl_test_classes < $< > $@

.PHONY: clean
clean:
	find -maxdepth 1 -name "*.json" ! -name "efl_class_hostname2.json" \
		! -name "efl_class_hostrange.json" -delete
