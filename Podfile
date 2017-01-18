use_frameworks!

target "NuBrick" do
    pod 'JGProgressHUD'
    pod 'Charts', '~> 3.0.1'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
        end
    end
end
