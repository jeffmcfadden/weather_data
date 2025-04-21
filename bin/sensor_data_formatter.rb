#!/usr/bin/env ruby

require 'time'
require 'fileutils'

# --- Configuration ---
INPUT_DIR = 'tmp'
OUTPUT_DIR = 'tmp'
INPUT_PATTERN = File.join(INPUT_DIR, 'sensor_*.tsv')
OUTPUT_PREFIX = 'formatted_'

# --- Script Logic ---

# Ensure output directory exists (though it likely does if input exists)
FileUtils.mkdir_p(OUTPUT_DIR)

# Find all sensor TSV files matching the pattern, excluding already formatted ones
tsv_files = Dir.glob(INPUT_PATTERN).reject { |f| File.basename(f).start_with?(OUTPUT_PREFIX) }

if tsv_files.empty?
  puts "No sensor TSV files found matching '#{INPUT_PATTERN}' (and not starting with '#{OUTPUT_PREFIX}')."
  exit 0
end

puts "Found #{tsv_files.length} sensor TSV files to process..."

tsv_files.each do |input_file_path|
  begin
    base_name = File.basename(input_file_path) # e.g., "sensor_1.tsv"
    output_file_path = File.join(OUTPUT_DIR, "#{OUTPUT_PREFIX}#{base_name}")

    puts "Processing #{input_file_path} -> #{output_file_path}"

    # Open input and output files
    File.open(input_file_path, 'r') do |infile|
      File.open(output_file_path, 'w') do |outfile|

        # Process each line, skipping the header
        infile.each_line.with_index do |line, index|
          next if index == 0 # Skip header row

          begin
            # Split the line by tab
            timestamp_str, value_str = line.strip.split("\t", 2)

            # Ensure both parts were found
            unless timestamp_str && value_str
              puts "Warning: Skipping malformed line #{index + 1} in #{input_file_path}: '#{line.strip}'"
              next
            end

            # Parse the ISO8601 timestamp
            time = Time.iso8601(timestamp_str)

            # Format the timestamp as YYYY-MM-DD HH:MM
            formatted_time = time.strftime('%Y-%m-%d %H:%M')

            # Convert value to float and format to 3 decimal places
            formatted_value = sprintf('%.3f', value_str.to_f)

            # Write the formatted line to the output file
            outfile.puts("#{formatted_time}\t#{formatted_value}")

          rescue ArgumentError => e
            # Handle potential errors parsing the timestamp
            puts "Error parsing timestamp on line #{index + 1} in #{input_file_path}: #{e.message}. Line: '#{line.strip}'"
            next # Skip this line and continue with the next
          rescue => e
            # Handle other potential errors on the line (e.g., formatting)
             puts "Error processing line #{index + 1} in #{input_file_path}: #{e.class} - #{e.message}. Line: '#{line.strip}'"
            next # Skip this line
          end
        end
      end
    end
    puts "Successfully created #{output_file_path}"

  rescue Errno::ENOENT
    puts "Error: Input file not found: #{input_file_path}"
  rescue => e # Catch other potential errors during file processing
    puts "An unexpected error occurred while processing #{input_file_path}: #{e.class} - #{e.message}"
    puts e.backtrace.join("\n")
  end
end

puts "Processing complete."