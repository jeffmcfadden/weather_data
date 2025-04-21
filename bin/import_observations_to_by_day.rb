#!/usr/bin/env ruby

require 'fileutils'
require 'csv' # Using CSV library for robust TSV parsing

# --- Configuration ---
INPUT_FILE = 'observations/import.tsv'
OUTPUT_BASE_DIR = 'observations'
COLUMN_TO_EXCLUDE = 'temp_c2'

# --- Script Logic ---

unless File.exist?(INPUT_FILE)
  puts "Error: Input file not found: #{INPUT_FILE}"
  exit 1
end

puts "Processing #{INPUT_FILE}..."

current_output_file = nil
current_output_date_str = nil
header_row = nil
filtered_header_row_str = nil
excluded_column_index = nil

begin
  # Read the input file line by line
  File.open(INPUT_FILE, 'r') do |infile|
    infile.each_line.with_index do |line, line_num|
      begin
        # Use CSV parser with tab delimiter for robustness
        row = CSV.parse_line(line, col_sep: "\t")

        if line_num == 0
          # Process header row once
          header_row = row
          excluded_column_index = header_row.index(COLUMN_TO_EXCLUDE)

          unless excluded_column_index
            puts "Warning: Column '#{COLUMN_TO_EXCLUDE}' not found in header. No columns will be excluded."
            filtered_header_row = header_row
          else
            filtered_header_row = header_row.reject.with_index { |_, idx| idx == excluded_column_index }
          end
          filtered_header_row_str = CSV.generate_line(filtered_header_row, col_sep: "\t").strip
          next # Move to the next line after processing header
        end

        # Process data row
        timestamp_str = row[0]
        unless timestamp_str && timestamp_str.match?(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/)
           puts "Warning: Skipping malformed timestamp on line #{line_num + 1}: '#{timestamp_str}'"
           next
        end

        # Extract date parts (YYYY, MM, DD) from the timestamp "YYYY-MM-DD HH:MM"
        row_date_str = timestamp_str.split(' ').first # "YYYY-MM-DD"

        # Check if the date has changed
        if row_date_str != current_output_date_str
          # Close the previous file if it was open
          current_output_file&.close unless current_output_file&.closed?

          # Update the current date
          current_output_date_str = row_date_str
          year, month, _day = current_output_date_str.split('-')

          # Determine new output directory and filename
          output_dir = File.join(OUTPUT_BASE_DIR, year, month)
          output_file_path = File.join(output_dir, "#{current_output_date_str}.tsv")

          # Ensure the directory exists
          FileUtils.mkdir_p(output_dir)

          # Open the new file
          current_output_file = File.open(output_file_path, 'w')
          puts "Switched to output file: #{output_file_path}"

          current_output_file.puts(filtered_header_row_str)
        end

        # Filter the data row, excluding the specified column's value
        filtered_data_row = if excluded_column_index
                              row.reject.with_index { |_, idx| idx == excluded_column_index }
                            else
                              row # No column to exclude
                            end

        # Write the filtered data row to the currently open file
        current_output_file.puts(CSV.generate_line(filtered_data_row, col_sep: "\t").strip)

      rescue CSV::MalformedCSVError => e
        puts "Error parsing TSV on line #{line_num + 1}: #{e.message}. Line: '#{line.strip}'"
        next # Skip malformed line
      rescue => e
        # Log other unexpected errors but try to continue
        puts "An unexpected error occurred processing line #{line_num + 1}: #{e.class} - #{e.message}"
        puts e.backtrace.first(5).join("\n") # Print some backtrace for debugging
        next
      end
    end
  end

ensure
  # Ensure the very last opened file is closed
  puts "Closing final output file..."
  current_output_file&.close unless current_output_file&.closed?
end

puts "Processing complete. Daily files updated/created in #{OUTPUT_BASE_DIR} subdirectories."