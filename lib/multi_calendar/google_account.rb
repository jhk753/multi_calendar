require 'google/api_client'

module MultiCalendar
  class GoogleAccount

    attr_reader :access_token, :email, :refresh_token, :client_id, :client_secret

    # Usage
    #
    #
    # google_account = MultiCalendar::GoogleAccount.new(
    #  client_id:     "$$CLIENT-ID$$",
    #  client_secret: "$$CLIENT-SECRET$$",
    #  refresh_token: "$$USER-REFRESH-TOKEN$$"
    # )
    #
    # google_account.list_events (
    #  start_date:    DateTime.now,
    #  end_date:      DateTime.now + 60,
    #  calendar_ids:  ["$$CALENDAR-ID-1$$", "$$CALENDAR-ID-2$$"]
    # )
    #
    # google_account.get_event (
    #  calendar_id:   "$$CALENDAR-ID$$",
    #  event_id:      "$$EVENT-ID"
    # )
    #
    # google_account.share_calendar_with (
    #  calendar_id:   "$$CALENDAR-ID$$",
    #  email:         "email@mydomain.com"
    # )


    def initialize params
      raise "Missing argument client_id" unless params[:client_id]
      raise "Missing argument client_secret" unless params[:client_secret]
      raise "Missing argument refresh_token" unless params[:refresh_token]
      @client_id = params[:client_id]
      @client_secret = params[:client_secret]
      @email = params[:email]
      @refresh_token = params[:refresh_token]
    end

    def client
      unless @client
        @client = Google::APIClient.new(
            application_name: 'JulieDesk',
            application_version: '1.0.0'
        )
        @client.authorization.client_id = client_id
        @client.authorization.client_secret = client_secret
        @client.authorization.refresh_token = refresh_token
        @client.authorization.grant_type = 'refresh_token'
        @client.authorization.fetch_access_token!

        @access_token = client.authorization.access_token
      end
      @client
    end

    def service
      unless @service
        @service = client.discovered_api('calendar', 'v3')
      end
      @service
    end

    def refresh_access_token
      client.authorization.grant_type = 'refresh_token'
      #client.authorization.expires_at = self.expires_at.to_i
      client.authorization.fetch_access_token!

      @access_token = client.authorization.access_token
    end

    def list_calendars
      result = client.execute(
          :api_method => service.calendar_list.list,
          :headers => {'Content-Type' => 'application/json'})

      result.data['items'].map {|item|
        {
            id: item['id'],
            summary: item['summary'],
            colorId: item['colorId'],
            timezone: item['time_zone']
        }
      }
    end

    def list_events params
      total_result = []
      time_zone = nil
      params[:calendar_ids].each do |calendar_id|
        result = client.execute(
            :api_method => service.events.list,
            :parameters => {
                calendarId: calendar_id,
                timeMin: params[:start_date].strftime("%Y-%m-%dT%H:%M:%S%Z"),
                timeMax: params[:end_date].strftime("%Y-%m-%dT%H:%M:%S%Z"),
                singleEvents: true
            },
            :headers => {'Content-Type' => 'application/json'})

        time_zone ||= result.data['timeZone']

        if calendar_id == email
          time_zone = result.data['timeZone']
        end
        total_result += result.data['items'].map { |item| item['calId'] = calendar_id; item }
      end

      #{
      #    time_zone: time_zone,
      #    events: total_result
      #}
      total_result
    end

    def get_event params
      result = client.execute(
          :api_method => service.events.get,
          :parameters => {
              calendarId: params[:calendar_id],
              eventId: params[:event_id]
          },
          :headers => {'Content-Type' => 'application/json'})

      {
          id: result.data['id'],
          summary: "#{result.data['summary']}",
          description: "#{result.data['description']}",
          location: "#{result.data['location']}",
          start: result.data['start'],
          end: result.data['end'],
          private: result.data['visibility'] == 'private',
          all_day: result.data['start']['dateTime'].nil?,
          attendees: (result.data['attendees'] || []).map { |att| {email: att['email'], name: att['displayName']} },
      }
    end

    def create_event params
      result = client.execute(
          :api_method => service.events.insert,
          :parameters => {
              calendarId: params[:calendar_id],
              sendNotifications: true,
          },
          :body_object => {
              start: {
                  dateTime: params[:start_date].strftime("%Y-%m-%dT%H:%M:%S%Z")
              },
              end: {
                  dateTime: params[:end_date].strftime("%Y-%m-%dT%H:%M:%S%Z")
              },
              summary: params[:summary],
              location: params[:location],
              visibility: (params[:private])?'private':'default',
              attendees: generate_attendees_array(params[:attendees]),
              description: params[:description]
          },
          :headers => {'Content-Type' => 'application/json'})

      result.data.id
    end

    def update_event params
      result = client.execute(
          :api_method => service.events.update,
          :parameters => {
              calendarId: params[:calendar_id],
              eventId: params[:event_id],
              sendNotifications: true
          },
          :body_object => {
              start: {
                  dateTime: params[:start_date].strftime("%Y-%m-%dT%H:%M:%S%Z")
              },
              end: {
                  dateTime: params[:end_date].strftime("%Y-%m-%dT%H:%M:%S%Z")
              },
              summary: params[:summary],
              location: params[:location],
              visibility: (params[:private])?'private':'default',
              attendees: generate_attendees_array(params[:attendees]),
              description: params[:description]
          },
          :headers => {'Content-Type' => 'application/json'})

      result.data.id
    end

    def delete_event params
      result = client.execute(
          :api_method => service.events.delete,
          :parameters => {
              calendarId: params[:calendar_id],
              eventId: params[:event_id],
              sendNotifications: true
          },
          :headers => {'Content-Type' => 'application/json'})

      result.body == ""
    end


    def share_calendar_with params
      client.execute(
          :api_method => service.acl.insert,
          :parameters => {
              calendarId: params[:calendar_id]
          },
          :body_object => {
              role: "writer",
              scope: {
                  type: "user",
                  value: params[:email]
              }
          },
          :headers => {'Content-Type' => 'application/json'})
    end

    private

    def generate_attendees_array attendees
      result = (attendees || []).map{|att|
        {
            email: att[:email]
        }
      }.select{|att|
        att[:email] != self.email
      }
      if result.length > 0
        result << {
            email: self.email,
            responseStatus: "accepted"
        }
      end

      result
    end
  end
end