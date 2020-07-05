require 'xcoed/version'
require 'xcoed/constants'
require 'xcodeproj'
require 'json'

module Xcoed
  def self.integrate_package_swift!(project)
    package_json = JSON.parse(`swift package dump-package`)

    packages = {}
    package_json['dependencies'].each do |dependency|
      STDERR.puts dependency
      package_ref = Xcodeproj::Project::Object::XCRemoteSwiftPackageReference.new(project, project.generate_uuid)
      package_ref.repositoryURL = dependency['url']
      package_ref.requirement = {
        'kind' => 'versionRange',
        'minimumVersion' => dependency['requirement']['range'][0]['lowerBound'],
        'maximumVersion' => dependency['requirement']['range'][0]['upperBound']
      }
      project.root_object.package_references << package_ref
      packages[dependency['name']] = package_ref
    end

    package_json['targets'].each do |target|
      target_ref = project.targets.select { |t| t.name == target['name'] }.first
      raise "Target `#{target['name']}` not found in project" if target_ref.nil?

      target['dependencies'].each do |dependency|
        by_name = dependency['byName'].first
        package_ref = packages[by_name]
        raise "Product `#{by_name}` not found in package references" if package_ref.nil?

        package_dep = Xcodeproj::Project::Object::XCSwiftPackageProductDependency.new(project, project.generate_uuid)
        package_dep.package = package_ref
        package_dep.product_name = by_name

        target_ref.package_product_dependencies << package_dep
      end
    end
  end
end
