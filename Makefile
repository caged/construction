PERMIT_HEADER_INDEXES='1,2,3,5,6,7,8,9,10,11,12,13,14'
ENCODING='iso-8859-1'
FINAL_PERMIT_COLUMNS="permit_case_number,permit_case_type,issue_date,final_date,latest_activity,status,activity_type,activities,must_check,activity_status,last_activity,completed,address_id,zip_code,address_full,x,y"

all:	data/shp/neighborhoods.shp \
			data/shp/residential-permits.shp \
			data/shp/osm.shp \
			data/shp/buildings.shp

.SECONDARY:

# Residential construction data provided by Kevin Martin of the City of Portland.
# See https://github.com/CityofPortland/pdxdata/issues/5
data/shp/residential-permits.shp: data/gz/residential-permits.zip
data/shp/neighborhoods.shp: data/gz/Neighborhoods_pdx.zip
data/shp/buildings.shp: data/gz/Building_Footprints_pdx.zip
data/shp/osm.shp: data/gz/osm/portland_oregon.osm2pgsql-shapefiles.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	tar --exclude="._*" -xzm -C $(basename $@) -f $<

	chmod 644 $(basename $@)/*
	mv $(basename $@)/* data/shp
	rm -rf $(basename $@)
	touch $@

data/csv/business_licenses.csv: data/gz/business_licenses.zip

data/gz/residential-permits.zip:
	mkdir -p $(dir $@)
	curl -L --remote-time 'https://www.dropbox.com/s/n2fh9rn9tsdbrh6/residential_permits_pdx_150907.zip?dl=0' -o $@.download
	mv $@.download $@

data/gz/osm/%.zip:
	mkdir -p $(dir $@)
	curl --remote-time 'https://s3.amazonaws.com/metro-extracts.mapzen.com/$(notdir $@)' -o $@.download
	mv $@.download $@

# Download from CivicApps FTP
data/gz/%.zip:
	mkdir -p $(dir $@)
	curl --remote-time 'ftp://ftp02.portlandoregon.gov/CivicApps/$(notdir $@)' -o $@.download
	mv $@.download $@

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
