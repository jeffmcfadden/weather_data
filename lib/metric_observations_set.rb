class MetricObservationsSet
  attr_reader :metric_observations

  delegate :each, :map, :select, :reject, :find, :find_index, :include?, :empty?, :size, to: :metric_observations

  def initialize(metric_observations:)
    @metric_observations = metric_observations
  end

  def add(metric_observation)
    @metric_observations << metric_observation
  end

  # Take a set of metric observations and group them by minute, convert them into an Observation
  # @return [Array<Observation>] An array of observations, each containing a list of metric observations from the same minute
  def to_observations
    metric_observations.group_by(&:observed_at_minute).map do |observed_at_minute, metric_observations|
      Observation.new(
        observed_at: metric_observations.first.observed_at,
        metric_observations: metric_observations
      )
    end
  end

  # Convert the metric observations set into an ObservationsSet
  # @return [ObservationsSet] An ObservationsSet containing the observations created from the metric observations
  def to_observations_set
    ObservationsSet.new(observations: to_observations)
  end


end