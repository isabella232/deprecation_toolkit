# frozen_string_literal: true

module DeprecationToolkit
  module Warning
    def warn(str)
      if DeprecationToolkit::Configuration.warnings_treated_as_deprecation.any? { |warning| warning =~ str }
        ActiveSupport::Deprecation.warn(str)
      else
        super
      end
    end
  end
end

if defined?(Warning)
  Warning.singleton_class.prepend(DeprecationToolkit::Warning)
end

# https://bugs.ruby-lang.org/issues/12944
if RUBY_VERSION <= '2.5.0' && RUBY_ENGINE == 'ruby'
  module Kernel
    def warn(*messages)
      Array(messages.flatten).each do |str|
        if DeprecationToolkit::Configuration.warnings_treated_as_deprecation.any? { |warning| warning =~ str }
          ActiveSupport::Deprecation.warn(str)
        else
          _original_warn
        end
      end
    end
    alias_method :_original_warn, :warn
  end
end
