require 'gdata'

class Contacts
  class Gmail < Base
    
    CONTACTS_SCOPE = 'http://www.google.com/m8/feeds/'
    CONTACTS_FEED = CONTACTS_SCOPE + 'contacts/default/full/?max-results=1000'
    
    def contacts
      fetch_contacts unless @contacts
      return @contacts if @contacts
    end
    
    def real_connect
      @client = GData::Client::Contacts.new
      @client.clientlogin(@login, @password, @captcha_token, @captcha_response)
    rescue GData::Client::AuthorizationError => e
      raise AuthenticationError, "Username or password are incorrect"
    rescue GData::Client::CaptchaError => e
      raise CaptchaError
    end

  TYPES[:gmail] = Gmail

  protected
    def fetch_contacts
      feed = @client.get(CONTACTS_FEED).to_xml
      
      @contacts = feed.elements.to_a('entry').collect do |entry|
        title, email = entry.elements['title'].text, nil
        entry.elements.each('gd:email') do |e|
          email = e.attribute('address').value if e.attribute('primary')
        end
        [title, email] unless email.nil?
      end
      @contacts.compact!
    end
  end
end
