class MetricObservation
  attr_reader :metric, :observed_at, :value

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