Pod::Spec.new do |s|
  s.name         = "SensorsDiagnosis"
  s.version      = "0.0.2"
  s.summary      = "The official iOS SDK of Sensors Diagnosis."
  s.homepage     = "http://www.sensorsdata.cn"
  s.source       = { :git => 'https://github.com/sensorsdata/sensors-diagnosis-sdk.git', :tag => "v#{s.version}" }
  s.license = { :type => "Apache License, Version 2.0" }
  s.author = { "Yuguo Chen" => "chenyuguo@sensorsdata.cn" }
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.13'
  s.default_subspec = 'Core'
  s.frameworks = 'Foundation'
  base_dir = "SensorsDiagnosis/SensorsDiagnosis"

  s.subspec 'Core' do |c|
    c.source_files = base_dir + '/**/*.{h,m}'
    c.public_header_files = base_dir + '/include/*.h'
  end

end