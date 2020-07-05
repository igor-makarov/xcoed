require 'xcoed/version'
require 'xcoed/constants'
require 'xcodeproj'
require 'json'

module Xcoed
  def self.integrate_package_swift!(project)
    package_json = JSON.parse(`swift package dump-package`)

    packages = {}
    package_json['dependencies'].each do |dependency|
      package_ref = add_swift_package_reference(project, dependency)
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
        package_dep.product_name = by_name

        if package_ref.kind_of?(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
          package_dep.package = package_ref
        end

        target_ref.package_product_dependencies << package_dep
      end
    end
  end

  def self.add_swift_package_reference(project, dependency)
    STDERR.puts dependency
    requirement_type = dependency['requirement'].keys.first
    case requirement_type
    when 'range'
      add_remote_swift_package_reference(project, dependency)
    when 'localPackage'
      add_local_swift_package_reference(project, dependency)
    else
      raise "Unsupported package requirement `#{requirement_type}`"
    end
  end

  def self.add_remote_swift_package_reference(project, dependency)
    package_ref = Xcodeproj::Project::Object::XCRemoteSwiftPackageReference.new(project, project.generate_uuid)
    package_ref.repositoryURL = dependency['url']
    package_ref.requirement = {
      'kind' => 'versionRange',
      'minimumVersion' => dependency['requirement']['range'][0]['lowerBound'],
      'maximumVersion' => dependency['requirement']['range'][0]['upperBound']
    }
    project.root_object.package_references << package_ref
    package_ref
  end

  def self.add_local_swift_package_reference(project, dependency)
    local_packages_group = local_packages_group(project)
    package_ref = Xcodeproj::Project::Object::FileReferencesFactory.new_reference(local_packages_group, dependency['url'], :group)
    package_ref.last_known_file_type = 'folder'
    package_ref
  end

  def self.local_packages_group(project)
    name = 'Local Packages'
    project.main_group.groups.select { |g| g.name == name }.first ||
      project.main_group.new_group(name)
  end
end
