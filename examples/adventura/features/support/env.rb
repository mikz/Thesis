require 'bundler/setup'

Bundler.require(:test)

if ENV['ARUBA_REPORT_DIR']
  Bundler.require(:reporting)
end

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

Before do
  @aruba_io_wait_seconds = (time = ENV['ARUBA_IO_WAIT']) ? time.to_f : 1.5
end

After do
  # quit processes
  terminate_processes!
end
