require "csv"
require "fileutils"
require "json"
require "logger"
require "time"
require "active_support/time"

require_relative 'metric'

METRICS = [
  Metric.new(id: :temp_c,       header: "temp_c",       name: "Temperature (°C)", unit: "°C"),
  Metric.new(id: :humidity_pct, header: "humidity_pct", name: "Humidity (%)",     unit: "%"),
  Metric.new(id: :dewpoint_c,   header: "dewpoint_c",   name: "Dew Point (°C)",   unit: "°C"),
  Metric.new(id: :pressure_hPa, header: "pressure_hPa", name: "Pressure (hPa)",   unit: "hPa"),
  Metric.new(id: :wind_speed_mps, header: "wind_speed_mps", name: "Wind Speed (m/s)", unit: "m/s"),
  Metric.new(id: :wind_gust_mps, header: "wind_gust_mps", name: "Wind Gust (m/s)", unit: "m/s"),
  Metric.new(id: :wind_dir_deg, header: "wind_dir_deg", name: "Wind Direction (°)", unit: "°"),
  Metric.new(id: :uv_index,          header: "uv_index",          name: "UV Index",        unit: "Index"),
  Metric.new(id: :solar_radiation_wm2, header: "solar_radiation_wm2", name: "Solar Radiation (W/m²)", unit: "W/m²"),
  Metric.new(id: :rain_hourly_mm, header: "rain_hourly_mm", name: "Hourly Rain (mm)", unit: "mm"),
  Metric.new(id: :rain_hourly_in, header: "rain_hourly_in", name: "Hourly Rain (in)", unit: "in"),
  Metric.new(id: :temp_f,      header: "temp_f",       name: "Temperature (°F)", unit: "°F"),
  Metric.new(id: :dewpoint_f,  header: "dewpoint_f",   name: "Dew Point (°F)",   unit: "°F"),
  Metric.new(id: :wind_speed_mph, header: "wind_speed_mph", name: "Wind Speed (mph)", unit: "mph"),
  Metric.new(id: :wind_gust_mph, header: "wind_gust_mph", name: "Wind Gust (mph)", unit: "mph"),
].freeze

require_relative 'observation'
require_relative 'observations_set'
require_relative 'observations_writer'
require_relative 'observations_loader'
require_relative 'observation_aggregation'
require_relative 'metric_observation'
require_relative 'metric_observations_set'
require_relative 'observation_aggregation_writer'
require_relative 'daily_observations_set'
require_relative 'observation_aggregation_loader'
require_relative 'weather_station_reading'
require_relative 'graph_helpers'
require_relative 'daily_summary'
require_relative 'template_helpers'

LOGGER = Logger.new($stdout)

ROOT_DIR = File.expand_path(File.join(__dir__, '..'))
SITE_DIR = File.join(ROOT_DIR, "docs")

