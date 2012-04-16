module InteractiveOutput
  def all_stdout
    out = only_processes.inject("") { |out, ps| out << ps.stdout(@aruba_keep_ansi) }
    announcer.stdout(out)
    out
  end

  def truncate_stdout
    only_processes.each{ |ps| truncate(ps.out) }
  end

  def truncate(io)
    io.rewind
    backup << read = io.read.gsub("\0", '')
    io.truncate(0)
    read
  end

  def all_stderr
    only_processes.inject("") { |out, ps| out << ps.stderr(@aruba_keep_ansi) and truncate(ps.err) }
  end

  def type(input)
    truncate_stdout
    backup.last << input
    super
  end

  def backup
    @backup ||= []
  end

end

World(InteractiveOutput)

module InteractiveReporting
  def output
    @aruba_keep_ansi = true # We want the output coloured!

    escaped_stdout = CGI.escapeHTML(backup.join("\n"))
    html = Bcat::ANSI.new(escaped_stdout).to_html
    Bcat::ANSI::STYLES.each do |name, style|
      html.gsub!(/style='#{style}'/, %{class="xterm_#{name}"})
    end

    html
  end

  def description
    [steps, super].join("\n")
  end

  def steps
    steps = @scenario.raw_steps.map{|s| " #{s.keyword} " << [s.name, s.multiline_arg].compact.join("\n") }
    steps.insert(0, "### Steps\n")
    RDiscount.new(steps.join("\n")).to_html
  end
end

World(InteractiveReporting) if ENV['ARUBA_REPORT_DIR']

module TruncateIO
  attr_reader :out, :err
end

Aruba::Process.send(:include, TruncateIO)
