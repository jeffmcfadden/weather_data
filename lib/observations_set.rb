class ObservationsSet
  attr_reader :observations

  delegate :each, :map, :select, :reject, :find, :find_index, :include?, :empty?, :size, to: :observations

  def initialize(observations:)
    @observations = observations
  end

  # Take a set of observations and group them by date, convert them into an ObservationSet
  # @return [ObservationsSet] An ObservationsSet containing the observations for the given date
  def find_by_date(date)
    ObservationsSet.new(observations:
      observations.find { |observation| observation.observed_at.strftime('%Y-%m-%d') == date }
    )
  end

  # Take a set of observations and group them by date
  # @example
  #   {
  #     "2023-10-01" => [observation1, observation2],
  #     "2023-10-02" => [observation3]
  #   }
  #
  # @return [Hash<String, Array<Observation>>] A hash where the keys are dates and the values are arrays of observations for that date
  def grouped_by_day
    observations.group_by { |observation| observation.observed_at.strftime('%Y-%m-%d') }
  end

end