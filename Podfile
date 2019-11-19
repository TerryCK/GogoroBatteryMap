# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
use_frameworks!

pod 'AlamofireNetworkActivityLogger'
pod 'SideMenu', '~> 5.0.1'
pod 'ColorMatchTabs'
pod 'Google-Mobile-Ads-SDK'
pod 'Fabric'
pod 'Crashlytics'
pod 'Firebase/Core'
pod 'SwiftyStoreKit'
pod 'Cluster', :git => 'https://github.com/efremidze/Cluster.git', :tag => '3.0.0'
pod 'FloatingPanel'
end

target 'GogoroMap' do

    shared_pods
    
end


target 'GogoroMapTests' do
    
    shared_pods
    
end

  # Pods for GogoroMap



post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
     config.build_settings['SWIFT_VERSION'] = '5'
    end
  end
end
