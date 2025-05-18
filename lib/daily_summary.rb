class DailySummary
  attr_reader :date, :observations

  def self.url_path_for(date:)
    y = date.year.to_s
    m = date.month.to_s.rjust(2, '0')
    d = date.day.to_s.rjust(2, '0')

    "/#{y}/#{m}/#{y}-#{m}-#{d}.html"
  end

  def url_path_for(date:)
    self.class.url_path_for(date: date)
  end

  def initialize(date:)
    date = Date.parse(date) if date.is_a?(String)

    @date = date
    @observations = []

    load_observations
  end

  def observed_metrics
    @observed_metrics ||= @observations.collect { _1.metric_observations.map(&:metric) }.flatten.uniq
  end

  # Determine if the DailySummary includes a specific metric
  # @param metric [Metric] The metric to check for
  # @return [Boolean] True if the metric is included, false otherwise
  # @example
  #   daily_summary.includes_metric?(metric: Metric.find(:temp_f))
  #   # => true or false
  def includes_metric?(metric:)
    raise ArgumentError, "Invalid metric" unless METRICS.include?(metric)

    @observations.any? { _1.metric_observation(metric_id: metric.id) }
  end

  # Find the maximum metric observation for the given metric
  # @param metric [Metric] The metric to find the maximum observation for
  # @return [MetricObservation, nil] The maximum observation for the specified metric, or nil if no observations exist
  def max_observation(metric:)
    raise ArgumentError, "Invalid metric" unless METRICS.include?(metric)

    metric_observations = @observations.collect { _1.metric_observation(metric_id: metric.id) }.compact
    return nil if metric_observations.empty?

    metric_observations.max_by(&:value)
  end

  # Find the minimum metric observation for the given metric
  # @param metric [Metric] The metric to find the maximum observation for
  # @return [MetricObservation, nil] The maximum observation for the specified metric, or nil if no observations exist
  def min_observation(metric:)
    raise ArgumentError, "Invalid metric" unless METRICS.include?(metric)

    metric_observations = @observations.collect { _1.metric_observation(metric_id: metric.id) }.compact
    return nil if metric_observations.empty?

    metric_observations.min_by(&:value)
  end


  # Find the maximum value for the given metric
  # @param metric [Metric] The metric to find the maximum value for
  # @return [Float, nil] The maximum value of the specified metric, or nil if no observations exist
  # @example
  #   daily_summary.max(metric: Metric.find(:temp_f))
  #   # => <Float> or nil
  def max_value(metric:)
    raise ArgumentError, "Invalid metric" unless METRICS.include?(metric)

    metric_values = @observations.collect { _1[metric.id] }.compact
    return nil if metric_values.empty?

    metric_values.max
  end

  # Find the minimum value for the given metric
  # @param metric [Metric] The metric to find the minimum value for
  # @return [Float, nil] The minimum value of the specified metric, or nil if no observations exist
  # @example
  #  daily_summary.min(metric: Metric.find(:temp_f))
  #  # => <Float> or nil
  def min_value(metric:)
    raise ArgumentError, "Invalid metric" unless METRICS.include?(metric)

    metric_values = @observations.collect { _1[metric.id] }.compact
    return nil if metric_values.empty?

    metric_values.min
  end

  # Return the average value for the given metric. Assumes equal distribution of observations.
  # @param metric [Metric] The metric to find the average value for
  # @return [Float, nil] The average value of the specified metric, or nil if no observations exist
  # @example
  #   daily_summary.average(metric: Metric.find(:temp_f))
  #   # => <Float> or nil
  def average_value(metric:)
    raise ArgumentError, "Invalid metric" unless METRICS.include?(metric)

    metric_values = @observations.collect { _1[metric.id] }.compact
    return nil if metric_values.empty?

    metric_values.sum / metric_values.size.to_f
  end


  private

  def load_observations
    y = date.year.to_s
    m = date.month.to_s.rjust(2, '0')
    d = date.day.to_s.rjust(2, '0')

    filename = File.join(__dir__, "..", "observations", y, m, "#{y}-#{m}-#{d}.tsv")

    return unless File.exist?(filename)

    @observations = ObservationsLoader.new(metrics: METRICS).load(File.open(filename)).observations
  end



end