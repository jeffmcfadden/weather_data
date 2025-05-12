class MetricObservation
  attr_reader :metric, :observed_at, :value

  # @param [Metric] metric The metric associated with this observation.
  # @param [Time] observed_at The time the observation was made.
  # @param [Float] value The value of the observation.
  def initialize(metric:, observed_at:, value:)
    @metric = metric
    @observed_at = observed_at
    @value = value
  end

  def observed_at_minute
    observed_at.strftime('%Y-%m-%d %H:%M')
  end

  def to_h
    {
      metric_id: metric&.id,
      observed_at: observed_at,
      value: value
    }
  end

  def to_s
    to_h.to_s
  end

end