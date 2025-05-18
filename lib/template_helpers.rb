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