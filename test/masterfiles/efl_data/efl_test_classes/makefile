%.json: %.csv
	$(CSVTOJSON) -b efl_test_classes < $< > $@

.PHONY: clean
clean:
	rm -f *.json
