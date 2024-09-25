# frozen_string_literal: true

require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:one)
  end

  test 'should get index' do
    get events_url
    assert_response :success
  end

  test 'should get new' do
    get new_event_url
    assert_response :success
  end

  test 'should create event' do
    assert_difference('Event.count') do
      post events_url,
           params: { event: { all_day: @event.all_day, color: @event.color, end: @event.end, start: @event.start,
                              title: @event.title } }
    end

    assert_redirected_to events_url
  end

  test 'should get edit' do
    get edit_event_url(@event)
    assert_response :success
  end

  test 'should update event' do
    patch event_url(@event),
          params: { event: { all_day: @event.all_day, color: @event.color, end: @event.end, start: @event.start,
                             title: @event.title } }
    assert_redirected_to events_url
  end

  test 'should destroy event' do
    assert_difference('Event.count', -1) do
      delete event_url(@event)
    end
    assert_redirected_to events_url
  end

  test 'should create QR code' do
    txt = { text: 'Who are we?' }
    post '/qr', params: txt
    assert_path_exists 'public/qr.png'
    assert URI.parse(JSON.parse(response.body)[:url].to_s) and URI.parse(JSON.parse(response.body)[:url].to_s).starts_with?('http')
  end

  test "should yield error if out of range for both lat and lon" do
    input = {degrees: 1370.7749}
    post '/dd2dms', params: input
    response = JSON.parse(response.body)
    assert response['error'] == 'Out of range -- 1370.7749'
    assert response.except('error').empty?
  end

  test "Should advise if out of range for lat, but not lon" do
    input = {degrees: 121}
    post '/dd2dms', params: input
    response = JSON.parse(response.body)
    assert response['warning'] == '121 out of range for latitude, longitude assumed'
  end

  test '/dd2dms works on appropriate values' do
    input = {degrees:  37.7749}
    post '/dd2dms', params: input
    response = JSON.parse(response.body)
    assert response["dms"] == "37°46\" 29.64'"
    assert response['degrees'] == 37 and response['minutes'] == 46 and  response['seconds'] == 29.64
  end
  
  test '/new requires valid user' do
    get '/new'
    assert response.code == 401
  end
end
