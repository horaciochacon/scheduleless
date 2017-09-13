require "resque_web"

Rails.application.routes.draw do
  root to: "marketing/welcome#index"

  resources :approvals, only: [:index]

  namespace :blog do
    root to: "welcome#index"
    resources :categories, only: [:show]

    namespace :admin, path: "management" do
      root to: "welcome#show"
      resources :blog_posts, only: [:create, :edit, :index, :new, :update]
    end

    resources :posts, only: [:show]
  end

  namespace :business, path: "company" do
    resources :users,
      only: [:create, :destroy, :edit, :index, :new, :show, :update],
      path: "employees"
  end

  resource :calendar, only: [:show]

  resource :dashboard, only: [:show]

  resources :employee_positions, only: [:destroy]

  get "getting_started", to: "marketing/welcome#getting_started", as: :getting_started
  get "how_it_works", to: "marketing/welcome#how_it_works", as: :how_it_works

  resources :locations, only: [:create, :edit, :index, :new, :show, :update] do
    resources :available_employees, only: [:index]
    resource :calendar, only: [:show]
    resource :new_calendar, only: [:show]
    resource :daily_schedule, only: [:show]
    resource :join, only: [:create, :show]
    resource :print, only: [:show]

    scope module: :locations, as: :locations do
      resources :in_progress_shifts,
        only: [:create, :destroy, :edit, :new, :update],
        path: "pending_shifts"
      resources :shifts, only: [:create, :destroy, :edit, :new, :update]
      resources :scheduling_periods, only: [:create]
      resources :schedule_rules, only: [:create, :destroy, :edit, :index, :update]
    end

    resources :trades, only: [:index]
    resources :user_locations, only: [:create]

    scope module: :locations, as: :locations do
      resources :users, only: [:create, :destroy, :edit, :update, :index, :new], path: "employees"
      resources :scheduling_hours, only: [:create, :edit, :destroy, :index, :new, :update], path: "hours"
    end
  end

  namespace :admin, path: "management" do
    root to: "welcome#index"

    resources :companies, only: [:destroy, :edit, :index, :update] do
      resources :schedule_rules,
        only: [:create, :destroy, :edit, :index, :new, :update]
    end

    resources :impersonations, only: [:new, :create]

    resources :schedule_approvals, only: [:index]
    resources :scheduling_periods, only: [:show, :update] do
      resource :approval, only: [:create]
      resource :schedule_period_regenerator, only: [:create], path: "regenerate"
    end
  end

  namespace :mobile_api do
    resources :firebase_tokens, only: [:create]
    resource :featured_shift, only: [:show]
    resource :future_shifts, only: [:show]
    resources :locations, only: [:index]

    resource :my_trades, only: [:show]

    resources :offers, only: [] do
      resource :offer_accept, only: [:create], path: "accept"
      resource :offer_decline, only: [:create], path: "decline"
    end

    resources :shifts, only: [] do
      resource :cancellation, only: [:create], path: "cancel"
      resource :check_in, only: [:create]
      resource :check_out, only: [:create]

      resources :trades, only: [:create]
    end

    resources :time_off_requests, only: [:index, :create]

    resources :trades, only: [:index] do
      resources :offers, only: [:create, :index]
    end
  end

  resource :my_trades, only: [:show]

  use_doorkeeper # makes /oauth routes

  resources :offers, only: [] do
    resource :offer_accept, only: [:create], path: "accept"
    resource :offer_decline, only: [:create], path: "decline"
  end

  namespace :onboarding do
    resource :company, only: [:edit, :update]
    resource :company_preferences, only: [:create, :new]
    resources :leads, only: [:new, :create], path: "contact"
    resources :locations, only: [:create, :edit, :index, :new, :update] do
      resource :scheduling_hours,
        only: [:show, :update],
        path: "hours"
      resources :users, path: :employees, only: [:create, :destroy, :index, :new]
    end
    resources :positions, only: [:create, :destroy, :new]
    resources :registrations, only: [:create, :new]
    resource :schedule_settings, only: [:edit, :update]
  end

  get "pricing", to: "marketing/welcome#pricing", as: :pricing

  mount ResqueWeb::Engine, at: "/queues", anchor: false, constraints: lambda { |req|
    req.env['warden'].authenticated? and req.env['warden'].user.scheduleless_admin?
  }

  namespace :remote, defaults: { format: :js } do

    resources :in_progress_shifts, only: [] do
      scope module: :in_progress_shifts, as: :in_progress_shifts do
        resource :delete_confirmation, only: [:create, :new], path: "delete"
      end
    end

    resources :locations, only: [] do
      # TODO: ensure routes used in new_calendar/calendar are in the right
      # namespace
      resource :calendar, only: [:show]
      resources :in_progress_shifts, only: [:create, :edit, :new, :update]
      resources :postings, only: [:create, :new]
      resources :scheduling_periods, only: [:show]
    end

    namespace :new_calendar, only: [] do
      resources :shifts, only: [] do
        resource :shift_detail, only: [:show], path: "details"
      end

      resources :locations, only: [] do
        resources :favorite_shifts, only: [:create, :new]
        resources :repeating_shifts, only: [:create, :new]
      end
    end
  end

  namespace :reporting do
    resources :locations, only: [] do
      resource :statistics, only: [:show], path: "stats"
    end
  end

  resources :scheduling_period, only: [] do
    resource :scheduling_period_publisher, only: [:create], path: "publish"
    resource :schedule_period_regenerator, only: [:create], path: "regenerate"
  end

  resource :schedules_management, only: [:create, :show]
  resource :search, only: [:show]

  resource :settings, only: [:show]

  namespace :settings do
    resource :company_preference, only: [:edit, :update]
    resources :credit_cards, only: [:create, :destroy, :edit, :index, :new, :update]

    resources :popular_times, only: [:index]

    resources :popular_date_range_times, only: [:create, :destroy, :edit, :new, :update]
    resources :popular_holiday_times, only: [:create, :destroy, :edit, :new, :update]
    resources :popular_time_range_times, only: [:create, :destroy, :edit, :new, :update]
    resources :popular_weekday_times, only: [:create, :destroy, :edit, :new, :update]

    resources :positions, only: [:create, :destroy, :edit, :index, :new, :update] do
      resource :confirm_delete, only: [:show, :destroy]
    end
    resources :schedule_rules, only: [:create, :destroy, :edit, :index, :update]
    resource :subscription, only: [:edit, :update]
  end

  resources :shifts, only: [:index] do
    resource :cancellation, only: [:create], path: "cancel"
    resource :check_in, only: [:create]
    resource :check_out, only: [:create]
    resources :trades, only: [:create, :new]
  end

  resources :email_captures, only: [:create], path: "sign_up"

  resources :streams, only: [:show], defaults: { format: :ics }

  resources :time_off_requests, only: [:create, :index, :new] do
  end

  namespace :time_off_requests do
    resources :approvals, only: [:index]
  end

  scope module: :time_off_requests, as: :time_off_requests do
    resources :time_off_requests, only: [] do
      resources :approvals, only: [:create]
    end
  end

  resources :trades, only: [:index] do
    resource :trade_accept, only: [:create], path: "accept"
    resources :offers, only: [:create, :index, :new]
  end

  resource :user, only: [:edit, :update]

  devise_for :users, controllers: { invitations: "users/invitations" }
end
