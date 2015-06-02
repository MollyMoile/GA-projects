class EventsController < ApplicationController
  before_filter :current_event, only: [:show, :edit, :update, :destroy]
  before_filter :event_host, only: [:show, :edit, :update, :destroy]
  before_filter :check_event_status, only: [:show]
  # before_action :authenticate_user, only: [:new]
  before_filter :set_view_path, only: [:show]
  helper_method :event_host, :current_event

  def index
    @events = ::Query::User::Events.all(current_user)
  end

  def show
    @presenter = ::EventPresenter.new(current_event, current_user)
  end

  def new
    @event = ::EventForm.new(Event.new)
  end

  def edit
    @event = ::EventForm.new(current_event)
  end

  def create
    @event = ::EventForm.new(Event.new)
    if @event.validate(parsed_params.merge(user_id: current_user.id))
      @event.save
      @event.model.invites.create(user_id: current_user.id, rsvp: 'going')
      redirect_to event_path(@event)
    else
      render action: 'new'
    end
  end


  def update
    respond_to do |format|
      if current_event.update(event_params)
        # TODO will need an update email notification here
        if event_params.include?("booked")
          current_user.notifications.create(event: current_event, name: 'notify_guests')
          format.js { head 200 }
        end
        format.html { redirect_to @event}
      else
        format.html { render action: 'edit' }
      end
    end
  end


  def destroy
    # there is no links to destroy atm
    current_event.destroy
    redirect_to events_url
  end

  def campaign_form
    @event = Event.new
  end

  private

  def user_type
    (current_user == event_host) ? "planner" : "guest"
  end

  def set_view_path
    prepend_view_path("#{Rails.root}/app/views/#{user_type}")
  end

  def current_event
    @event ||= Event.find(params[:id])
  end

  def event_host
    current_event.host
  end

  def check_event_status
    current_event.check_status
  end

  def parsed_params
    pp = event_params
    format = "%d %m %Y %H:%M %Z"
    when_date = event_params[:when] + ' ' + event_params[:timezone]
    deadline_date = event_params[:deadline] + ' ' + event_params[:timezone]
    pp[:when] = DateTime.strptime(when_date, format).utc
    pp[:deadline] = DateTime.strptime(deadline_date, format).utc
    pp
  end

  def event_params
    params.require(:event).permit(:when, :what, :description, :deadline, :price, :where, :lat, :lng, :booked, :timezone)
  end
end
