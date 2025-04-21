#!/usr/bin/env ruby

# bin/convert_sensors_to_tsv.rb
require 'json'
require 'time'
require 'fileutils'
require "active_support/time"
# Removed: require 'tzinfo'

# --- Configuration ---
INPUT_DIR = 'tmp'
OUTPUT_DIR = 'tmp'
JSON_PATTERN = File.join(INPUT_DIR, 'sensor_*.json')
# Removed: TIMEZONE_IDENTIFIER

# Define the fixed offset in seconds (7 hours * 60 minutes/hour * 60 seconds/minute)
ARIZONA_OFFSET_SECONDS = 7 * 60 * 60

#<Sensor id: 2, name: "House KW", sensor_type: nil, latest_value: 772.0, latest_value_observed_at: "2016-12-27 22:26:52", sensor_settings: nil, created_at: "2018-02-14 22:31:06", updated_at: "2019-09-02 19:44:33">,
#<Sensor id: 3, name: "Humidity", sensor_type: "relative_humitity", latest_value: 25.0683574672, latest_value_observed_at: "2025-04-19 23:18:02", sensor_settings: nil, created_at: "2018-02-14 22:31:18", updated_at: "2025-04-19 23:18:02">,
#<Sensor id: 4, name: "Dewpoint", sensor_type: "temperature", latest_value: 1.00715905378538, latest_value_observed_at: "2025-04-19 23:18:02", sensor_settings: nil, created_at: "2018-02-14 22:31:29", updated_at: "2025-04-19 23:18:02">,
#<Sensor id: 5, name: "Barometric Pressure", sensor_type: "barometric_pressure", latest_value: 970.098701171, latest_value_observed_at: "2025-04-19 23:18:02", sensor_settings: nil, created_at: "2018-02-14 22:31:42", updated_at: "2025-04-19 23:18:03">,
#<Sensor id: 1, name: "Outdoor Temperature", sensor_type: "temperature", latest_value: 21.8573341229, latest_value_observed_at: "2025-04-19 23:18:03", sensor_settings: nil, created_at: "2018-02-14 21:51:38", updated_at: "2025-04-19 23:18:03">,
#<Sensor id: 6, name: "Outdoor Temp 2", sensor_type: "temperature", latest_value: 21.8573341229, latest_value_observed_at: "2025-04-19 23:18:03", sensor_settings: nil, created_at: "2018-02-14 22:31:52", updated_at: "2025-04-19 23:18:03">


# Placeholder: Update this map based on the actual content of 'Helpful Data.md'
# Maps sensor ID (e.g., '1' from 'sensor_1.json') to the value header name
SENSOR_VALUE_HEADERS = {
  '1' => 'temp_c',
  '2' => 'na',
  '3' => 'humidity_pct',
  '4' => 'dewpoint_c',
  '5' => 'pressure_hPa',
  '6' => 'temp_c' # Updated based on user selection context
  # Add or modify mappings based on your 'Helpful Data.md'
}.freeze

# --- Script Logic ---

# Ensure output directory exists
FileUtils.mkdir_p(OUTPUT_DIR)

# Removed: Block getting tzinfo object

# Find all sensor JSON files
json_files = Dir.glob(JSON_PATTERN)

if json_files.empty?
  puts "No sensor JSON files found matching '#{JSON_PATTERN}'."
  exit 0
end

puts "Found #{json_files.length} sensor files. Processing..."

json_files.each do |json_file_path|
  begin
    puts "Processing #{json_file_path}..."
    base_name = File.basename(json_file_path, '.json') # e.g., "sensor_1"
    sensor_id = base_name.split('_').last # e.g., "1"

    # Determine the value header, default to 'Value' if not found
    value_header = SENSOR_VALUE_HEADERS.fetch(sensor_id, 'Value')
    unless SENSOR_VALUE_HEADERS.key?(sensor_id)
      puts "Warning: No header mapping found for sensor ID '#{sensor_id}' in SENSOR_VALUE_HEADERS. Using default 'Value'."
    end

    # Define output TSV file path
    tsv_file_path = File.join(OUTPUT_DIR, "#{base_name}.tsv")

    # Open TSV file for writing
    File.open(tsv_file_path, 'w') do |tsv_file|
      # Write headers
      headers = ["observed_at_arizona_iso8601", value_header]
      tsv_file.puts(headers.join("\t"))

      # Process each line of the JSON file
      File.foreach(json_file_path).with_index do |line, line_num|
        begin
          # Parse the JSON object on the current line
          record = JSON.parse(line)

          observed_at_str = record.fetch('observed_at') + "Z" # Use fetch for better error on missing key
          value = record.fetch('value')

          time = Time.parse(observed_at_str) # Parse the UTC timestamp

          az_time = time.in_time_zone('Arizona') # Convert to Arizona time

          # Write data row
          tsv_file.puts([az_time.iso8601, value].join("\t"))

        rescue JSON::ParserError => e
          puts "Error parsing JSON on line #{line_num + 1} in file #{json_file_path}: #{e.message}. Line content: #{line.strip}"
          # next # Uncomment to skip the bad line and continue
        rescue KeyError => e
          puts "Error: Missing expected key on line #{line_num + 1} in #{json_file_path}: #{e.message}"
          # next # Uncomment to skip the bad line and continue
        rescue ArgumentError => e
          puts "Error: Could not parse timestamp on line #{line_num + 1} in #{json_file_path}. Ensure 'observed_at' is valid UTC format. Error: #{e.message}"
          # next # Uncomment to skip the bad line and continue
        end
      end
    end

    puts "Successfully converted #{json_file_path} to #{tsv_file_path}"

  rescue Errno::ENOENT => e
    puts "Error: Input file not found: #{json_file_path}"
  rescue => e # Catch other potential errors during file processing
    puts "An unexpected error occurred while processing #{json_file_path}: #{e.class} - #{e.message}"
    puts e.backtrace.join("\n")
  end
end

puts "Processing complete."