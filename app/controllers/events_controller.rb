require 'net/http'

class EventsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_event, only: %i[ edit update destroy ]

  # GET /events or /events.json
  def index
    @events = Event.all
  end

  # GET /events/new
  def new
    @event = Event.new(start: convert_date(params[:start]), end: convert_date(params[:end]), color: '#404bad')
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to events_url, notice: "Event was successfully created." }
        format.turbo_stream { turbo_notice("Event was successfully created.") }
        format.json { render :edit, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to events_url, notice: "Event was successfully updated." }
        format.turbo_stream { turbo_notice("Event was successfully updated.") }
        format.json { render :edit, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.turbo_stream { turbo_notice("Event was successfully destroyed.") }
      format.json { head :no_content }
    end
  end

  # POST /qr
  def qr
    start = (Time.now.to_f * 1000).to_i
    qr = RQRCode::QRCode.new(params[:text])
    png = qr.as_png
    IO::binwrite("#{Rails.root}/public/qr.png", png)
    url = URI('https://api.imgbb.com/1/upload?key=904f9669f28a4b17ced781bb497d7d5e')
    header = {'Content-Type': 'image/png'}
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = Base64.encode64(IO.binread("#{Rails.root}/public/qr.png"))
    response = http.request(request)
    imgbb_hash = JSON.parse(response.body)
    ret = {:string => qr.to_s, :remote => imgbb_hash[:data][:image][:url], :svg => qr.as_svg( color: "000", shape_rendering: "crispEdges", module_size: 11, standalone: true, use_path: true), text: params[:text], :time =>  (Time.now.to_f * 1000).to_i-start}
    render json: ret
    return
  end


  private
  # Use callbacks to share common setup or constraints between actions.

    def turbo_notice(notice)
      render turbo_stream: turbo_stream.update('popup',
        ApplicationController.render(NoticeComponent.new(notice: notice))
      )
    end

    def convert_date(date)
      I18n.l(date&.to_datetime || Time.zone.now)
    end

    def auth
      Current.account != nil
    end

    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:title, :start, :end, :color, :all_day)
    end
end
