class ObservationAggregationWriter
  attr_reader :observation_aggregation

  def initialize(observation_aggregation:)
    @observation_aggregation = observation_aggregation
  end

  def write(io)
    raise ArgumentError, "observation_aggregation cannot be nil" if @observation_aggregation.nil?

    # Write the header
    header = observation_aggregation.aggregated_metrics.keys
    io.puts(header.join("\t"))

    # Write the data
    io.puts observation_aggregation.aggregated_metrics.map{ |k, v| v.to_s }.join("\t")
  end
end