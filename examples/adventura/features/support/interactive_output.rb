module InteractiveOutput
  def all_stdout
    out = only_processes.inject("") { |out, ps| out << ps.stdout(@aruba_keep_ansi) }
    announcer.stdout(out)
    out
  end

  def truncate_stdout
    only_processes.each{ |ps| ps.out.truncate(0) }
  end

  def all_stderr
    only_processes.inject("") { |out, ps| out << ps.stderr(@aruba_keep_ansi) and ps.err.truncate(0) and out }
  end

  def type(input)
    truncate_stdout
    super
  end
end

World(InteractiveOutput)


module TruncateIO
  attr_reader :out, :err
end

Aruba::Process.send(:include, TruncateIO)
