libdir = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'webmock/rspec'
