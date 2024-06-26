# frozen_string_literal: true

module RailsLti2Provider
  class Tool < ApplicationRecord
    validates :shared_secret, :uuid, :tool_settings, :lti_version, presence: true
    serialize :tool_settings
    belongs_to :tenant, inverse_of: :tools
    has_many :lti_launches, dependent: :restrict_with_exception
    has_many :registrations, dependent: :restrict_with_exception
    enum status: { disabled: 0, enabled: 1 } # disabled by default for dynamic registration

    def tool_proxy
      IMS::LTI::Models::ToolProxy.from_json(tool_settings)
    end

    def self.find_by_issuer(issuer, options = {})
      return Tool.find_by(uuid: issuer) unless options.any?

      Rails.logger.debug(options.inspect)
      Tool.where(uuid: issuer).find_each do |tool|
        tool_settings = JSON.parse(tool.tool_settings)
        options.each do |key, value|
          return tool if tool_settings[key.to_s] == value
        end
      end
    end

    def settings
      JSON.parse(tool_settings)
    end
  end
end
