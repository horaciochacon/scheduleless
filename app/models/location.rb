class Location < ApplicationRecord
  belongs_to :company
  has_many :popular_times, as: :popular
  has_many :scheduling_periods
  has_many :schedule_rules, as: :ruleable
  has_many :shifts
  has_many :user_locations
  has_many :users, through: :user_locations
  has_many :scheduling_hours

  has_one :preference, as: :preferable

  validates :city, presence: true
  validates :line_1, presence: true
  validates :postalcode, presence: true
  validates :time_zone, presence: true

  accepts_nested_attributes_for :preference

  update_index "site_search#location", :self

  def self.default_for(user)
    locations = user.locations

    locations.find_by(user_locations: { home: true }) || locations.first
  end

  def preference
    super || build_preference(
        company.
          preference.
          attributes.
          slice(
            "break_length",
            "minimum_shift_length",
            "maximum_shift_length",
            "shift_overlap"
          )
      )
  end
end
