%.json: %.csv
	$(CSVTOJSON) -b $* < $< > $@
	if [ "$@" = efl_main.json ] ;\
	then \
		perl -pi -e 's/csv/json/' $@ ;\
	fi

.PHONY: clean
clean:
	find -maxdepth 1 -name "*.json" ! -name "efl_class_hostname2.json" -delete

