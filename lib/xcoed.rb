require 'xcoed/version'
require 'xcoed/constants'
require 'xcodeproj'
require 'json'

module Xcoed
  def self.integrate_package_swift!(project)
    package_json = JSON.parse(`swift package dump-package`)

    packages = {}
    package_json['dependencies'].each do |dependency|
      package_ref = add_swift_package_reference(project, dependency['scm'][0])
      packages[dependency['name']] = package_ref
    end

    package_json['targets'].each do |target|
      target_ref = project.targets.select { |t| t.name == target['name'] }.first
      raise "Target `#{target['name']}` not found in project" if target_ref.nil?

      target['dependencies'].each do |dependency|
        by_name = dependency['byName'].first

        target_ref.package_product_dependencies
                  .select { |p| p.product_name == by_name }
                  .each(&:remove_from_project)

        package_dep = Xcodeproj::Project::Object::XCSwiftPackageProductDependency.new(project, project.generate_uuid)
        package_dep.product_name = by_name

        target_ref.package_product_dependencies << package_dep
      end
    end
  end

  def self.add_swift_package_reference(project, dependency)
    STDERR.puts dependency
    requirement_type = dependency['requirement'].keys.first
    case requirement_type
    when 'range'
      add_remote_swift_package_range_reference(project, dependency)
    when 'branch'
      add_remote_swift_package_branch_reference(project, dependency)
    when 'revision'
      add_remote_swift_package_revision_reference(project, dependency)
    when 'localPackage'
      add_local_swift_package_reference(project, dependency)
    else
      raise "Unsupported package requirement `#{requirement_type}`"
    end
  end

  def self.add_remote_swift_package_range_reference(project, dependency)
    project.root_object.package_references
           .select { |r| r.repositoryURL.downcase == dependency['location'].downcase }
           .each(&:remove_from_project)

    package_ref = Xcodeproj::Project::Object::XCRemoteSwiftPackageReference.new(project, project.generate_uuid)
    package_ref.repositoryURL = dependency['location']
    package_ref.requirement = {
      'kind' => 'versionRange',
      'minimumVersion' => dependency['requirement']['range'][0]['lowerBound'],
      'maximumVersion' => dependency['requirement']['range'][0]['upperBound']
    }
    project.root_object.package_references << package_ref
    package_ref
  end

  def self.add_remote_swift_package_branch_reference(project, dependency)
    project.root_object.package_references
           .select { |r| r.repositoryURL.downcase == dependency['location'].downcase }
           .each(&:remove_from_project)

    package_ref = Xcodeproj::Project::Object::XCRemoteSwiftPackageReference.new(project, project.generate_uuid)
    package_ref.repositoryURL = dependency['location']
    package_ref.requirement = {
      'kind' => 'branch',
      'branch' => dependency['requirement']['branch'].first
    }
    project.root_object.package_references << package_ref
    package_ref
  end

  def self.add_remote_swift_package_revision_reference(project, dependency)
    project.root_object.package_references
           .select { |r| r.repositoryURL.downcase == dependency['location'].downcase }
           .each(&:remove_from_project)

    package_ref = Xcodeproj::Project::Object::XCRemoteSwiftPackageReference.new(project, project.generate_uuid)
    package_ref.repositoryURL = dependency['location']
    package_ref.requirement = {
      'kind' => 'revision',
      'revision' => dependency['requirement']['revision'].first
    }
    project.root_object.package_references << package_ref
    package_ref
  end

  def self.add_local_swift_package_reference(project, dependency)
    local_packages_group = local_packages_group(project)
    local_packages_group.children
                        .select { |c| File.expand_path(c.path).downcase == dependency['location'].downcase }
                        .each(&:remove_from_project)
    package_ref = Xcodeproj::Project::Object::FileReferencesFactory.new_reference(local_packages_group, dependency['location'], :group)
    package_ref.last_known_file_type = 'folder'
    package_ref
  end

  def self.local_packages_group(project)
    name = 'Local Packages'
    project.main_group.groups.select { |g| g.name == name }.first ||
      project.main_group.new_group(name)
  end
end
