require_relative '../lib/core'

class DailySummaryTest < TLDR

  def setup
    @summary = DailySummary.new(date: "2023-10-01")
  end

  def test_observations_loaded
    assert_equal 1440, @summary.observations.size
  end

  def test_max_temp_value
    assert_equal 29.045, @summary.max_value(metric: Metric.find(:temp_c))
  end

  def test_max_observation
    assert_equal 29.045, @summary.max_observation(metric: Metric.find(:temp_c)).value
  end

  def test_max_observation_time
    assert_equal Time.parse("2023-10-01 14:10:00 -07:00"), @summary.max_observation(metric: Metric.find(:temp_c)).observed_at
  end

  def test_min_temp_value
    assert_equal 19.553, @summary.min_value(metric: Metric.find(:temp_c))
  end

  def test_min_observation
    assert_equal 19.553, @summary.min_observation(metric: Metric.find(:temp_c)).value
  end

  def test_min_observation_time
    assert_equal Time.parse("2023-10-01 05:26:00 -07:00"), @summary.min_observation(metric: Metric.find(:temp_c)).observed_at
  end

  def test_includes_metric
    assert_equal true, @summary.includes_metric?(metric: Metric.find(:temp_c))
    assert_equal false, @summary.includes_metric?(metric: Metric.find(:uv_index))
  end




end