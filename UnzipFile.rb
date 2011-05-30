require 'fileutils'
require 'zip/zipfilesystem'

module Zip
	class ZipFile
		# We add a class helper method to ZipFile to make it easier to use
		def ZipFile.unzip_file(source, target)
			Zip::ZipFile.open(source) do |zipfile|
				zipfile.each do |entry|
					fpath = File.join(target, entry.name)
					FileUtils.mkdir_p(File.dirname(fpath))
					zipfile.extract(entry, fpath) do |entry, extract_loc|
						# We will always overwrite.. but I wonder how to just cause it to skip...
						File.delete extract_loc
					end
				end
			end
		end
	end
end

if __FILE__ == $0 then
	Zip::ZipFile.unzip_file(ARGV[0], ARGV[1])
end
