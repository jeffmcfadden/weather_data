def render_daily_summary(date:)
  dy = date.year.to_s
  dm = date.month.to_s.rjust(2, '0')
  dd = date.day.to_s.rjust(2, '0')

  daily_summary = DailySummary.new(date: date)

  daily_summary_path = File.join(SITE_DIR, dy, dm, "#{dy}-#{dm}-#{dd}.html")
  daily_summary_template = File.open(File.join(SITE_DIR, "templates", "daily_summary.html.erb")).read

  rendered = ERB.new(daily_summary_template).result_with_hash({ daily_summary: daily_summary } )

  FileUtils.mkdir_p File.join(SITE_DIR, dy, dm)
  File.open(daily_summary_path, 'w') do |f|
    f.write(rendered)
  end
end

def render_current_conditions
  year = Time.now.year
  month = Time.now.strftime("%m")
  ymd = Time.now.strftime("%Y-%m-%d")

  observations_path = File.join(ROOT_DIR, "observations", "#{year}", "#{month}", "#{ymd}.tsv")
  observations = []

  File.open(observations_path) do |f|
    observations = ObservationsLoader.new(metrics: METRICS).load(f).observations
  end

  current_conditions = observations.sort_by(&:observed_at).last

  # Calculate daily high and low temperatures
  daily_temperatures = observations.map { |obs| obs.metric_observations.find { |mo| mo.metric.id == :temp_f }&.value }
  daily_high = daily_temperatures.compact.max
  daily_low = daily_temperatures.compact.min

  # Write the current conditions to index.html
  template = File.open(File.join(SITE_DIR, "templates", "index.html.erb")).read

  template_locals = current_conditions.metric_observations.map { |mo|
    [mo.metric.id, mo.value]
  }.to_h

  template_locals[:ts] = Time.now.to_i
  template_locals[:current_datetime] = current_conditions.observed_at.strftime('%Y-%m-%d %H:%M')
  template_locals[:daily_high] = daily_high
  template_locals[:daily_low] = daily_low

  other_years_summaries = (BEGINNING_OF_OBSERVATIONS.year..(Date.today.year)).map do |y|
    [y, DailySummary.new(date: Date.new(y, Time.now.month, Time.now.day))]
  end

  rendered = ERB.new(template).result_with_hash(template_locals.merge({ other_years_summaries: other_years_summaries }))

  File.open(File.join(SITE_DIR, "index.html"), 'w') do |f|
    f.write(rendered)
  end

  # Now let's generate a plot of today's temperature
  render_simple_metric_graph(metric: Metric.find(:temp_f),
                             output_name: "temperature_today.png",
                             observations_path: observations_path,
                             line_color: "purple")

  # And the solar radiation
  render_simple_metric_graph(metric: Metric.find(:solar_radiation_wm2),
                             output_name: "solar_radiation_today.png",
                             observations_path: observations_path,
                             line_color: "orange")
end