# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
# ignore all warnings from all pods
inhibit_all_warnings!

target 'Funnel' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'TesseractOCRiOS'
  pod 'AWSCore'
  pod 'AWSAppSync'

  # Pods for Funnel

  target 'FunnelTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FunnelUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end