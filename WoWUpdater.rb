#!/usr/bin/env ruby

# = Summary
# Downloads and installs the required AddOns for the Benevolent Thuggery guild on Dragonblight.
#
# = License
# Copyright (c) 2007 Quaiche of Dragonblight <quaiche@gmail.com>
# 
# This software is provided 'as-is', without any express or implied
# warranty. In no event will the authors be held liable for any damages
# arising from the use of this software.
# 
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
# 
# 1. The origin of this software must not be misrepresented; you must not
# claim that you wrote the original software. If you use this software
# in a product, an acknowledgment in the product documentation would be
# appreciated but is not required.
# 
# 2. Altered source versions must be plainly marked as such, and must not be
# misrepresented as being the original software.
# 
# 3. This notice may not be removed or altered from any source
# distribution.

require 'net/http'
require 'optparse'
require 'ostruct'
require 'pathname'
require 'rdoc/usage'
require 'tmpdir'

require 'Addon'
require 'UnzipFile'
require 'DownloadFile'
require 'UiWoWNetListener'
require 'WoWInterfaceListener'
require 'WoWAce'
require 'yaml'

RUNNING_ON_WINDOWS = /mswin32|cygwin|mingw|bccwin/i =~ RUBY_PLATFORM
RUNNING_ON_MAC = /darwin/i =~ RUBY_PLATFORM

class WoWUpdater
	def get_default_wowpath
		# This is all Win32. Wonder how do I find the WoW path on a Mac?
		if RUNNING_ON_WINDOWS then
			require 'win32/registry'

			install_path = "C:\\Program Files\\World of Warcraft"
			key = Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\\Blizzard Entertainment\\World of Warcraft')
			if key then
				key_type, key_value = key.read('InstallPath')
				if key_value then
					install_path = key_value
				end
			end
		elsif RUNNING_ON_MAC then 
		  	install_path = "/Applications/World\ of\ Warcraft/"
		else
			raise "Unable to determine WoW installation folder!"
		end

		return install_path
	end

	# 	thug_update [-wowpath <path>] [-h | --help] 
	def get_options
		options = OpenStruct.new
		options.help = false
		options.wowpath = nil

		parser = OptionParser.new do |parser|
			parser.on("-p", "--wowpath PATH", "Provide an alternate path for WOW.") do |path|
				options.wowpath = path 
			end

			parser.on_tail("-h", "Show this usage statement.") do |h|
				puts parser
				options.help = true
			end
		end.parse!
		
		if (options.wowpath == nil) then options.wowpath = get_default_wowpath end

		return options
	end

	def update_addon(addon)
	  #puts addon.url
		zipfile = Net::HTTP.download_file(addon.url, Dir.tmpdir)
    if (zipfile) then
		  Zip::ZipFile.unzip_file(zipfile, Addon.addons_folder)
		  addon.local_version = addon.remote_version
		end
	end
	
	def check_addon(addon, displayMessage)
	  if addon != nil then
	    if addon.update_needed? then
	      if displayMessage then
			    message = "Update required (Local version: #{addon.local_version}, Remote version: #{addon.remote_version})"
			  end
			  update_addon(addon)
		  else
		    if displayMessage then
			    message = "No update required. (Local version: #{addon.local_version})"
			  end
		  end
		  if displayMessage then 
		    printf("%-40s%s\n", addon.name, message)
	    end
	  end
  end
	
	def update_ace_addons()
	  puts "*** Downloading updates from wowace.com ***"
	  
	  addons = YAML.load_file("addons.yaml")
	  if addons && addons["Ace"] then
		  addons["Ace"].each do |name, id|
				addon = WoWAce.new(id, name).getAddon
		    check_addon(addon, true)
		  end
	  end
  end
  
  def update_wowinterface_addons()
    puts "*** Downloading updates from wowinterface.com ***"
		
	  addons = YAML.load_file("addons.yaml")
	  if addons && addons["WoWinterface"] then
		  addons["WoWinterface"].each do |name, id|
		    data = Net::HTTP.get(URI.parse('http://www.wowinterface.com/patcher' + id.to_s + '.xml'))
    	  addon = WoWInterfaceListener.new(data, name).get_addons
		    check_addon(addon, true)
		  end
	  end
  end
  
  def update_uiwownet_addons()
    puts "*** Downloading updates from ui.worldofwar.net ***"
		
	  addons = YAML.load_file("addons.yaml")
	  if addons && addons["UiWoWnet"] then
		  addons["UiWoWnet"].each do |name, id|
		    data = Net::HTTP.get(URI.parse('http://uicentral.incgamers.com/new/xml-view.php?id=' + id.to_s))
    	  addon = UiWoWNetListener.new(data, name).get_addons
		    check_addon(addon, true)
		  end
	  end
  end
  
  def main
		options = get_options

		if not options.help then
			Addon.addons_folder = (Pathname.new(options.wowpath) + "Interface" + "AddOns").to_s
			
			#update_ace_addons()
			update_uiwownet_addons()
			update_wowinterface_addons()
			
			puts "*** Update Complete ***"
		end
	end
end

if __FILE__ == $0 then
	WoWUpdater.new.main
end

