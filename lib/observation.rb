class Observation
  attr_reader :observed_at, :metric_observations

  def initialize(observed_at:, metric_observations:)
    @observed_at = observed_at
    @metric_observations = metric_observations
  end

  # @param for: [Array<Symbol>] The metrics to filter by
  # @return [Array<Float>] The values of the specified metrics
  # @example
  #   observation.values(for: [:temp_f, :humidity_pct])
  #   # => [<Float>, <Float>]
  def values(metric_ids:)
    metric_ids.map{ |metric_id|
      self[metric_id]
    }
  end

  def observed_at_minute
    observed_at.strftime('%Y-%m-%d %H:%M')
  end

  # @param metric_id [Symbol] The metric ID to look up
  # @return [MetricObservation, nil] The MetricObservation object for the specified metric ID
  def metric_observation(metric_id:)
    metric_observations.find { _1.metric.id == metric_id }
  end

  # @param metric_id [Symbol, String] The metric ID to look up
  # @return [Float, nil] The value of the specified metric
  def [](metric_id)
    metric_observation(metric_id: metric_id.to_sym)&.value
  end

  def to_h
    {
      observed_at: observed_at,
      metric_observations: metric_observations.map(&:to_h)
    }
  end

  def to_s
    to_h.to_s
  end

end