require 'pathname'

class WoWAce
  API_KEY = "?api-key=8bb80a603bcd39e65d95c137bef853696250c2de"
	URL_BASE = "http://www.wowace.com"
	@id = nil
	@name = nil
	
	def initialize(id, name)
		@id = id
		@name = name
	end
	
	def getAddon
	  url = URL_BASE + "/projects/" + @id + "/" + API_KEY
    html = fetch(url)
    #puts html
	  re = /<a href="(.*)"><span>Download<\/span><\/a>/ 
	  match = re.match(html)
	  if (!match) 
	    puts "Could not find " + @name + "."
	    return
	  end
	  urlPath = match[1]
	  #puts urlPath
	  url = URL_BASE + urlPath + API_KEY
	  html = fetch(url)
	  #puts html
	  re = /<a href="(.*)">Download<\/a>/
    match = re.match(html)
	  addonUrl = match[1]
	  createAddon(addonUrl)
  end
  
  def fetch(uri, limit = 10)
    # You should choose better exception.
    raise ArgumentError, 'Could not find ' + @name if limit == 0
    
    response = Net::HTTP.get_response(URI.parse(uri))
    case response
    when Net::HTTPSuccess     then response.body()
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
      response.error!
    end
  end
  
  def createAddon(addonUrl)
    addon = Addon.new
	  addon.name = @name
	  addon.url = addonUrl
	  index = addonUrl.rindex('/')
		fileName = addonUrl.slice(index + 1, addonUrl.length - (index))
		version = fileName.slice(0, fileName.length - 4)
		addon.remote_version = version
		addon
  end
end