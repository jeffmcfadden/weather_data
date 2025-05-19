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

  def includes_metric?(metric_id)
    metric_observations.any? { _1.metric.id == metric_id }
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

  def fill_missing!
    fill_missing_temperatures!
    fill_missing_dewpoints!
  end

  private

  def fill_missing_temperatures!
    if includes_metric?(:temp_c) && !includes_metric?(:temp_f)
      metric_observations << MetricObservation.new(
        metric: Metric.find(:temp_f),
        observed_at: observed_at,
        value: ((self[:temp_c] * 9.0 / 5.0) + 32.0).round(4)
      )
    elsif includes_metric?(:temp_f) && !includes_metric?(:temp_c)
      metric_observations << MetricObservation.new(
        metric: Metric.find(:temp_c),
        observed_at: observed_at,
        value: ((self[:temp_f] - 32.0) * 5.0 / 9.0).round(4)
      )
    end
  end

  def fill_missing_dewpoints!
    if includes_metric?(:dewpoint_c) && !includes_metric?(:dewpoint_f)
      metric_observations << MetricObservation.new(
        metric: Metric.find(:dewpoint_f),
        observed_at: observed_at,
        value: ((self[:dewpoint_c] * 9.0 / 5.0) + 32.0).round(4)
      )
    elsif includes_metric?(:dewpoint_f) && !includes_metric?(:dewpoint_c)
      metric_observations << MetricObservation.new(
        metric: Metric.find(:dewpoint_c),
        observed_at: observed_at,
        value: ((self[:dewpoint_f] - 32.0) * 5.0 / 9.0).round(4)
      )
    end

  end

end