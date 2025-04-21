class Observation
  attr_reader :observed_at, :metric_observations

  def initialize(observed_at:, metric_observations:)
    @observed_at = observed_at
    @metric_observations = metric_observations
  end

  def observed_at_minute
    observed_at.strftime('%Y-%m-%d %H:%M')
  end

  def metric_observation(metric_id:)
    metric_observations.find { _1.metric.id == metric_id }
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