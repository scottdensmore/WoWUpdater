# Synthetic local regression tests. Never load the updater or download/unzip code.
require 'tmpdir'
require 'fileutils'
require 'Addon'
require 'WoWInterfaceListener'
require 'UiWowNetListener'

def assert(condition, message)
  raise message unless condition
end

def addon_at(root, remote = '2.0')
  Addon.addons_folder = root
  FileUtils.mkdir_p(File.join(root, 'SyntheticAddon'))
  addon = Addon.new
  addon.name = 'SyntheticAddon'
  addon.remote_version = remote
  addon
end

cases = {
  'missing local version needs an update' => lambda { |root|
    addon = addon_at(root)
    assert(addon.local_version == '(no version)', 'missing-version marker changed')
    assert(addon.update_needed?, 'missing local addon must need an update')
  },
  'version record survives a fresh instance' => lambda { |root|
    addon = addon_at(root)
    addon.local_version = '2.0'
    assert(File.read(File.join(root, 'SyntheticAddon', 'current.ver')) == '2.0', 'record was not written')
    reloaded = addon_at(root)
    assert(reloaded.local_version == '2.0', 'record did not reload')
    assert(!reloaded.update_needed?, 'matching versions must not need an update')
  },
  'different remote version needs an update' => lambda { |root|
    addon = addon_at(root)
    addon.local_version = '1.0'
    assert(addon.update_needed?, 'different versions must need an update')
  },
  'local version ignores trailing record newline' => lambda { |root|
    addon = addon_at(root)
    File.write(File.join(root, 'SyntheticAddon', 'current.ver'), "2.0\n")
    assert(addon.local_version == '2.0', 'record newline leaked into version')
    assert(!addon.update_needed?, 'record newline must not cause an update')
  },
  'dependency lists belong to each addon' => lambda { |_root|
    first = Addon.new
    second = Addon.new
    first.dependencies << 'SyntheticDependency'
    assert(second.dependencies.empty?, 'addon dependency lists are shared')
  },
  'WoWInterface XML yields name URL and version' => lambda { |_root|
    xml = '<Updates><Current><UIFileURL>https://example.invalid/addon.zip</UIFileURL><UIVersion>2.0</UIVersion></Current></Updates>'
    addon = WoWInterfaceListener.new(xml, 'SyntheticAddon').get_addons
    assert(addon.name == 'SyntheticAddon', 'addon name was not retained')
    assert(addon.url == 'https://example.invalid/addon.zip', 'download URL was not parsed')
    assert(addon.remote_version == '2.0', 'remote version was not parsed')
  },
  'UiWoWNet XML retains URL filename as its remote version' => lambda { |_root|
    xml = '<Updates><mod><url>https://example.invalid/files/Addon-2.0.zip</url></mod></Updates>'
    addon = UiWoWNetListener.new(xml, 'SyntheticAddon').get_addons
    assert(addon.name == 'SyntheticAddon', 'addon name was not retained')
    assert(addon.url == 'https://example.invalid/files/Addon-2.0.zip', 'download URL was not parsed')
    assert(addon.remote_version == 'Addon-2.0.zip', 'remote filename was not parsed')
  },
  'empty WoWInterface update contains no addon' => lambda { |_root|
    assert(WoWInterfaceListener.new('<Updates/>', 'SyntheticAddon').get_addons.nil?, 'empty feed invented an addon')
  },
  'empty UiWoWNet update contains no addon' => lambda { |_root|
    assert(UiWoWNetListener.new('<Updates/>', 'SyntheticAddon').get_addons.nil?, 'empty feed invented an addon')
  }
}

failures = []
cases.each do |name, test|
  begin
    Dir.mktmpdir('wow-ci-', ENV.fetch('RUNNER_TEMP')) { |root| test.call(root) }
    puts "PASS: #{name}"
  rescue StandardError => error
    failures << name
    warn "FAIL: #{name}: #{error.class}: #{error.message}"
  end
end
puts "#{cases.length - failures.length} passed, #{failures.length} failed, 0 skipped"
exit(failures.empty? ? 0 : 1)
