def render_simple_metric_graph(metric:, output_name:, observations_path:, line_color: "#0077cc")
  # We need to grab the column index of the value we care about, from this file
  header = File.open(observations_path, &:readline).strip.split("\t")
  col_index = header.index(metric.header) + 1

  # Read the first column of line 2 and get the date
  # Format is: 2025-05-18 00:06
  ymd = Time.strptime(File.readlines(observations_path)[1], "%Y-%m-%d %H:%M").strftime("%Y-%m-%d")

  # Create a temporary file to store the gnuplot script
  Dir.mktmpdir do |dir|
    gp_file_path = File.join(dir, "gnuplot_script.gp")

    gnuplot_script = <<~GNUPLOT
      set terminal pngcairo size 800,400 enhanced font 'Verdana,10'
      set output '#{File.join(SITE_DIR, "images", output_name)}'
      set datafile separator '\t'
      set xdata time
      set timefmt "%Y-%m-%d %H:%M"
      set format x "%H:%M"
      set title "#{metric.name} on #{ymd}"
      set xlabel "Time"
      set ylabel "#{metric.name}"
      set grid
      plot '#{observations_path}' using 1:#{col_index} with lines linecolor rgb "#{line_color}" title '#{metric.name}'
    GNUPLOT

    File.open(gp_file_path, "w") do |gnuplot|
      gnuplot.write(gnuplot_script)
    end

    # Run gnuplot
    cmd = "gnuplot #{gp_file_path}"
    puts `#{cmd}`
  end
end
