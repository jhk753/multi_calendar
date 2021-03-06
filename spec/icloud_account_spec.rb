require 'spec_helper'

describe "IcloudAccount" do

  describe "#new" do

    it "should initialize correctly when everything given" do
      icloud_account = MultiCalendar::IcloudAccount.new(
          username: "marck@zuck.com",
          password: "password"
      )
      expect(icloud_account.username).to eq("marck@zuck.com")
      expect(icloud_account.password).to eq("password")
    end

    it "should raise error when client_id not given" do
      expect {
        MultiCalendar::IcloudAccount.new(
            username: "marck@zuck.com"
        )
      }.to raise_error("Missing argument password")
    end

    it "should raise error when client_secret not given" do
      expect {
        MultiCalendar::IcloudAccount.new(
            password: "password"
        )
      }.to raise_error("Missing argument username")
    end
  end

  describe "instance" do

    describe "api calls" do
      before(:each) do
        @icloud_account = MultiCalendar::IcloudAccount.new(
            username: "marck@zuck.com",
            password: "password"
        )

        stub_request(:propfind, "https://marck@zuck.com:password@p01-caldav.icloud.com/").
            with(:body => "<d:propfind xmlns:d=\"DAV:\"><d:prop><d:current-user-principal /></d:prop></d:propfind>").
            to_return(:status => 207, :body => "<?xml version='1.0' encoding='UTF-8'?>\r\n<multistatus xmlns='DAV:'>\r\n  <response>\r\n    <href>/</href>\r\n    <propstat>\r\n      <prop>\r\n        <current-user-principal>\r\n          <href>/207958951/principal/</href>\r\n        </current-user-principal>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n</multistatus>")

        stub_request(:propfind, "https://marck@zuck.com:password@p01-caldav.icloud.com/207958951/calendars/").
            with(:body => "<d:propfind xmlns:d=\"DAV:\"><d:prop><d:displayname/></d:prop></d:propfind>").
            to_return(:status => 207, :body => "<?xml version='1.0' encoding='UTF-8'?>\r\n<multistatus xmlns='DAV:'>\r\n  <response>\r\n    <href>/207958951/calendars/home/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>Personnelle</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>Nicolas Marlier</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/outbox/</href>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/tasks/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>Rappels</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/work/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>Travail</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/notification/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>notification</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/inbox/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname/>\r\n      </prop>\r\n      <status>HTTP/1.1 404 Not Found</status>\r\n    </propstat>\r\n  </response>\r\n</multistatus>")

        stub_request(:report, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/").
            with(:body => "        <C:calendar-query xmlns:D=\"DAV:\"\n                 xmlns:C=\"urn:ietf:params:xml:ns:caldav\">\n     <D:prop>\n       <D:getetag/>\n       <C:calendar-data>\n         <C:comp name=\"VCALENDAR\">\n           <C:prop name=\"VERSION\"/>\n           <C:comp name=\"VEVENT\">\n             <C:prop name=\"SUMMARY\"/>\n             <C:prop name=\"UID\"/>\n             <C:prop name=\"DTSTART\"/>\n             <C:prop name=\"DTEND\"/>\n             <C:prop name=\"DURATION\"/>\n             <C:prop name=\"RRULE\"/>\n             <C:prop name=\"RDATE\"/>\n             <C:prop name=\"EXRULE\"/>\n             <C:prop name=\"EXDATE\"/>\n             <C:prop name=\"RECURRENCE-ID\"/>\n           </C:comp>\n           <C:comp name=\"VTIMEZONE\"/>\n         </C:comp>\n       </C:calendar-data>\n     </D:prop>\n     <C:filter>\n       <C:comp-filter name=\"VCALENDAR\">\n         <C:comp-filter name=\"VEVENT\">\n           <C:time-range start=\"20150101T120000Z\"\n                         end=\"20150130T120000Z\"/>\n         </C:comp-filter>\n       </C:comp-filter>\n     </C:filter>\n   </C:calendar-query>\n",).
            to_return(:status => 207, :body => "<?xml version='1.0' encoding='UTF-8'?>\r\n<multistatus xmlns='DAV:'>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150108T163000-1037563606.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=161@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Hello\r\nUID:20150108T163000-1037563606@iclouddav.com\r\nDTSTART:20150108T163000\r\nDTEND:20150108T183000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150109T090000-7016265254.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=210@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Gouter\r\nUID:20150109T090000-7016265254\r\nDTSTART:20150109T090000\r\nDTEND:20150109T100000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150108T123000-9659696895.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=178@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Hello 24\r\nUID:20150108T123000-9659696895@iclouddav.com\r\nDTSTART:20150108T123000\r\nDTEND:20150108T133000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150108T150000-6600987885.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=184@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Yoyo\r\nUID:20150108T150000-6600987885\r\nDTSTART:20150108T150000\r\nDTEND:20150108T160000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150109T110000-9005638381.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=190@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Midi real\r\nUID:20150109T110000-9005638381\r\nDTSTART:20150109T110000\r\nDTEND:20150109T120000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150110T120000-2943239791.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=188@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Ho\r\nUID:20150110T120000-2943239791\r\nDTSTART:20150110T120000\r\nDTEND:20150110T130000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150110T120000-3141510784.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=189@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Ho\r\nUID:20150110T120000-3141510784\r\nDTSTART:20150110T120000\r\nDTEND:20150110T130000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150114T130321Z-0040192454.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=234@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Yo4\r\nUID:20150114T130321Z-0040192454\r\nDTSTART:20150114T130449Z\r\nDTEND:20150114T170449Z\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150112T150000-5758768501.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=222@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Test de rdv\r\nUID:20150112T150000-5758768501\r\nDTSTART:20150112T150000\r\nDTEND:20150112T160000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150108T090000-0129917367.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=185@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Hahah\r\nUID:20150108T090000-0129917367\r\nDTSTART:20150108T090000\r\nDTEND:20150108T100000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150108T120000-6867438624.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=186@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Hahah\r\nUID:20150108T120000-6867438624\r\nDTSTART:20150108T120000\r\nDTEND:20150108T130000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/20150109T133000-6839699524.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=220@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Soir\xC3\xA9e\r\nUID:20150109T133000-6839699524\r\nDTSTART:20150109T133000\r\nDTEND:20150109T143000\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/home/16284049-11A1-4ABA-B3A3-951BEBDE6BD0.ics</href>\r\n    <propstat>\r\n      <prop>\r\n        <getetag>\"C=44@U=532480dc-160e-4866-b140-63af4221c6a6\"</getetag>\r\n        <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nSUMMARY:Every week\r\nUID:16284049-11A1-4ABA-B3A3-951BEBDE6BD0\r\nDTSTART;VALUE=DATE:20141121\r\nDTEND;VALUE=DATE:20141122\r\nRRULE:FREQ=WEEKLY\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n</multistatus>", :headers => {})

      end

      describe "#list_calendars" do
        it "should list calendars" do
          expect(@icloud_account.list_calendars).to eq([
                                                           {:summary => "Personnelle", :id => "/207958951/calendars/home/", :colorId => 1},
                                                           {:summary => "Travail", :id => "/207958951/calendars/work/", :colorId => 2}
                                                       ])
        end
      end

      describe "#list_events" do
        it "should list events" do
          stub_request(:report, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/").
              with(:body => "        <c:calendar-multiget xmlns:d=\"DAV:\"\n        xmlns:c=\"urn:ietf:params:xml:ns:caldav\">\n          <d:prop>\n            <c:calendar-data />\n          </d:prop>\n          <c:filter>\n            <c:comp-filter name=\"VCALENDAR\" />\n          </c:filter>\n          <d:href>/207958951/calendars/home/20150108T163000-1037563606.ics</d:href><d:href>/207958951/calendars/home/20150109T090000-7016265254.ics</d:href><d:href>/207958951/calendars/home/20150108T123000-9659696895.ics</d:href><d:href>/207958951/calendars/home/20150108T150000-6600987885.ics</d:href><d:href>/207958951/calendars/home/20150109T110000-9005638381.ics</d:href><d:href>/207958951/calendars/home/20150110T120000-2943239791.ics</d:href><d:href>/207958951/calendars/home/20150110T120000-3141510784.ics</d:href><d:href>/207958951/calendars/home/20150114T130321Z-0040192454.ics</d:href><d:href>/207958951/calendars/home/20150112T150000-5758768501.ics</d:href><d:href>/207958951/calendars/home/20150108T090000-0129917367.ics</d:href><d:href>/207958951/calendars/home/20150108T120000-6867438624.ics</d:href><d:href>/207958951/calendars/home/20150109T133000-6839699524.ics</d:href><d:href>/207958951/calendars/home/16284049-11A1-4ABA-B3A3-951BEBDE6BD0.ics</d:href>\n        </c:calendar-multiget>\n").
              to_return(:status => 207, :body => "<?xml version='1.0' encoding='UTF-8'?><multistatus xmlns='DAV:'>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150108T163000-1037563606.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150108T163000-1037563606@iclouddav.com\r\nDTSTART:20150108T163000\r\nDTEND:20150108T183000\r\nSUMMARY:Hello\r\nLOCATION:\r\nDESCRIPTION:\r\nORGANIZER;CN=Orga nizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T162704Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;PARTSTAT=NEEDS-ACTION;ROLE=REQ-PARTICIPANT;SCHEDULE-STATUS=1.1:\r\n mailto:nicolas@wepopp.com\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150109T090000-7016265254.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150109T090000-7016265254\r\nDTSTART:20150109T090000\r\nDTEND:20150109T100000\r\nSUMMARY:Gouter\r\nLOCATION:Ouche\r\nDESCRIPTION:Aahah\r\nORGANIZER;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T173611Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;PARTSTAT=NEEDS-ACTION;ROLE=REQ-PARTICIPANT;SCHEDULE-STATUS=1.1:\r\n mailto:nicolas@wepopp.com\r\nATTENDEE;PARTSTAT=NEEDS-ACTION;ROLE=REQ-PARTICIPANT;SCHEDULE-STATUS=1.1:\r\n mailto:elrandil@gmail.com\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150108T123000-9659696895.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150108T123000-9659696895@iclouddav.com\r\nDTSTART:20150108T123000\r\nDTEND:20150108T133000\r\nSUMMARY:Hello 24\r\nLOCATION:\r\nDESCRIPTION:\r\nORGANIZER;CN=Orga nizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T165804Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150108T150000-6600987885.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150108T150000-6600987885\r\nDTSTART:20150108T150000\r\nDTEND:20150108T160000\r\nSUMMARY:Yoyo\r\nLOCATION:\r\nDESCRIPTION:\r\nORGANIZER;CN=Orga nizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T170903Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150109T110000-9005638381.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150109T110000-9005638381\r\nDTSTART:20150109T110000\r\nDTEND:20150109T120000\r\nSUMMARY:Midi real\r\nLOCATION:Dans le midi\r\nDESCRIPTION:\r\nORGANIZER;CN=Orga nizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T171846Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150110T120000-2943239791.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150110T120000-2943239791\r\nDTSTART:20150110T120000\r\nDTEND:20150110T130000\r\nSUMMARY:Ho\r\nLOCATION:\r\nDESCRIPTION:\r\nORGANIZER;CN=Orga nizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T171521Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150110T120000-3141510784.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150110T120000-3141510784\r\nDTSTART:20150110T120000\r\nDTEND:20150110T130000\r\nSUMMARY:Ho\r\nLOCATION:\r\nDESCRIPTION:\r\nORGANIZER;CN=Orga nizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T171547Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150114T130321Z-0040192454.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150114T130321Z-0040192454\r\nDTSTART:20150114T130449Z\r\nDTEND:20150114T170449Z\r\nSUMMARY:Yo4\r\nLOCATION:Chez toi\r\nDESCRIPTION:Fatos\r\nORGANIZER;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150113T130450Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150112T150000-5758768501.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150112T150000-5758768501\r\nDTSTART:20150112T150000\r\nDTEND:20150112T160000\r\nSUMMARY:Test de rdv\r\nLOCATION:\r\nDESCRIPTION:\r\nORGANIZER;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150112T145228Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150108T090000-0129917367.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150108T090000-0129917367\r\nDTSTART:20150108T090000\r\nDTEND:20150108T100000\r\nSUMMARY:Hahah\r\nLOCATION:\r\nDESCRIPTION:\r\nORGANIZER;CN=Orga nizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T170918Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150108T120000-6867438624.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150108T120000-6867438624\r\nDTSTART:20150108T120000\r\nDTEND:20150108T130000\r\nSUMMARY:Hahah\r\nLOCATION:\r\nDESCRIPTION:\r\nORGANIZER;CN=Orga nizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T170954Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150109T133000-6839699524.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150109T133000-6839699524\r\nDTSTART:20150109T133000\r\nDTEND:20150109T143000\r\nSUMMARY:Soir\xC3\xA9e\r\nLOCATION:Chez moi\r\nDESCRIPTION:\r\nORGANIZER;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T174020Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=DECLINED;SCHEDULE-STATUS=2.0:\r\n mailto:nicolas@wepopp.com\r\nDTSTAMP:20150109T090846Z\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/16284049-11A1-4ABA-B3A3-951BEBDE6BD0.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nUID:16284049-11A1-4ABA-B3A3-951BEBDE6BD0\r\nSUMMARY:Every week\r\nSEQUENCE:0\r\nLOCATION:\r\nDTSTART;VALUE=DATE:20141121\r\nDTEND;VALUE=DATE:20141122\r\nLAST-MODIFIED:20141127T171155Z\r\nRRULE:FREQ=WEEKLY\r\nTRANSP:TRANSPARENT\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n</multistatus>\n", :headers => {})


          expect(@icloud_account.list_events(
                     start_date: DateTime.new(2015, 1, 1, 12, 0),
                     end_date: DateTime.new(2015, 1, 30, 12, 0),
                     calendar_ids: ['/207958951/calendars/']
                 )).to eq([{"id" => "20150108T163000-1037563606@iclouddav.com", "summary" => "Hello", "location" => "", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}, {:displayName => "", :responseStatus => "NEEDS-ACTION", :email => "nicolas@wepopp.com"}], "htmlLink" => "/207958951/calendars/home/20150108T163000-1037563606.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-08T16:30:00+00:00"}, "end" => {"dateTime" => "2015-01-08T18:30:00+00:00"}, "all_day" => false},
                           {"id" => "20150109T090000-7016265254", "summary" => "Gouter", "location" => "Ouche", "description" => "Aahah", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}, {:displayName => "", :responseStatus => "NEEDS-ACTION", :email => "nicolas@wepopp.com"}, {:displayName => "", :responseStatus => "NEEDS-ACTION", :email => "elrandil@gmail.com"}], "htmlLink" => "/207958951/calendars/home/20150109T090000-7016265254.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-09T09:00:00+00:00"}, "end" => {"dateTime" => "2015-01-09T10:00:00+00:00"}, "all_day" => false},
                           {"id" => "20150108T123000-9659696895@iclouddav.com", "summary" => "Hello 24", "location" => "", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}], "htmlLink" => "/207958951/calendars/home/20150108T123000-9659696895.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-08T12:30:00+00:00"}, "end" => {"dateTime" => "2015-01-08T13:30:00+00:00"}, "all_day" => false},
                           {"id" => "20150108T150000-6600987885", "summary" => "Yoyo", "location" => "", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}], "htmlLink" => "/207958951/calendars/home/20150108T150000-6600987885.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-08T15:00:00+00:00"}, "end" => {"dateTime" => "2015-01-08T16:00:00+00:00"}, "all_day" => false},
                           {"id" => "20150109T110000-9005638381", "summary" => "Midi real", "location" => "Dans le midi", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}], "htmlLink" => "/207958951/calendars/home/20150109T110000-9005638381.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-09T11:00:00+00:00"}, "end" => {"dateTime" => "2015-01-09T12:00:00+00:00"}, "all_day" => false},
                           {"id" => "20150110T120000-2943239791", "summary" => "Ho", "location" => "", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}], "htmlLink" => "/207958951/calendars/home/20150110T120000-2943239791.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-10T12:00:00+00:00"}, "end" => {"dateTime" => "2015-01-10T13:00:00+00:00"}, "all_day" => false},
                           {"id" => "20150110T120000-3141510784", "summary" => "Ho", "location" => "", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}], "htmlLink" => "/207958951/calendars/home/20150110T120000-3141510784.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-10T12:00:00+00:00"}, "end" => {"dateTime" => "2015-01-10T13:00:00+00:00"}, "all_day" => false},
                           {"id" => "20150114T130321Z-0040192454", "summary" => "Yo4", "location" => "Chez toi", "description" => "Fatos", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}], "htmlLink" => "/207958951/calendars/home/20150114T130321Z-0040192454.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-14T13:04:49+00:00"}, "end" => {"dateTime" => "2015-01-14T17:04:49+00:00"}, "all_day" => false},
                           {"id" => "20150112T150000-5758768501", "summary" => "Test de rdv", "location" => "", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}], "htmlLink" => "/207958951/calendars/home/20150112T150000-5758768501.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-12T15:00:00+00:00"}, "end" => {"dateTime" => "2015-01-12T16:00:00+00:00"}, "all_day" => false},
                           {"id" => "20150108T090000-0129917367", "summary" => "Hahah", "location" => "", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}], "htmlLink" => "/207958951/calendars/home/20150108T090000-0129917367.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-08T09:00:00+00:00"}, "end" => {"dateTime" => "2015-01-08T10:00:00+00:00"}, "all_day" => false},
                           {"id" => "20150108T120000-6867438624", "summary" => "Hahah", "location" => "", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}], "htmlLink" => "/207958951/calendars/home/20150108T120000-6867438624.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-08T12:00:00+00:00"}, "end" => {"dateTime" => "2015-01-08T13:00:00+00:00"}, "all_day" => false},
                           {"id" => "20150109T133000-6839699524", "summary" => "Soirée", "location" => "Chez moi", "description" => "", "attendees" => [{:displayName => "", :responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true}, {:displayName => "", :responseStatus => "DECLINED", :email => "nicolas@wepopp.com"}], "htmlLink" => "/207958951/calendars/home/20150109T133000-6839699524.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"dateTime" => "2015-01-09T13:30:00+00:00"}, "end" => {"dateTime" => "2015-01-09T14:30:00+00:00"}, "all_day" => false},
                           {"id" => "16284049-11A1-4ABA-B3A3-951BEBDE6BD0", "summary" => "Every week", "location" => "", "description" => "", "attendees" => [], "htmlLink" => "/207958951/calendars/home/16284049-11A1-4ABA-B3A3-951BEBDE6BD0.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"date" => "2015-01-02"}, "end" => {"date" => "2015-01-03"}, "all_day" => true},
                           {"id" => "16284049-11A1-4ABA-B3A3-951BEBDE6BD0", "summary" => "Every week", "location" => "", "description" => "", "attendees" => [], "htmlLink" => "/207958951/calendars/home/16284049-11A1-4ABA-B3A3-951BEBDE6BD0.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"date" => "2015-01-09"}, "end" => {"date" => "2015-01-10"}, "all_day" => true},
                           {"id" => "16284049-11A1-4ABA-B3A3-951BEBDE6BD0", "summary" => "Every week", "location" => "", "description" => "", "attendees" => [], "htmlLink" => "/207958951/calendars/home/16284049-11A1-4ABA-B3A3-951BEBDE6BD0.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"date" => "2015-01-16"}, "end" => {"date" => "2015-01-17"}, "all_day" => true},
                           {"id" => "16284049-11A1-4ABA-B3A3-951BEBDE6BD0", "summary" => "Every week", "location" => "", "description" => "", "attendees" => [], "htmlLink" => "/207958951/calendars/home/16284049-11A1-4ABA-B3A3-951BEBDE6BD0.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"date" => "2015-01-23"}, "end" => {"date" => "2015-01-24"}, "all_day" => true},
                           {"id" => "16284049-11A1-4ABA-B3A3-951BEBDE6BD0", "summary" => "Every week", "location" => "", "description" => "", "attendees" => [], "htmlLink" => "/207958951/calendars/home/16284049-11A1-4ABA-B3A3-951BEBDE6BD0.ics", "calId" => "/207958951/calendars/", "private" => false, "owned" => true, "start" => {"date" => "2015-01-30"}, "end" => {"date" => "2015-01-31"}, "all_day" => true}])
        end
      end

      describe "#get_event" do
        before do

          stub_request(:report, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/").
              with(:body => "        <d:sync-collection xmlns:d=\"DAV:\">\n          <d:sync-token/>\n          <d:prop>\n            <d:getcontenttype/>\n          </d:prop>\n        </d:sync-collection>\n").
              to_return(:status => 200, :body => "", :headers => {})

          stub_request(:report, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/").
              with(:body => "        <c:calendar-multiget xmlns:d=\"DAV:\"\n        xmlns:c=\"urn:ietf:params:xml:ns:caldav\">\n          <d:prop>\n            <c:calendar-data />\n          </d:prop>\n          <c:filter>\n            <c:comp-filter name=\"VCALENDAR\" />\n          </c:filter>\n          <d:href>/207958951/calendars/home/20150109T133000-6839699524.ics</d:href>\n        </c:calendar-multiget>\n").
              to_return(:status => 200, :body => "<?xml version='1.0' encoding='UTF-8'?><multistatus xmlns='DAV:'>\r\n<response xmlns='DAV:'>\r\n  <href>/207958951/calendars/home/20150109T133000-6839699524.ics</href>\r\n  <propstat>\r\n    <prop>\r\n      <calendar-data xmlns='urn:ietf:params:xml:ns:caldav'><![CDATA[BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\r\nBEGIN:VEVENT\r\nUID:20150109T133000-6839699524\r\nDTSTART:20150109T133000\r\nDTEND:20150109T143000\r\nSUMMARY:Soir\xC3\xA9e\r\nLOCATION:Chez moi\r\nDESCRIPTION:\r\nORGANIZER;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;CN=Organizer;EMAIL=nicolas.marlier@wanadoo.fr;\r\n X-CALENDARSERVER-DTSTAMP=20150107T174020Z:\r\n /aMjA3OTU4OTUxMjA3OTU4OWySu79f4dSH4mIePT8HcARqUER4gwjTN-JRC0eyM3Og/princip\r\n al/\r\nATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=DECLINED;SCHEDULE-STATUS=2.0:\r\n mailto:nicolas@wepopp.com\r\nDTSTAMP:20150109T090846Z\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n]]></calendar-data>\r\n    </prop>\r\n    <status>HTTP/1.1 200 OK</status>\r\n  </propstat>\r\n</response>\r\n</multistatus>\n", :headers => {})

          stub_request(:report, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/").
              with(:body => "        <c:calendar-multiget xmlns:d=\"DAV:\"\n        xmlns:c=\"urn:ietf:params:xml:ns:caldav\">\n          <d:prop>\n            <c:calendar-data />\n          </d:prop>\n          <c:filter>\n            <c:comp-filter name=\"VCALENDAR\" />\n          </c:filter>\n          <d:href>/207958951/calendars/home/20150109T133000-1345.ics</d:href>\n        </c:calendar-multiget>\n").
              to_return(:status => 200, :body => "<?xml version='1.0' encoding='UTF-8'?><multistatus xmlns='DAV:'>\r\n</multistatus>\n", :headers => {})

        end
        context "event exists" do
          it "should get event" do
            expect(@icloud_account.get_event(
                       calendar_id: '/207958951/calendars/',
                       event_url: "/207958951/calendars/home/20150109T133000-6839699524.ics"
                   )).to eq({
                                "id" => "20150109T133000-6839699524",
                                "summary" => "Soirée",
                                "location" => "Chez moi",
                                "description" => "",
                                "attendees" => [
                                    {:displayName => "",:responseStatus => "Unknown", :email => "nicolas.marlier@wanadoo.fr", :organizer => true},
                                    {:displayName => "", :responseStatus => "DECLINED", :email => "nicolas@wepopp.com"}
                                ],
                                "htmlLink" => "/207958951/calendars/home/20150109T133000-6839699524.ics",
                                "calId" => "/207958951/calendars/",
                                "start" => {'dateTime' => "2015-01-09T13:30:00+00:00"},
                                "end" => {'dateTime' => "2015-01-09T14:30:00+00:00"},
                                "all_day" => false,
                                "private" => false,
                                "owned" => true,
                            })
          end
        end
        context "event does not exist" do
          it "should raise" do
            expect{@icloud_account.get_event(
                       calendar_id: '/207958951/calendars/',
                       event_url: "/207958951/calendars/home/20150109T133000-1345.ics"
                   )}.to raise_error(MultiCalendar::EventNotFoundException)
          end
        end

      end

      describe "#create_event" do
        it "should create event with attendees" do
          stub_request(:put, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/20150101T120000-.ics/").
              with(:body => "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\nBEGIN:VEVENT\nUID:20150101T120000-\nDTSTART:20150101T120000\nDTEND:20150101T130000\nSUMMARY:New event\nLOCATION:Paris\nDESCRIPTION:created by Multi-Calendar gem\nATTENDEE;PARTSTAT=NEEDS-ACTION;ROLE=REQ-PARTICIPANT;RSVP=TRUE:mailto:you@yourdomain.com\nORGANIZER;CN=Organizer:mailto:marck@zuck.com\nATTENDEE;CN=Organizer:mailto:marck@zuck.com\n\nEND:VEVENT\nEND:VCALENDAR\n").
              to_return(:status => 201, :body => "", :headers => {})

          expect(@icloud_account.create_event(
                     calendar_id: '/207958951/calendars/',
                     start_date: DateTime.new(2015, 1, 1, 12, 0),
                     end_date: DateTime.new(2015, 1, 1, 13, 0),
                     summary: "New event",
                     description: "created by Multi-Calendar gem",
                     attendees: [{email: "you@yourdomain.com"}],
                     location: "Paris"
                 )).to eq({
                                        event_id: "20150101T120000-",
                                        calendar_id: '/207958951/calendars/',
                                        event_url: '/207958951/calendars/20150101T120000-.ics/'
                                    })
        end

        it "should create event without attendees" do
          stub_request(:put, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/20150101T120000-.ics/").
              with(:body => "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\nBEGIN:VEVENT\nUID:20150101T120000-\nDTSTART:20150101T120000\nDTEND:20150101T130000\nSUMMARY:New event\nLOCATION:Paris\nDESCRIPTION:created by Multi-Calendar gem\n\nEND:VEVENT\nEND:VCALENDAR\n").
              to_return(:status => 201, :body => "", :headers => {})

          expect(@icloud_account.create_event(
                     calendar_id: '/207958951/calendars/',
                     start_date: DateTime.new(2015, 1, 1, 12, 0),
                     end_date: DateTime.new(2015, 1, 1, 13, 0),
                     summary: "New event",
                     description: "created by Multi-Calendar gem",
                     attendees: [],
                     location: "Paris"
                 )).to eq({
                                        event_id: "20150101T120000-",
                                        calendar_id: '/207958951/calendars/',
                                        event_url: '/207958951/calendars/20150101T120000-.ics/'
                                    })
        end

        it "should create event with correct timezone" do
          stub_request(:put, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/20150101T120000-.ics/").
              with(:body => "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\nBEGIN:VTIMEZONE\nTZID:Europe/Paris\nX-LIC-LOCATION:Europe/Paris\nBEGIN:DAYLIGHT\nTZOFFSETFROM:+0100\nTZOFFSETTO:+0200\nTZNAME:CEST\nDTSTART:19700329T020000\nRRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU\nEND:DAYLIGHT\nBEGIN:STANDARD\nTZOFFSETFROM:+0200\nTZOFFSETTO:+0100\nTZNAME:CET\nDTSTART:19701025T030000\nRRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU\nEND:STANDARD\nEND:VTIMEZONE\n\nBEGIN:VEVENT\nUID:20150101T120000-\nDTSTART;TZID=Europe/Paris:20150101T120000\nDTEND;TZID=Europe/Paris:20150101T130000\nSUMMARY:New event\nLOCATION:Paris\nDESCRIPTION:created by Multi-Calendar gem\n\nEND:VEVENT\nEND:VCALENDAR\n").
              to_return(:status => 201, :body => "", :headers => {})

          expect(@icloud_account.create_event(
                     calendar_id: '/207958951/calendars/',
                     start_date: DateTime.new(2015, 1, 1, 12, 0),
                     end_date: DateTime.new(2015, 1, 1, 13, 0),
                     start_timezone: "Europe/Paris",
                     end_timezone: "Europe/Paris",
                     summary: "New event",
                     description: "created by Multi-Calendar gem",
                     attendees: [],
                     location: "Paris"
                 )).to eq({
                              event_id: "20150101T120000-",
                              calendar_id: '/207958951/calendars/',
                              event_url: '/207958951/calendars/20150101T120000-.ics/'
                          })
        end

        it "should create event all day" do
          stub_request(:put, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/20150101-.ics/").
              with(:body => "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\nBEGIN:VEVENT\nUID:20150101-\nDTSTART:20150101\nDTEND:20150101\nSUMMARY:New event\nLOCATION:Paris\nDESCRIPTION:created by Multi-Calendar gem\n\nEND:VEVENT\nEND:VCALENDAR\n").
              to_return(:status => 201, :body => "", :headers => {})

          expect(@icloud_account.create_event(
                     calendar_id: '/207958951/calendars/',
                     start_date: DateTime.new(2015, 1, 1),
                     end_date: DateTime.new(2015, 1, 1),
                     all_day: true,
                     summary: "New event",
                     description: "created by Multi-Calendar gem",
                     attendees: [],
                     location: "Paris"
                 )).to eq({
                                        event_id: "20150101-",
                                        calendar_id: '/207958951/calendars/',
                                        event_url: '/207958951/calendars/20150101-.ics/'
                                    })
        end
      end

      describe "#update_event" do

        it "should update event with attendees" do
          stub_request(:put, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/20150109T090000-7016265254.ics/").
              with(:body => "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\nBEGIN:VEVENT\nUID:20150109T090000-7016265254\nDTSTART:20150101T120000\nDTEND:20150101T130000\nSUMMARY:New event\nLOCATION:Paris\nDESCRIPTION:created by Multi-Calendar gem\nATTENDEE;PARTSTAT=NEEDS-ACTION;ROLE=REQ-PARTICIPANT;RSVP=TRUE:mailto:you@yourdomain.com\nORGANIZER;CN=Organizer:mailto:marck@zuck.com\nATTENDEE;CN=Organizer:mailto:marck@zuck.com\n\nEND:VEVENT\nEND:VCALENDAR\n").
              to_return(:status => 204, :body => "", :headers => {})

          expect(@icloud_account.update_event(
                     event_id: '20150109T090000-7016265254',
                     event_url: '/207958951/calendars/20150109T090000-7016265254.ics/',
                     calendar_id: '/207958951/calendars/',
                     start_date: DateTime.new(2015, 1, 1, 12, 0),
                     end_date: DateTime.new(2015, 1, 1, 13, 0),
                     summary: "New event",
                     description: "created by Multi-Calendar gem",
                     attendees: [{email: "you@yourdomain.com"}],
                     location: "Paris"
                 )).to eq(true)
        end

        it "should update event without attendees" do
          stub_request(:put, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/20150109T090000-7016265254.ics/").
              with(:body => "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\nBEGIN:VEVENT\nUID:20150109T090000-7016265254\nDTSTART:20150101T120000\nDTEND:20150101T130000\nSUMMARY:New event\nLOCATION:Paris\nDESCRIPTION:created by Multi-Calendar gem\n\nEND:VEVENT\nEND:VCALENDAR\n").
              to_return(:status => 204, :body => "", :headers => {})

          expect(@icloud_account.update_event(
                     event_id: '20150109T090000-7016265254',
                     event_url: '/207958951/calendars/20150109T090000-7016265254.ics/',
                     calendar_id: '/207958951/calendars/',
                     start_date: DateTime.new(2015, 1, 1, 12, 0),
                     end_date: DateTime.new(2015, 1, 1, 13, 0),
                     summary: "New event",
                     description: "created by Multi-Calendar gem",
                     attendees: [],
                     location: "Paris"
                 )).to eq(true)
        end

        it "should update event with correct timezone" do
          stub_request(:put, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/20150109T090000-7016265254.ics/").
              with(:body => "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\nBEGIN:VTIMEZONE\nTZID:America/New_York\nX-LIC-LOCATION:America/New_York\nBEGIN:DAYLIGHT\nTZOFFSETFROM:-0500\nTZOFFSETTO:-0400\nTZNAME:EDT\nDTSTART:19700308T020000\nRRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU\nEND:DAYLIGHT\nBEGIN:STANDARD\nTZOFFSETFROM:-0400\nTZOFFSETTO:-0500\nTZNAME:EST\nDTSTART:19701101T020000\nRRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU\nEND:STANDARD\nEND:VTIMEZONE\n\nBEGIN:VTIMEZONE\nTZID:America/Los_Angeles\nX-LIC-LOCATION:America/Los_Angeles\nBEGIN:DAYLIGHT\nTZOFFSETFROM:-0800\nTZOFFSETTO:-0700\nTZNAME:PDT\nDTSTART:19700308T020000\nRRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU\nEND:DAYLIGHT\nBEGIN:STANDARD\nTZOFFSETFROM:-0700\nTZOFFSETTO:-0800\nTZNAME:PST\nDTSTART:19701101T020000\nRRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU\nEND:STANDARD\nEND:VTIMEZONE\n\nBEGIN:VEVENT\nUID:20150109T090000-7016265254\nDTSTART;TZID=America/New_York:20150101T120000\nDTEND;TZID=America/Los_Angeles:20150101T130000\nSUMMARY:New event\nLOCATION:Paris\nDESCRIPTION:created by Multi-Calendar gem\n\nEND:VEVENT\nEND:VCALENDAR\n").
              to_return(:status => 204, :body => "", :headers => {})

          expect(@icloud_account.update_event(
                     event_id: '20150109T090000-7016265254',
                     event_url: '/207958951/calendars/20150109T090000-7016265254.ics/',
                     calendar_id: '/207958951/calendars/',
                     start_date: DateTime.new(2015, 1, 1, 12, 0),
                     end_date: DateTime.new(2015, 1, 1, 13, 0),
                     start_timezone: "America/New_York",
                     end_timezone: "America/Los_Angeles",
                     summary: "New event",
                     description: "created by Multi-Calendar gem",
                     attendees: [],
                     location: "Paris"
                 )).to eq(true)
        end

        it "should update event all day" do
          stub_request(:put, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/20150109T090000-7016265254.ics/").
              with(:body => "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN\nBEGIN:VEVENT\nUID:20150109T090000-7016265254\nDTSTART:20150101\nDTEND:20150101\nSUMMARY:New event\nLOCATION:Paris\nDESCRIPTION:created by Multi-Calendar gem\n\nEND:VEVENT\nEND:VCALENDAR\n").
              to_return(:status => 204, :body => "", :headers => {})

          expect(@icloud_account.update_event(
                     event_id: '20150109T090000-7016265254',
                     event_url: '/207958951/calendars/20150109T090000-7016265254.ics/',
                     calendar_id: '/207958951/calendars/',
                     start_date: DateTime.new(2015, 1, 1),
                     end_date: DateTime.new(2015, 1, 1),
                     all_day: true,
                     summary: "New event",
                     description: "created by Multi-Calendar gem",
                     attendees: [],
                     location: "Paris"
                 )).to eq(true)
        end
      end

      describe "#delete_event" do
        it "should delete event" do
          stub_request(:delete, "https://marck%40zuck.com:password@p01-caldav.icloud.com/207958951/calendars/20150109T090000-7016265254.ics/").
              to_return(:status => 204, :body => "", :headers => {})

          expect(@icloud_account.delete_event(
                     event_id: '20150109T090000-7016265254',
                     event_url: '/207958951/calendars/20150109T090000-7016265254.ics/',
                     calendar_id: '/207958951/calendars/'
                 )).to eq(true)
        end
      end

    end

    describe "#credentials_valid?" do
      context "when credentials valid" do
        before(:each) do
          @icloud_account = MultiCalendar::IcloudAccount.new(
              username: "marck@zuck.com",
              password: "password"
          )
          stub_request(:propfind, "https://marck@zuck.com:password@p01-caldav.icloud.com/").
              with(:body => "<d:propfind xmlns:d=\"DAV:\"><d:prop><d:current-user-principal /></d:prop></d:propfind>").
              to_return(:status => 207, :body => "<?xml version='1.0' encoding='UTF-8'?>\r\n<multistatus xmlns='DAV:'>\r\n  <response>\r\n    <href>/</href>\r\n    <propstat>\r\n      <prop>\r\n        <current-user-principal>\r\n          <href>/207958951/principal/</href>\r\n        </current-user-principal>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n</multistatus>")
        end
        context "no calendars for this user" do
          it "should return true" do
            stub_request(:propfind, "https://marck@zuck.com:password@p01-caldav.icloud.com/207958951/calendars/").
                with(:body => "<d:propfind xmlns:d=\"DAV:\"><d:prop><d:displayname/></d:prop></d:propfind>").
                to_return(:status => 207, :body => "<?xml version='1.0' encoding='UTF-8'?>\r\n<multistatus xmlns='DAV:'>\r\n</multistatus>")

            expect(@icloud_account.credentials_valid?).to eq(false)
          end
        end

        context "calendars for this user" do
          it "should return true" do
            icloud_account = MultiCalendar::IcloudAccount.new(
                username: "marck@zuck.com",
                password: "password"
            )
            stub_request(:propfind, "https://marck@zuck.com:password@p01-caldav.icloud.com/").
                with(:body => "<d:propfind xmlns:d=\"DAV:\"><d:prop><d:current-user-principal /></d:prop></d:propfind>").
                to_return(:status => 207, :body => "<?xml version='1.0' encoding='UTF-8'?>\r\n<multistatus xmlns='DAV:'>\r\n  <response>\r\n    <href>/</href>\r\n    <propstat>\r\n      <prop>\r\n        <current-user-principal>\r\n          <href>/207958951/principal/</href>\r\n        </current-user-principal>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n</multistatus>")

            stub_request(:propfind, "https://marck@zuck.com:password@p01-caldav.icloud.com/207958951/calendars/").
                with(:body => "<d:propfind xmlns:d=\"DAV:\"><d:prop><d:displayname/></d:prop></d:propfind>").
                to_return(:status => 207, :body => "<?xml version='1.0' encoding='UTF-8'?>\r\n<multistatus xmlns='DAV:'>\r\n  <response>\r\n    <href>/207958951/calendars/home/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>Personnelle</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>Nicolas Marlier</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/outbox/</href>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/tasks/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>Rappels</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/work/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>Travail</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/notification/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname>notification</displayname>\r\n      </prop>\r\n      <status>HTTP/1.1 200 OK</status>\r\n    </propstat>\r\n  </response>\r\n  <response>\r\n    <href>/207958951/calendars/inbox/</href>\r\n    <propstat>\r\n      <prop>\r\n        <displayname/>\r\n      </prop>\r\n      <status>HTTP/1.1 404 Not Found</status>\r\n    </propstat>\r\n  </response>\r\n</multistatus>")


            expect(icloud_account.credentials_valid?).to eq(true)
          end
        end

      end

      context "when credentials not valid" do
        before(:each) do
          @icloud_account = MultiCalendar::IcloudAccount.new(
              username: "marck@zuck.com",
              password: "wrong_password"
          )
          stub_request(:propfind, "https://marck@zuck.com:wrong_password@p01-caldav.icloud.com/").
              with(:body => "<d:propfind xmlns:d=\"DAV:\"><d:prop><d:current-user-principal /></d:prop></d:propfind>").
              to_return(:status => 404, :body => "")
        end
        it "should return false" do
          expect(@icloud_account.credentials_valid?).to eq(false)
        end
      end
    end
  end


end