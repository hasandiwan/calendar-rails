# frozen_string_literal: true

#require 'icalendar'
#require 'open-uri'
module EventsHelper
class Event::IcalendarEvent
  include Rails.application.routes.url_helpers

  def initialize(event:, user: nil)
    @event = {}
    @user = user 
  end

  def call
     cal = Icalendar::Calendar.parse(URI.open(@user[:calendar_id]).read)

     cal.events.each { |e|
       if e.dtstart.after(Date.today) and e.dtend.before(Date.tomorrow) then # event is today
         # TODO make all-day event detection smarter -- https://stackoverflow.com/questions/4330672/all-day-event-icalendar-gem
         @user.events.append(Event.new(title:e.title , start:e.dtstart, end:e.dtend, all_day: false)).save!
       end
     }
  end
end

end

