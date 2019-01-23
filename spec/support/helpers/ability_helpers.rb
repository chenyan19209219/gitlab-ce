# frozen_string_literal: true

module AbilityHelpers
  def stub_delegation_for_can(subject)
    allow(subject).to receive(:can?) do |user, permission, object|
      Ability.allowed?(user, permission, object)
    end
  end
end
