# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
use_frameworks!

pod 'AlamofireNetworkActivityLogger'
pod 'SideMenu', :git => 'https://github.com/jonkykong/SideMenu.git', :tag => '3.1.5'
pod 'Google-Mobile-Ads-SDK'
pod 'Fabric'
pod 'Crashlytics'
pod 'Firebase/Core'
pod 'SwiftyStoreKit'
pod 'Cluster', :git => 'https://github.com/efremidze/Cluster.git', :tag => '2.1.0'

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
    
      if target.name.include? 'SideMenu'
#          puts "#{target.name}"
          config.build_settings['SWIFT_VERSION'] = '4.0'
      elsif target.name.include? 'Cluster'
          config.build_settings['SWIFT_VERSION'] = '4.0'
      else
          config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
