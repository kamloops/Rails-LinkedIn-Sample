module TutorialHelper
  
  require 'oauth/consumer'
  
  def main
    # OAuth code
    authorize
    
    if(!@access_token.token.nil?)
      # Retrieve basic profile info for the logged in user
      puts "\nGet Basic Profile Info"
      response = @access_token.get("http://api.linkedin.com/v1/people/~")
      puts response
      
      # Retrieve basic profile info in JSON format for the logged in user
      puts "\nGet Basic Profile Info in JSON format"
      response = @access_token.get("http://api.linkedin.com/v1/people/~?format=json")
      puts response
      
      # Retrieve connections for the logged in user
      puts "\nGet Profile Connections"
      response = @access_token.get("http://api.linkedin.com/v1/people/~/connections?count=10")
      puts response
      
      # Retrieve just job titles of all logged in user's connections using field selectors
      puts "\nGet Job Titles of All Connections"
      response = @access_token.get("http://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,positions:(title))")
      puts response
      
      # Searches for companies using "Maple" and "Leaf" as search parameters
      puts "\nSearch for companies using Maple and Leaf as keywords"
      response = @access_token.get("http://api.linkedin.com/v1/company-search?keywords=maple&leaf")
      puts response
      
      # Gets 50 network updates along with pictures for logged in user using query parameters
      puts "\nGet Network Updates using query parameters"
      response = @access_token.get("http://api.linkedin.com/v1/people/~/network/updates?type=STAT&type=PICT&count=50&start=50")
      puts response
            
      # Write to logged in user's share feed
      puts "\nWrite to Logged In User's Share Feed"
      response = @access_token.post("http://api.linkedin.com/v1/people/~/shares", static_xml, {'Content-Type'=>'application/xml'})
      puts response
      
    end
  end
  
  private
  
  def authorize
    # The following auth values belong in the config, but for the sake of this exercise will be hard coded
    api_key = 'XXXXXXXXXX'
    api_secret = 'XXXXXXXXXXXX'
    configuration = { :site => 'https://api.linkedin.com',
                         :authorize_path => 'https://api.linkedin.com/uas/oauth/authorize',
                         :request_token_path => 'https://api.linkedin.com/uas/oauth/requestToken',
                         :access_token_path => 'https://api.linkedin.com/uas/oauth/accessToken' }

    consumer = OAuth::Consumer.new(api_key, api_secret, configuration)
    
    if File::exists?( "service.dat" ) && !File.zero?( "service.dat" )
      # Read from file and grab access token and secret
      arr = IO.readlines("service.dat")
      token = arr[0].chomp # Gets rid of \n
      secret = arr[1]

      # Retrieve the access token object passing in the consumer object along with the token and secret from the temp file
      @access_token = OAuth::AccessToken.new(consumer, token, secret)
    else
      #Request token
      request_token = consumer.get_request_token
      
      # Output request URL to console
      puts "Please visit this URL: " + request_token.authorize_url + " in your browser and then input the numerical code you are provided here: "
      
      # Set verifier code
      verifier = $stdin.gets.strip
      
      # Retrieve access token object
      @access_token = request_token.get_access_token(:oauth_verifier => verifier)
      
      # Write access token and secret to file
      file = File.new("service.dat", "r+")
      if file
        aFile.syswrite(@access_token.token)
        aFile.syswrite(@access_token.secret)
      end
    end  
  end
  
  def static_xml
    xml = "<share>
      <comment>I've shared this via the LinkedIn Share API :)</comment>
      <content>
    	 <title>Detroit Red Wings: Revamped customer-focused business strategy helps make Hockeytown history</title>
    	 <submitted-url>http://www.mlive.com/redwings/index.ssf/2012/04/detroit_red_wings_revamped_cus.html</submitted-url>
    	 <submitted-image-url>http://media.mlive.com/detroit/photo/2012/04/10841011-large.jpg</submitted-image-url>
      </content>
      <visibility>
    	 <code>anyone</code>
      </visibility>
    </share>"
  end
  
end
