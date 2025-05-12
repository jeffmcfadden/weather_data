# A group of observation metrics coming from my weather station.
#
# Incoming data looks like this:
#
# ```json
# a=1
# PASSKEY=7EF5A57AB040884E8472F10FD5F5D1D9
# stationtype=AMBWeatherPro_V5.1.9
# dateutc=2025-05-11+16:15:24
# tempf=94.3
# humidity=12
# windspeedmph=1.79
# windgustmph=2.24
# maxdailygust=4.47
# winddir=136
# uv=7
# solarradiation=775.49
# hourlyrainin=0.000
# eventrainin=0.000
# dailyrainin=0.000
# weeklyrainin=0.000
# monthlyrainin=0.000
# yearlyrainin=0.000
# totalrainin=0.000
# battout=1
# tempinf=74.8
# humidityin=32
# baromrelin=29.920
# baromabsin=28.647
# ```
class WeatherStationReading
  attr_reader :observed_at, :temp_f, :temp_c, :humidity, :dew_point_f, :dew_point_c,
              :wind_speed_mph, :wind_speed_kph, :wind_gust_mph, :wind_gust_kph,
              :wind_dir_deg, :relative_pressure_hpa, :uv, :solar_radiation, :daily_rain_in

  def self.from_json(json_data_or_string)
    json_data = json_data_or_string.is_a?(String) ? JSON.parse(json_data_or_string) : json_data_or_string
    new(json_data)
  end

  def initialize(params)
    @observed_at = params[:observed_at].nil? ? Time.now : Time.strptime(params['observed_at'], "%Y-%m-%d %H:%M:%S")

    @temp_f = params['temp1f'].to_f
    @temp_c = f_to_c(@temp_f).round(3)
    @humidity = params['humidity1'].to_f
    @dew_point_f = params['dewpointf'].to_f
    @dew_point_c = f_to_c(@dew_point_f).round(3)
    @wind_speed_mph = params['windspeedmph'].to_f
    @wind_speed_mps = mph_to_mps(@wind_speed_mph).round(3)
    @wind_gust_mph = params['windgustmph'].to_f
    @wind_gust_mps = mph_to_mps(@wind_gust_mph).round(3)
    @wind_dir_deg = params['winddir'].to_f
    @relative_pressure_hpa = inhg_to_hpa(params['baromrelin']).round(3)
    @uv = params['uv'].to_i
    @solar_radiation = params['solarradiation'].to_f
    @daily_rain_in = params['dailyrainin'].to_f
  end

  def to_observation
    Observation.new(observed_at: @observed_at,
                    metric_observations: [
                      build_metric_observation(:temp_c, @observed_at, @temp_c),
                      build_metric_observation(:humidity_pct, @observed_at, @humidity),
                      build_metric_observation(:dewpoint_c, @observed_at, @dew_point_c),
                      build_metric_observation(:pressure_hPa, @observed_at, @relative_pressure_hpa),
                      build_metric_observation(:wind_speed_mps, @observed_at, @wind_speed_mps),
                      build_metric_observation(:wind_gust_mps, @observed_at, @wind_gust_mps),
                      build_metric_observation(:wind_dir_deg, @observed_at, @wind_dir_deg),
                      build_metric_observation(:uv_index, @observed_at, @uv),
                      build_metric_observation(:solar_radiation_wm2, @observed_at, @solar_radiation),
                      build_metric_observation(:rain_hourly_mm, @observed_at, in_to_mm(@daily_rain_in)),
                      build_metric_observation(:rain_hourly_in, @observed_at, @daily_rain_in),
                      build_metric_observation(:temp_f, @observed_at, @temp_f),
                      build_metric_observation(:dewpoint_f, @observed_at, @dew_point_f),
                      build_metric_observation(:wind_speed_mph, @observed_at, @wind_speed_mph),
                      build_metric_observation(:wind_gust_mph, @observed_at, @wind_gust_mph)
                    ])
  end

  private

  def build_metric_observation(id, observed_at, value)
    MetricObservation.new(metric: Metric.find(id), observed_at: observed_at, value: value)
  end

  def in_to_mm(inches)
    inches.to_f * 25.4
  end

  def f_to_c(f)
    (f.to_f - 32) * 5.0 / 9.0
  end

  def inhg_to_hpa(inhg)
    inhg.to_f * 33.8639
  end

  def mph_to_mps(mph)
    mph.to_f * 0.44704
  end

  def mph_to_kph(mph)
    mph.to_f * 1.60934
  end

end