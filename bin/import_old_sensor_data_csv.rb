#!/usr/bin/env ruby

require_relative '../lib/core'

LOGGER = Logger.new(STDOUT)

# Maps sensor IDs from import file to the defined metric IDs
SENSOR_ID_TO_METRIC_ID = {
  '1' => :temp_c,
  '3' => :humidity_pct,
  '4' => :dewpoint_c,
  '5' => :pressure_hPa
}.freeze

def find_metric(metric_id)
  METRICS.find { |m| m.id == metric_id }
end

SENSOR_ID_TO_METRIC_MAP = SENSOR_ID_TO_METRIC_ID.map{ |sensor_id, metric_id| [sensor_id, find_metric(metric_id)] }.to_h


CSV_FILE_PATH = File.join('tmp', 'sensor_data_export.csv')

metric_observations = MetricObservationsSet.new(metric_observations: [])

LOGGER.info "Parsing CSV file: #{CSV_FILE_PATH}"

# Parse the CSV file and create MetricObservation objects
CSV.foreach(CSV_FILE_PATH, headers: true, header_converters: :symbol) do |row|
  observed_at = Time.parse(row[:observed_at])
  sensor_id = row[:sensor_id]
  value = row[:value].to_f

  metric = SENSOR_ID_TO_METRIC_MAP[sensor_id]
  unless metric
    next
  end

  metric_observations.add MetricObservation.new(
    metric: metric,
    observed_at: observed_at,
    value: value.round(3)
  )

  # break if metric_observations.size > 100_000 # Temporary limit for testing
end

LOGGER.info "Parsed #{metric_observations.size} metric observations"

LOGGER.info "Converting to observations"
observations_set = metric_observations.to_observations_set
LOGGER.info "Converted to #{observations_set.size} observations"

LOGGER.info "Grouping observations by day"
observations_by_day = observations_set.grouped_by_day
LOGGER.info "Grouped observations into #{observations_by_day.size} days"

observations_by_day.each do |day, observations|
  date = Date.parse(day)

  year = day[0..3]
  month = day[5..6]

  file_for_day = File.join('observations', year, month, "#{day}.tsv")

  daily_observations_set = DailyObservationsSet.new(date: date, observations: [])

  if File.exist?(file_for_day)
    LOGGER.info "Loading existing observations from #{file_for_day}"
    daily_observations_set << ObservationsLoader.new(metrics: METRICS).load(File.open(file_for_day)).observations
    LOGGER.info "Loaded #{daily_observations_set.size} existing observations"
  end

  LOGGER.info "Merging the #{observations.size} observations for #{day}..."
  daily_observations_set << observations
  LOGGER.info "Now there are #{daily_observations_set.size} observations for #{day}"

  existing_file_contents = File.exist?(file_for_day) ? File.read(file_for_day) : nil

  sio = StringIO.new
  ObservationsWriter.new(observations: daily_observations_set.observations).write(sio)
  new_file_contents = sio.string

  if existing_file_contents&.strip == new_file_contents.strip
    LOGGER.info "No changes to observations for #{day}, skipping write"
  else
    LOGGER.warn "Files do not match, writing new observations for #{day} to #{file_for_day}"

    LOGGER.info "Writing observations for #{day} to #{file_for_day}"
    FileUtils.mkdir_p(File.dirname(file_for_day))
    File.write(file_for_day, new_file_contents)
    LOGGER.info "Wrote #{daily_observations_set.size} observations to #{file_for_day}"
  end
end



#   def group_and_write_observations(metric_observations)
#     # Group metric observations by minute
#     observations_by_minute = group_by_minute(metric_observations)
#
#     # Convert to Observation objects
#     observations = observations_by_minute.map do |timestamp, metrics|
#       Observation.new(
#         observed_at: timestamp,
#         metric_observations: metrics
#       )
#     end
#
#     # Group by day
#     observations_by_day = group_by_day(observations)
#
#     # Process each day
#     observations_by_day.each do |day, day_observations|
#       process_day(day, day_observations)
#     end
#   end
#
#   def group_by_minute(metric_observations)
#     metric_observations.group_by(&:observed_at)
#   end
#
#   def group_by_day(observations)
#     observations.group_by { |o| o.observed_at.strftime('%Y-%m-%d') }
#   end
#
#   def process_day(day, new_observations)
#     puts "Processing observations for #{day}..."
#
#     # Get a date object from the day string
#     date = Date.parse(day)
#
#     # Create a daily file for this date
#     daily_file = DailyObservationsFile.new(date)
#
#     # Merge new observations with existing ones
#     daily_file.merge_observations(new_observations)
#
#     # Save the file
#     daily_file.save
#
#     puts "Processed #{new_observations.size} observations for #{day}"
#   end
# end
#
# # Class that represents a daily observations file
# class DailyObservationsFile
#   attr_reader :date, :observations
#
#   def initialize(date)
#     @date = date
#     @observations = []
#     load if exists?
#   end
#
#   def exists?
#     File.exist?(file_path)
#   end
#
#   def load
#     puts "Loading existing observations from #{file_path}"
#     File.open(file_path, 'r') do |file|
#       loader = ObservationsLoader.new(metrics: METRICS)
#       loader.load(file)
#       @observations = loader.observations
#     end
#     puts "Loaded #{@observations.size} existing observations"
#   rescue => e
#     puts "Warning: Failed to load existing observations: #{e.message}"
#     @observations = []
#   end
#
#   def merge_observations(new_observations)
#     # Create a hash of existing observations indexed by timestamp
#     observation_hash = @observations.each_with_object({}) do |obs, hash|
#       hash[obs.observed_at] = obs
#     end
#
#     # Merge in new observations
#     new_observations.each do |new_obs|
#       if observation_hash[new_obs.observed_at]
#         # Merge with existing observation
#         existing_obs = observation_hash[new_obs.observed_at]
#         merged_metrics = merge_metric_observations(existing_obs, new_obs)
#
#         # Replace with merged observation
#         observation_hash[new_obs.observed_at] = Observation.new(
#           observed_at: new_obs.observed_at,
#           metric_observations: merged_metrics
#         )
#       else
#         # Add new observation
#         observation_hash[new_obs.observed_at] = new_obs
#       end
#     end
#
#     # Convert hash back to array and sort by timestamp
#     @observations = observation_hash.values.sort_by(&:observed_at)
#   end
#
#   def merge_metric_observations(existing_obs, new_obs)
#     # Create a hash of existing metric observations by metric ID
#     metrics_hash = existing_obs.metric_observations.each_with_object({}) do |mo, hash|
#       hash[mo.metric.id] = mo
#     end
#
#     # Add or replace with new metric observations
#     new_obs.metric_observations.each do |new_mo|
#       metrics_hash[new_mo.metric.id] = new_mo
#     end
#
#     # Return as array
#     metrics_hash.values
#   end
#
#   def save
#     # Ensure the directory exists
#     FileUtils.mkdir_p(File.dirname(file_path))
#
#     puts "Writing observations to #{file_path}"
#     File.open(file_path, 'w') do |file|
#       writer = ObservationsWriter.new(observations: @observations, metrics: METRICS)
#       writer.write(file)
#     end
#   end
#
#   def file_path
#     year = date.strftime('%Y')
#     month = date.strftime('%m')
#     File.join('observations', year, month, "#{date.strftime('%Y-%m-%d')}.tsv")
#   end
# end
#
# # --- Run the import script ---
# importer = CsvSensorDataImporter.new(File.join('tmp', 'sensor_data_export.csv'))
# importer.import
# puts "Import completed successfully"