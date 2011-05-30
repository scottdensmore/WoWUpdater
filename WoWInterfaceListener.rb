require 'rexml/document'
require 'rexml/streamlistener'

require 'Addon'

include REXML

class WoWInterfaceListener
	
	include REXML::StreamListener

	def initialize(raw_xml, name)
		@raw_xml = raw_xml
		@current_element = nil
		@current_addon = nil
		@name = name
	end

	def get_addons
		Document.parse_stream( @raw_xml, self)
		@current_addon
	end

	def tag_start(name, attributes)
		case name
		when 'Current'
			@current_addon = Addon.new
			@current_addon.name = @name;
		else
			@current_element = name
		end
	end

	def text(text)
		case @current_element
		when 'UIFileURL'
		  if @current_addon then
				@current_addon.url = text
			end
		when 'UIVersion'
			if @current_addon then
				@current_addon.remote_version = text
			end
		end
		@current_element = nil
	end
end


