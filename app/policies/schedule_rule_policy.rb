class ScheduleRulePolicy < ApplicationPolicy
  def create?
    user.company_admin? && same_company?
  end

  def index?
    user.company_admin? && same_company?
  end
end