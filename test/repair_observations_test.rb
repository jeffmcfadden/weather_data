require_relative '../lib/core'

class RepairObservationsTest < TLDR

  def test_temperature_fill
    sample_observations = <<-EOS
observed_at	temp_c	humidity_pct	dewpoint_c	pressure_hPa
2015-01-04 00:00	3.750
2015-01-04 00:01	3.687
2015-01-04 00:02	3.750
2015-01-04 00:03	3.687
    EOS

    sample_observations.strip!

    loader = ObservationsLoader.new(metrics: METRICS).load(sample_observations)

    observations = loader.observations
    observations.each(&:fill_missing!)

    writer = ObservationsWriter.new(observations: observations)
    io = StringIO.new

    writer.write(io, metrics: METRICS)

    expected = <<-EOS
observed_at	temp_c	humidity_pct	dewpoint_c	pressure_hPa	wind_speed_mps	wind_gust_mps	wind_dir_deg	uv_index	solar_radiation_wm2	rain_hourly_mm	rain_hourly_in	temp_f	dewpoint_f	wind_speed_mph	wind_gust_mph
2015-01-04 00:00	3.75											38.75			
2015-01-04 00:01	3.687											38.6366			
2015-01-04 00:02	3.75											38.75			
2015-01-04 00:03	3.687											38.6366			
EOS

    assert_equal expected, io.string
  end

  def test_dewpoint_fill
    sample_observations = <<-EOS
observed_at	temp_c	humidity_pct	dewpoint_c	pressure_hPa
2021-02-02 00:00	17.000	55.520	8.042	1016.690
2021-02-02 00:01	17.000	55.130	7.938	1016.640
2021-02-02 00:02	17.000	55.630	8.071	1016.660
2021-02-02 00:03	17.000	55.840	8.126	1016.660
2021-02-02 00:04	17.000	56.270	8.239	1016.690
2021-02-02 00:05	17.000	55.630	8.071	1016.720
2021-02-02 00:06	16.937	55.870	8.075	1016.730
EOS

    sample_observations.strip!

    loader = ObservationsLoader.new(metrics: METRICS).load(sample_observations)

    observations = loader.observations
    observations.each(&:fill_missing!)

    writer = ObservationsWriter.new(observations: observations)
    io = StringIO.new

    writer.write(io, metrics: METRICS)

    expected = <<-EOS
observed_at	temp_c	humidity_pct	dewpoint_c	pressure_hPa	wind_speed_mps	wind_gust_mps	wind_dir_deg	uv_index	solar_radiation_wm2	rain_hourly_mm	rain_hourly_in	temp_f	dewpoint_f	wind_speed_mph	wind_gust_mph
2021-02-02 00:00	17.0	55.52	8.042	1016.69								62.6	46.4756		
2021-02-02 00:01	17.0	55.13	7.938	1016.64								62.6	46.2884		
2021-02-02 00:02	17.0	55.63	8.071	1016.66								62.6	46.5278		
2021-02-02 00:03	17.0	55.84	8.126	1016.66								62.6	46.6268		
2021-02-02 00:04	17.0	56.27	8.239	1016.69								62.6	46.8302		
2021-02-02 00:05	17.0	55.63	8.071	1016.72								62.6	46.5278		
2021-02-02 00:06	16.937	55.87	8.075	1016.73								62.4866	46.535		
EOS

    assert_equal expected, io.string

  end

end