%.json: %.csv
	$(CSVTOJSON) -b efl_test_vars < $< > $@

.PHONY: clean
clean:
	rm -f *.json
