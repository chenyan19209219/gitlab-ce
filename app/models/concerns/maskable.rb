# frozen_string_literal: true

module Maskable
  extend ActiveSupport::Concern

  # * Single line
  # * No escape characters
  # * No variables
  # * No spaces
  # * Minimal length of 8 characters
  # * Absolutely no fun is allowed
  REGEX = /^\w{8,}$/

  def masked?
    protected && REGEX.match?(value)
  end

  def to_runner_variable
    super.merge(masked: masked?)
  end
end
