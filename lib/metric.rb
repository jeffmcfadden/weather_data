class Metric
  attr_reader :id, :name, :header, :unit

  def initialize(id:, name:, header:, unit:)
    @id = id
    @name = name
    @header = header
    @unit = unit
  end

  def ==(other)
    return false unless other.is_a?(Metric)
    id == other.id
  end

  def eql?(other)
    return false unless other.is_a?(Metric)
    id == other.id
  end

  def self.all
    METRICS
  end

  def self.find(id)
    METRICS.find { |metric| metric.id == id }
  end

  def self.find_by_name(name)
    METRICS.find { |metric| metric.name == name }
  end

end