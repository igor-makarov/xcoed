require 'json'
require 'xcoed'


package_json = Dir.chdir('spec/fixtures/swiftlint') do
  JSON.parse(`swift package dump-package`)
end

require 'pry'; binding.pry
