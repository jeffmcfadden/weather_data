class ObservationsLoader
  attr_reader :observations

  def initialize(metrics: [])
    @metrics = metrics.map{ [_1.header, _1] }.to_h
    @observations = []
  end

  # Loads observations from a TSV source
  # @param [IO] io The IO object to read from. This can be a file, string, etc.
  # @return [ObservationsLoader] The instance of the loader, allowing for method chaining.
  def load(io)
    header_columns = []

    io.each_line do |line|
      next if line.strip.empty? # Skip empty lines

      if header_columns.empty?
        # Read the header line to determine the number of columns
        header_columns = line.split("\t").map(&:strip)
        next # A truly empty file will just break stuff, sorry.
      end

      # Split the line into columns
      columns = line.split("\t")

      # The first column is the observed_at timestamp
      observed_at = Time.strptime(columns[0], "%Y-%m-%d %H:%M")

      # The rest of the columns are metric observations
      metric_observations = columns[1..].map.with_index do |value, index|
        metric = @metrics[header_columns[index + 1]]

        MetricObservation.new(
          metric: metric,
          observed_at: observed_at,
          value: value.to_f
        )
      end

      @observations << Observation.new(observed_at: observed_at, metric_observations: metric_observations)
    end

    self # Allow chaining
  end

end