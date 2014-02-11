Pod::Spec.new do |s|
  s.name     = 'SANetworking'
  s.version  = '1.3.3.samba'
  s.license  = 'MIT'
  s.summary  = 'Renamed AFNetworking to SANetworking.'
  s.homepage = 'https://github.com/FlingoMobile/SANetworking'
  s.authors  = { 'Allen Schober' => 'allen@samba.tv' }
  s.source   = { :git => 'https://github.com/FlingoMobile/SANetworking.git', :tag => '1.3.3.samba' }
  s.source_files = 'SANetworking'
  s.requires_arc = true

  s.ios.deployment_target = '5.0'
  s.ios.frameworks = 'MobileCoreServices', 'SystemConfiguration', 'Security', 'CoreGraphics'

  s.osx.deployment_target = '10.7'
  s.osx.frameworks = 'CoreServices', 'SystemConfiguration', 'Security'

  s.prefix_header_contents = <<-EOS
#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
  #import <SystemConfiguration/SystemConfiguration.h>
  #import <MobileCoreServices/MobileCoreServices.h>
  #import <Security/Security.h>
#else
  #import <SystemConfiguration/SystemConfiguration.h>
  #import <CoreServices/CoreServices.h>
  #import <Security/Security.h>
#endif
EOS
end