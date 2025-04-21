class ObservationAggregation
  attr_reader :observations, :aggregated_metrics

  def initialize(observations:)
    @observations = observations

    calculate_aggregated_metrics
  end

  def calculate_aggregated_metrics
    metric_ids = observations.flat_map do |observation|
      observation.metric_observations.map{ _1.metric.id }
    end.uniq

    @aggregated_metrics = {}
    metric_ids.each do |metric_id|
      metric_observations = observations.map{ _1.metric_observation(metric_id: metric_id) }

      @aggregated_metrics["#{metric_id}_max".to_sym]    = metric_observations.max_by(&:value)&.value
      @aggregated_metrics["#{metric_id}_max_at".to_sym] = metric_observations.max_by(&:value)&.observed_at
      @aggregated_metrics["#{metric_id}_min".to_sym]    = metric_observations.min_by(&:value)&.value
      @aggregated_metrics["#{metric_id}_min_at".to_sym] = metric_observations.min_by(&:value)&.observed_at

      if metric_observations.size > 0
        @aggregated_metrics["#{metric_id}_avg".to_sym]  = metric_observations.map(&:value).sum / metric_observations.size
      else
        @aggregated_metrics["#{metric_id}_avg".to_sym]  = nil
      end
    end
  end
end