class PlansController < ApplicationController
  before_filter :check_event_status, only: [:show]
  # before_action :authenticate_user, only: [:new]
  before_filter :set_view_path, only: [:show]
  before_filter :set_demo_end_date, only: [:demo_open]
  helper_method :current_event

  def index
    @events = ::Query::User::Plans.all(current_user)
  end

  def show
    @plan = ::Presenter::Plan.new(current_event, current_user, view_context)
  end

  def new
    @plan = ::PlanForm.new(Plan.new)
  end

  def edit
    @plan = ::PlanForm.new(current_event)
  end

  def create
    @plan = ::PlanForm.new(Plan.new)
    if @plan.validate(parsed_params.merge(user_id: current_user.id))
      @plan.save
      @plan.model.invites.create(user_id: current_user.id, rsvp: 'going')
      redirect_to event_path(@plan)
    else
      render action: 'new'
    end
  end


  def update
    respond_to do |format|
      if current_event.update(event_params)
        # TODO will need an update email notification here
        if event_params.include?("booked")
          current_user.notifications.create(plan: current_event, name: 'notify_guests')
          format.js { head 200 }
        end
        format.html { redirect_to @plan}
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
    @plan = Plan.new
  end

  def demo_closed
    @plan = ::Presenter::Plan.new(demo_event_closed, demo_user, view_context)
    set_demo_views
  end

  def demo_open
    @plan = ::Presenter::Plan.new(demo_event_open, demo_user, view_context)
    set_demo_views
  end

  private

  def demo_event_closed
    ::Query::Plan::Demo.closed
  end

  def demo_event_open
    ::Query::Plan::Demo.open
  end

  def demo_user
    User.where(demo: true).first
  end

  def user_type
    (current_user == current_event.host) ? "planner" : "guest"
  end

  def set_view_path
    prepend_view_path("#{Rails.root}/app/views/#{user_type}")
  end

  def set_demo_views
    prepend_view_path("#{Rails.root}/app/views/planner")
    render template: 'planner/events/show'
  end

  def set_demo_end_date
    demo_event_open.update(deadline: Time.now + 3.days)
  end

  def current_event
    @current_event ||= Plan.find(params[:id])
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
    params.require(:plan).permit(:when, :what, :description, :deadline, :price, :where, :lat, :lng, :booked, :timezone)
  end
end