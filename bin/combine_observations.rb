#!/usr/bin/env ruby

require 'fileutils'
require 'time' # Though not strictly needed for parsing as timestamps are pre-formatted

# --- Configuration ---
INPUT_DIR = 'tmp'
INPUT_PATTERN = File.join(INPUT_DIR, 'formatted_sensor_*.tsv')
OUTPUT_DIR = 'observations'
OUTPUT_FILE = File.join(OUTPUT_DIR, 'observations.tsv')

# Maps sensor ID (from filename) to the desired header name
# Using strings for keys consistent with filename parsing
SENSOR_HEADERS = {
  '1' => 'temp_c',
  '3' => 'humidity_pct',
  '4' => 'dewpoint_c',
  '5' => 'pressure_hPa',
  '6' => 'temp_c2' # Renamed to distinguish from sensor 1
}.freeze

# --- Script Logic ---

# Ensure output directory exists
FileUtils.mkdir_p(OUTPUT_DIR)

# Find all formatted sensor TSV files
input_files = Dir.glob(INPUT_PATTERN)

if input_files.empty?
  puts "No formatted sensor files found matching '#{INPUT_PATTERN}'."
  exit 0
end

puts "Found #{input_files.length} formatted sensor files. Processing..."

# Data structure to hold observations grouped by minute timestamp
# Example: { "YYYY-MM-DD HH:MM" => { "header1" => value1, "header2" => value2 } }
observations_by_minute = {}

# Determine the order of headers based on sorted sensor IDs
ordered_sensor_ids = SENSOR_HEADERS.keys.sort_by(&:to_i)
ordered_headers = ordered_sensor_ids.map { |id| SENSOR_HEADERS[id] }

# Process each input file
input_files.each do |file_path|
  begin
    base_name = File.basename(file_path, '.tsv') # e.g., "formatted_sensor_1"
    sensor_id = base_name.split('_').last       # e.g., "1"

    header_name = SENSOR_HEADERS[sensor_id]

    unless header_name
      puts "Warning: Skipping file #{file_path}. No header mapping found for sensor ID '#{sensor_id}'."
      next
    end

    puts "Reading data for #{header_name} from #{file_path}..."

    File.foreach(file_path).with_index do |line, line_num|
      begin
        timestamp, value = line.strip.split("\t", 2)

        unless timestamp && value && !timestamp.empty? && !value.empty?
           puts "Warning: Skipping malformed line #{line_num + 1} in #{file_path}: '#{line.strip}'"
           next
        end

        # Ensure the timestamp key exists in the main hash
        observations_by_minute[timestamp] ||= {}
        # Store the value under its corresponding header name for that timestamp
        observations_by_minute[timestamp][header_name] = value

      rescue => e
        puts "Error processing line #{line_num + 1} in #{file_path}: #{e.class} - #{e.message}. Line: '#{line.strip}'"
        next
      end
    end

  rescue Errno::ENOENT
    puts "Error: Input file not found: #{file_path}"
  rescue => e # Catch other potential errors during file processing
    puts "An unexpected error occurred while processing #{file_path}: #{e.class} - #{e.message}"
    puts e.backtrace.join("\n")
  end
end

# Sort the observations by timestamp
sorted_timestamps = observations_by_minute.keys.sort

puts "Combining and sorting data for #{sorted_timestamps.length} unique minutes..."

# Write the combined data to the output file
begin
  File.open(OUTPUT_FILE, 'w') do |outfile|
    # Write header row
    header_row = ['observed_at'] + ordered_headers
    outfile.puts(header_row.join("\t"))

    # Write data rows
    sorted_timestamps.each do |timestamp|
      minute_data = observations_by_minute[timestamp]
      # Build the row, fetching values by the ordered header names
      # Use fetch with a default empty string for missing sensor data at that minute
      output_values = ordered_headers.map { |header| minute_data.fetch(header, '') }
      output_line = [timestamp] + output_values
      outfile.puts(output_line.join("\t"))
    end
  end
  puts "Successfully created combined observations file: #{OUTPUT_FILE}"

rescue => e
  puts "An error occurred while writing the output file #{OUTPUT_FILE}: #{e.class} - #{e.message}"
  puts e.backtrace.join("\n")
end

puts "Processing complete."