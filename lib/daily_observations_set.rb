class DailyObservationsSet
  attr_reader :date, :_observations

  delegate :each, :map, :select, :reject, :find, :find_index, :include?, :empty?, :size, to: :_observations

  def initialize(date:, observations: [])
    @date = date
    @_observations = observations

    validate_observations!
  end

  # @return [Array<Observation>] The observations for the given date, sorted by observed_at
  def observations
    @_observations.sort_by(&:observed_at)
  end

  def <<(o)
    if o.is_a?(Observation)
      add(o)
    elsif o.is_a?(Array)
      o.each{ |obs| add(obs) }
    else
      raise ArgumentError, "Expected Observation or Array of Observations, got #{o.class}"
    end
  end

  # Add an observation to the set
  # @param observation [Observation] The observation to add
  # @return [DailyObservationsSet] The updated DailyObservationsSet
  def add(observation)
    raise "Observation date does not match the set date" unless observation.observed_at.to_date == date

    # Remove any existing observations with the same hour and minute
    @_observations.delete_if do |obs|
      obs.observed_at.hour == observation.observed_at.hour &&
      obs.observed_at.min == observation.observed_at.min
    end

    @_observations << observation

    self
  end

  private

  def validate_observations!
    raise "Observations must match the date" unless observations.all? { |observation| observation.observed_at.to_date == date }
  end

end