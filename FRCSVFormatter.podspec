Pod::Spec.new do |s|
  s.name         = "FRCSVFormatter"
  s.version      = "0.0.2"
  s.summary      = "  Simple CSV formatter for CocoaLumberJack"

  s.description  = <<-DESC
  CSV formatter for cocoa lumber jack Ideal for making log files
                   DESC

  s.homepage     = "https://github.com/veritech/FRCSVFormatter"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jonathan Dalrymple" => "jonathan@float-right.co.uk" }
  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.7"
  s.source       = { :git => "https://github.com/veritech/FRCSVFormatter.git", :tag => "0.0.2" }

  s.source_files = "FRCSVFormatter.h","FRCSVFormatter.m"
  s.requires_arc = true
  s.dependency   'CocoaLumberjack', '~> 2.0.0'
end
