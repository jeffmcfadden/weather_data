# Weather Data

This repo is a collection of weather data from my local weather station in 
south-central Arizona. 

## The Data

### Observations

Observations are stored in tab-separated-value format (TSV) with per-minute
observations. Observations are collated into daily files, grouped into folders
for year, then month. 

You'll find these observations in the `observations` folder, for example:
`observations/2021/12/2021-12-03.tsv`

The first row of each observation defines the columns. Temperature data is the
most abundant data, followed by humidity, then pressure and dewpoint. Wind and
rainfall data are rare in the dataset as of 2025, and wind data is probably 
not reliable in any case due to limitations for mounting an anemometer. 

### Aggregations

Aggregation files are created for each day, stored in TSV format. The first row
of each aggregation file defines the columns. It is in the aggregation files
where you will find daily maximum and minimum temperatures, for example.

There are also yearly aggregations files for each year, which follow the same
format.

### Almanacs

A yearly almanac is generated as well, with key data summarized in paragraph 
form.

## Tools

Tools for processing the data live in the `bin` directory, and are used by the
various systems responsible for collecting and processing the data in this
repository.

## Data Quality

### Temperature

Temperature data should be reliable. My temperature sensors have been in 
actively ventilated enclosures, out of the direct sun, approximately 7ft (2.
1m) above ground level. The ground beneath the sensor is turf. Because of 
local conditions, temperatures will typically be a bit lower than nearby NWS 
data by 1-2 degrees F.

### Humidity

Humidity will typically be slightly higher at my observing location 
(compared to NWS data, for example) due to local foliage, but the readings 
should be mostly accurate.

## Holes in the Data

In rare instances where data was lost due to equipment failure, computer
bugs, or human mistakes, I have substituted observations with nearby
stations that I trust.

## TODO

- Import the rest of the data (tmp/sensor_data_export.csv)
- Establish incoming data pipeline via cron, etc.
- Tools to build
  - add_observation(observed_at, metric_id, value)
  - almanac builder (including class, writer, etc)
  - 