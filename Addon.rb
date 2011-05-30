 require 'pathname'

class Addon
	attr_accessor :name, :remote_version, :url, :dependencies
	@local_version = nil
	@@addons_folder = nil
  
	VER_FILE_NAME = "current.ver"

  def initialize
    @dependencies = Array.new
  end

	def Addon.addons_folder=(value)
		@@addons_folder = value
	end

	def Addon.addons_folder
		return @@addons_folder
	end

	def dir
		Pathname.new(@@addons_folder) + @name
	end

	def local_version
		if @local_version == nil then
			ver_file = dir + VER_FILE_NAME

			if ver_file.exist? then
				@local_version = ver_file.read.chomp
			else
				@local_version = "(no version)"
			end
		end

		@local_version
	end

	def local_version=(new_val)
		if new_val != @local_version then
			ver_file = dir + VER_FILE_NAME
			ver_file.open("w") do |file|
				file.write new_val
			end
			@local_version = new_val
		end
	end

	def update_needed?
		return local_version != remote_version
	end
end


