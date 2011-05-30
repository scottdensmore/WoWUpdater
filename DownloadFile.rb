require 'net/http'
require 'pathname'

module Net
  class HTTP
		def HTTP.download_file(source_url, target_dir)
		  response = Net::HTTP.get_response(URI.parse(source_url))
			case response
      when Net::HTTPRedirection
        url = URI.parse(source_url)
        new_source_url = URI.join(url.scheme + "://" + url.host, response['location'])   
        Net::HTTP.download_file(new_source_url.to_s, target_dir)
      else
        do_download_file(source_url, target_dir)
      end
		end
		
		def HTTP.do_download_file(source_url, target_dir)
	    url = URI.parse(source_url)
      path_and_query = url.path
      if (url.query != nil) then path_and_query += "?" + url.query end
			request = Net::HTTP::Get.new(path_and_query)
			response = Net::HTTP.start(url.host, url.port) do |http|
				http.request(request)
			end
      # TODO: Filename comes from the URL
			filename = "temp.zip"
			target_path = Pathname.new(target_dir) + filename
			# response.body contains the data
			File.open(target_path, 'wb') do |file|
				file.write(response.body)
			end
      Pathname.new(target_dir) + filename
	  end
	end
end
