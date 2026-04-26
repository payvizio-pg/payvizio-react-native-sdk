Pod::Spec.new do |s|
  s.name             = 'PayvizioReactNative'
  s.version          = '0.1.0'
  s.summary          = 'React Native wrapper around the Payvizio iOS SDK.'
  s.homepage         = 'https://payvizio.com'
  s.license          = { :type => 'Apache-2.0' }
  s.author           = 'Payvizio'
  s.source           = { :path => '.' }
  s.platform         = :ios, '14.0'
  s.swift_version    = '5.9'
  s.source_files     = 'ios/**/*.{swift,h,m}'
  s.dependency 'React-Core'
  s.dependency 'Payvizio', '~> 0.1.0'
end
