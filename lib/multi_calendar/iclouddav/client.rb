require "net/https"
require "rexml/document"

module Net
  class HTTP
    class Report < HTTPRequest
      METHOD = "REPORT"
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
    end
  end
end

module ICloud
  class Client
    attr_accessor :caldav_server, :carddav_server, :port, :email, :password,
      :debug

    DEFAULT_CALDAV_SERVER = "p01-caldav.icloud.com"
    DEFAULT_CARDDAV_SERVER = "p01-contacts.icloud.com"

    def initialize(email, password, caldav_server = DEFAULT_CALDAV_SERVER,
    carddav_server = DEFAULT_CARDDAV_SERVER)
      @email = email
      @password = password
      @caldav_server = caldav_server
      @carddav_server = carddav_server
      @port = 443

      @debug = false
      @_http_cons = {}
    end

    def principal
      @principal ||= fetch_principal
    end

    def calendars
      @calendars ||= fetch_calendars
    end

    def contacts
      @contacts ||= fetch_contacts
    end

    def get(host, url, headers = {})
      http_fetch(Net::HTTP::Get, host, url, headers)
    end

    def propfind(host, url, headers = {}, xml)
      http_fetch(Net::HTTP::Propfind, host, url, headers, xml)
    end

    def report(host, url, headers = {}, xml)
      http_fetch(Net::HTTP::Report, host, url, headers, xml)
    end

    def report_without_xml_parsing(host, url, headers = {}, xml)
      http_fetch(Net::HTTP::Report, host, url, headers, xml, false)
    end

    def put(host, url, headers = {}, xml)
      http_fetch(Net::HTTP::Put, host, url, headers, xml)
    end

    def delete(host, url, headers = {}, xml)
      http_fetch(Net::HTTP::Delete, host, url, headers, xml)
    end

    def fetch_calendar_data(url, start_date=nil, end_date=nil)

      xml_request = <<END
        <d:sync-collection xmlns:d="DAV:">
          <d:sync-token/>
          <d:prop>
            <d:getcontenttype/>
          </d:prop>
        </d:sync-collection>
END

      if start_date && end_date
        xml_request = <<END
        <C:calendar-query xmlns:D="DAV:"
                 xmlns:C="urn:ietf:params:xml:ns:caldav">
     <D:prop>
       <D:getetag/>
       <C:calendar-data>
         <C:comp name="VCALENDAR">
           <C:prop name="VERSION"/>
           <C:comp name="VEVENT">
             <C:prop name="SUMMARY"/>
             <C:prop name="UID"/>
             <C:prop name="DTSTART"/>
             <C:prop name="DTEND"/>
             <C:prop name="DURATION"/>
             <C:prop name="RRULE"/>
             <C:prop name="RDATE"/>
             <C:prop name="EXRULE"/>
             <C:prop name="EXDATE"/>
             <C:prop name="RECURRENCE-ID"/>
           </C:comp>
           <C:comp name="VTIMEZONE"/>
         </C:comp>
       </C:calendar-data>
     </D:prop>
     <C:filter>
       <C:comp-filter name="VCALENDAR">
         <C:comp-filter name="VEVENT">
           <C:time-range start="#{start_date.to_time.utc.to_datetime.strftime("%Y%m%dT%H%M%SZ")}"
                         end="#{end_date.to_time.utc.to_datetime.strftime("%Y%m%dT%H%M%SZ")}"/>
         </C:comp-filter>
       </C:comp-filter>
     </C:filter>
   </C:calendar-query>
END
      end


      xml = self.report(self.caldav_server, url, { "Depth" => 1 }, xml_request)

      # gather the separate .ics urls for each event in this calendar
      hrefs = []
      REXML::XPath.each(xml, "//response") do |resp|
        href = resp.elements["href"].text
        if href.present?
          hrefs.push href
        end
      end

      # bundle them all in one multiget
      xml = self.report(self.caldav_server, url, { "Depth" => 1 }, <<END
        <c:calendar-multiget xmlns:d="DAV:"
        xmlns:c="urn:ietf:params:xml:ns:caldav">
          <d:prop>
            <c:calendar-data />
          </d:prop>
          <c:filter>
            <c:comp-filter name="VCALENDAR" />
          </c:filter>
          #{hrefs.map{|h| '<d:href>' << h << '</d:href>'}.join}
        </c:calendar-multiget>
END
        )

      REXML::XPath.each(xml,
        "//multistatus/response/propstat/prop/calendar-data").map{|e| e.text }.
        join
    end

  private
    def http_fetch(req_type, hhost, url, headers = {}, data = nil, xml_process=true)
      # keep the connection alive since we're probably sending all requests to
      # it anyway and we'll gain some speed by not reconnecting every time
      if !(host = @_http_cons["#{hhost}:#{self.port}"])
        host = Net::HTTP.new(hhost, self.port)
        host.use_ssl = true

        host.verify_mode = OpenSSL::SSL::VERIFY_NONE # For development
        #host.verify_mode = OpenSSL::SSL::VERIFY_PEER


        if self.debug
          host.set_debug_output $stdout
        end

        # if we don't call start ourselves, host.request will, but it will do
        # it in a block that will call finish when exiting request, closing the
        # connection even though we're specifying keep-alive
        host.start

        @_http_cons["#{hhost}:#{self.port}"] = host
      end

      req = req_type.new(url)
      req.basic_auth self.email, self.password

      req["Connection"] = "keep-alive"
      req["Content-Type"] = "text/xml; charset=\"UTF-8\""


      headers.each do |k,v|
        req[k] = v
      end

      if data
        req.body = data
      end

      res = host.request(req)

      if req_type == Net::HTTP::Put || req_type == Net::HTTP::Delete
        res.code
      else
        if xml_process
          REXML::Document.new(res.body)
        else
          res.body
        end
      end
    end

    def fetch_principal
      xml = self.propfind(self.caldav_server, "/", { "Depth" => 1 },
        '<d:propfind xmlns:d="DAV:"><d:prop><d:current-user-principal />' <<
        '</d:prop></d:propfind>')

      REXML::XPath.first(xml,
        "//response/propstat/prop/current-user-principal/href").text
    end

    # returns an array of Calendar objects
    def fetch_calendars
      # this is supposed to propfind "calendar-home-set" but icloud doesn't
      # seem to support that, so we skip that lookup and hard-code to
      # "/[principal user id]/calendars/" which is what calendar-home-set would
      # probably return anyway

      xml = self.propfind(self.caldav_server,
        "/#{self.principal.split("/")[1]}/calendars/", { "Depth" => 1 },
        '<d:propfind xmlns:d="DAV:"><d:prop><d:displayname/></d:prop>' <<
        '</d:propfind>')

      cals = REXML::XPath.each(xml, "//multistatus/response").map do |cal|
        if cal
          path = cal.elements["href"].text
          begin
            if cal.elements['propstat'].elements['prop'].elements['displayname']
              name = cal.elements['propstat'].elements['prop'].elements['displayname'].text
              Calendar.new(self, path, name)
            end
          rescue NoMethodError
          end
        end
      end

      cals.compact
    end

    # returns an array of Contact objects
    def fetch_contacts
      carddav_home = "/#{self.principal.split("/")[1]}/carddavhome/card/"

      xml = self.propfind(self.carddav_server, carddav_home, { "Depth" => 1 },
        '<d:propfind xmlns:d="DAV:"><d:prop><d:resourcetype/></d:prop>' <<
        '</d:propfind>')

      # gather the separate .vcf urls for each non-addressbook object in this
      # calendar (looking for a text/vcard contenttype would be preferable, but
      # icloud doesn't show that for all cards)
      cards = []
      REXML::XPath.each(xml, "//multistatus/response") do |card|
        if !card.elements["propstat"].elements["prop"].
        elements["resourcetype"].text.to_s.match(/addressbook/)
          cards.push card.elements["href"].text
        end
      end

      # fetch all vcard data in one multiget
      xml = self.report(self.carddav_server, carddav_home, { "Depth" => 1 },
        <<END
        <c:addressbook-multiget xmlns:d="DAV:"
          xmlns:c="urn:ietf:params:xml:ns:carddav">
          <d:prop>
            <c:address-data />
          </d:prop>
          #{cards.map{|h| '<d:href>' << h << '</d:href>'}.join}
        </c:addressbook-multiget>
END
        )

      # map non-empty vcards into Contact objects
      REXML::XPath.each(xml,
        "//multistatus/response/propstat/prop/address-data").
        map{|vc| vc.text }.
        reject{|t| !t }.
        map{|t| Contact.new(self, t) }
    end
  end
end
