all:	data/csv/address_data.csv \
			data/csv/permits.csv \
			data/csv/business_licenses.csv


.SECONDARY:

data/csv/address_data.csv: data/gz/address.zip
data/csv/business_licenses.csv: data/gz/business_licenses.zip
data/csv/permits.csv: data/gz/permits.zip
data/permits-normalized.csv: data/csv/permits.csv script/normalize-addresses
	ruby script/normalize-addresses $@ $<

# data/permits/all: script/normalize-addresses
# 	mkdir -p $(dir $@)
# 	csplit -f 'data/permits/' "data/csv/permits.csv" \
# 	  '/^\"1996/' '/^\"1997/' '/^\"1998/' '/^\"1999/' '/^\"2000/' '/^\"2001/' '/^\"2002/' \
# 	  '/^\"2003/' '/^\"2004/' '/^\"2005/' '/^\"2006/' '/^\"2007/' '/^\"2008/' '/^\"2009/' \
# 	  '/^\"2010/' '/^\"2011/' '/^\"2012/' '/^\"2013/' '/^\"2014/' '/^\"2015/'
# 	ruby script/normalize-addresses $@ $<

data/gz/%.zip:
	mkdir -p $(dir $@)
	curl --remote-time 'ftp://ftp02.portlandoregon.gov/CivicApps/$(notdir $@)' -o $@.download
	mv $@.download $@

data/csv/%.csv:
	mkdir -p $(dir $@)
	tar -xzm -C $(dir $@) -f $<
	# Hack to remove quotes in quotes
	LC_ALL=C sed -i '' -e 's/"//g;s/\([^,]*\)/"\1"/g;' $@
	perl -pe 's|\r||' $@ > $@.tmp
	mv $@.tmp $@
