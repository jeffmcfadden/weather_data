# Used to write a group of observations to one of our daily observations files.
#
# Observations files are tab separated and look like this:
#
# ```tsv
# observed_at	temp_c	humidity_pct	dewpoint_c	pressure_hPa
# 2019-02-03 00:00	18.812	64.840	12.060	1009.860
# 2019-02-03 00:01	18.812	65.110	12.124	1009.910
# 2019-02-03 00:02	18.812	65.190	12.142	1009.930
# 2019-02-03 00:03	18.750	65.400	12.132	1009.930
# 2019-02-03 00:04	18.750	65.400	12.132	1009.940
# 2019-02-03 00:05	18.750	65.690	12.199	1010.020
# 2019-02-03 00:06	18.750	65.980	12.266	1010.050
# 2019-02-03 00:07	18.687	66.190	12.255	1009.990
# 2019-02-03 00:08	18.687	66.300	12.280	1009.960
# ```
#
# @example
#   writer = ObservationsWriter.new(metrics: METRICS)
#   writer.write(File.open("path/to/file.tsv"))
class ObservationsWriter
  attr_reader :observations

  # @params [Array<Observation>] observations The observations to be written.
  # @return [ObservationsWriter] The instance of the writer, allowing for method chaining.
  #
  def initialize(observations: [])
    @observations = observations

    self
  end

  def write(io)
    raise ArgumentError, "observations cannot be nil" if @observations.nil?

    # Write the header
    header_columns = ["observed_at"]
    header_columns += observations.first.metric_observations.map(&:metric).map(&:header)

    io.puts(header_columns.join("\t"))

    # Write the data
    observations.each do |observation|
      row = [observation.observed_at.strftime("%Y-%m-%d %H:%M")]
      row.concat(observation.metric_observations.map(&:value))
      io.puts(row.join("\t"))
    end

    self # Allow chaining
  end

end