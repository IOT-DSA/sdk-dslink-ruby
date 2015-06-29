Dir[File.join(".", "**/*.rb")].each do |f|
  require f
end

$LINK = DSLink::Link.instance