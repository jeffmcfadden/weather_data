class Metric
  attr_reader :id, :name, :header, :unit

  def initialize(id:, name:, header:, unit:)
    @id = id
    @name = name
    @header = header
    @unit = unit
  end
end