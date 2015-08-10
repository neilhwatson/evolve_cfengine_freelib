%.json: %.csv
	$(CSVTOJSON) -b efl_test_simple < $< > $@

.PHONY: clean
clean:
	rm -f *.json
