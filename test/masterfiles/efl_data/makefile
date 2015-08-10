%.json: %.csv
	$(CSVTOJSON) -b $* < $< > $@
	echo "ifeq ($@,efl_main.json)"
	if [ "$@" = efl_main.json ] ;\
	then \
		perl -pi -e 's/csv/json/' $@ ;\
	fi

.PHONY: clean
clean:
	rm -f *.json
