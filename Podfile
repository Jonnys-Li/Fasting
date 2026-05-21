platform :ios, '17.0'
use_frameworks!

target 'Fasting' do
  pod 'Masonry', '~> 1.1.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |c|
      c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
