PERMIT_HEADER_INDEXES='1,2,3,5,6,7,8,9,10,11,12,13,14'
ENCODING='iso-8859-1'

all:	data/csv/address_data.csv \
			data/csv/permits.csv \
			data/csv/business_licenses.csv


.SECONDARY:

# Download and clean original data.  Unfortunately we have to process this data
# because some lines are not properly escaped or formatted in the original source.
data/csv/address_data.csv: data/gz/address.zip
data/csv/permits.csv: data/gz/permits.zip

# Simplify data, keeping only relevant columns
data/csv/address_data-processed.csv: data/csv/address_data.csv
	csvcut --encoding $(ENCODING) \
		-c address_id,zip_code,address_full,x,y $< > $@
data/csv/permits-processed.csv: data/csv/permits.csv
	csvcut --encoding $(ENCODING) -c $(PERMIT_HEADER_INDEXES) $< > $@

data/csv/permits-with-geo.csv: data/csv/permits-processed.csv data/csv/address_data-processed.csv
	csvjoin --columns case_address,address_full $< $(word 2,$^) > $@

data/csv/permits-new-construction.csv: data/csv/permits.csv
	csvcut --encoding $(ENCODING) -c $(PERMIT_HEADER_INDEXES) $< | csvgrep -c 3 -m "New Construction" > $@

data/csv/business_licenses.csv: data/gz/business_licenses.zip


data/gz/%.zip:
	mkdir -p $(dir $@)
	curl --remote-time 'ftp://ftp02.portlandoregon.gov/CivicApps/$(notdir $@)' -o $@.download
	mv $@.download $@

# Extract CSV, remove all leading header spaces, replace header spaces with _
# and lowercase all header names.  Finally remove all invalid rows
data/csv/%.csv:
	mkdir -p $(dir $@)
	tar -xzm -C $(dir $@) -f $<
	sed -i '' '1 s/" /"/g;1 s/ /_/g;' $@
	sed -i '' "1s/.*/`head -n 1 $@ | tr A-Z a-z`/" $@
	csvclean --encoding $(ENCODING) $@
	mv "$(dir $@)$(notdir $(basename $@))_out.csv" $@
	sed -i '' 's/ \{1,\}/ /g' $@
