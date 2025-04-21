require "csv"
require "fileutils"
require "json"
require "logger"
require "time"
require "active_support/time"

require_relative 'metric'
require_relative 'observation'
require_relative 'observations_set'
require_relative 'observations_writer'
require_relative 'observations_loader'
require_relative 'observation_aggregation'
require_relative 'metric_observation'
require_relative 'metric_observations_set'
require_relative 'observation_aggregation_writer'
require_relative 'daily_observations_set'

METRICS = [
  Metric.new(id: :temp_c,       header: "temp_c",       name: "Temperature (°C)", unit: "°C"),
  Metric.new(id: :humidity_pct, header: "humidity_pct", name: "Humidity (%)",     unit: "%"),
  Metric.new(id: :dewpoint_c,   header: "dewpoint_c",   name: "Dew Point (°C)",   unit: "°C"),
  Metric.new(id: :pressure_hPa, header: "pressure_hPa", name: "Pressure (hPa)",   unit: "hPa")
].freeze