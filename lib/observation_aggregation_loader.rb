class ObservationAggregationLoader
  attr_reader :observation_aggregation

  def initialize(metrics: [])
    @metrics = metrics
    @observation_aggregation = nil
  end

  def load(io)
    # File has only 2 lines, the headers and a single data line.
    # Read that all into a hash and return that for now.

    hash = {}
    header = io.gets.strip.split("\t").map(&:strip)
    data = io.gets.strip.split("\t").map(&:strip)
    header.each_with_index do |key, index|
      next if key.empty? || data[index].empty?
      hash[key] = data[index]
    end

    hash
  end

end