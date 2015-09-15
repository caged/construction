PERMIT_HEADER_INDEXES='1,2,3,5,6,7,8,9,10,11,12,13,14'
ENCODING='iso-8859-1'
FINAL_PERMIT_COLUMNS="permit_case_number,permit_case_type,issue_date,final_date,latest_activity,status,activity_type,activities,must_check,activity_status,last_activity,completed,address_id,zip_code,address_full,x,y"

all:	data/csv/address_data.csv \
			data/csv/permits.csv \
			data/csv/business_licenses.csv


.SECONDARY:

# Residential construction data provided by Kevin Martin of the City of Portland.
# See https://github.com/CityofPortland/pdxdata/issues/5
data/shp/residential-permits.shp: data/gz/residential-permits.zip
data/shp/neighborhoods.shp: data/gz/Neighborhoods_pdx.zip

data/json/supermarkets.json: data/shp/neighborhoods.shp script/fetch-and-combine-supermarkets
	sh script/fetch-and-combine-supermarkets $@ $<

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
	csvcut --encoding $(ENCODING) -c $(FINAL_PERMIT_COLUMNS) $@ > $@.tmp
	mv $@.tmp $@

data/csv/permits-new-construction.csv: data/csv/permits.csv
	csvcut --encoding $(ENCODING) -c $(PERMIT_HEADER_INDEXES) $< | csvgrep -c 3 -m "New Construction" > $@

data/csv/business_licenses.csv: data/gz/business_licenses.zip

# Download all files
data/gz/%.zip:
	mkdir -p $(dir $@)
	curl --remote-time 'ftp://ftp02.portlandoregon.gov/CivicApps/$(notdir $@)' -o $@.download
	mv $@.download $@

data/gz/residential-permits.zip:
	mkdir -p $(dir $@)
	curl -L --remote-time 'https://www.dropbox.com/s/n2fh9rn9tsdbrh6/residential_permits_pdx_150907.zip?dl=0' -o $@.download
	mv $@.download $@
# Extract CSV, remove all leading header spaces, replace header spaces with _
# and lowercase all header names.  Collapse multiple whitespace to single space,
# remove all trailing whitespace before command and finally remove all invalid rows
data/csv/%.csv:
	mkdir -p $(dir $@)
	tar -xzm -C $(dir $@) -f $<
	sed -i '' '1 s/" /"/g;1 s/ /_/g;' $@
	sed -i '' "1s/.*/`head -n 1 $@ | tr A-Z a-z`/" $@
	csvclean --encoding $(ENCODING) $@
	mv "$(dir $@)$(notdir $(basename $@))_out.csv" $@
	sed -i '' 's/ \{1,\}/ /g;s/ \{1,\},/,/g;s/ PORTLAND//g' $@

################################################################################
# SHAPEFILES: META
################################################################################
data/shp/%.shp:
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	tar --exclude="._*" -xzm -C $(basename $@) -f $<

	for file in `find $(basename $@) -name '*.shp'`; do \
		ogr2ogr -dim 2 -t_srs 'EPSG:4326' -f 'ESRI Shapefile' $(basename $@).$${file##*.} $$file; \
		chmod 644 $(basename $@).$${file##*.}; \
	done
	rm -rf $(basename $@)
