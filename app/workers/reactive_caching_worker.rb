# frozen_string_literal: true

class ReactiveCachingWorker
  include ApplicationWorker

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(class_name, id, *args)
    klass = begin
      class_name.constantize
    rescue NameError
      nil
    end
    return unless klass

    obj = if klass.reactive_cache_finder && klass.respond_to?(klass.reactive_cache_finder)
            klass.method(klass.reactive_cache_finder).call(*args)
          else
            klass.find_by(klass.primary_key => id)
          end

    obj.try(:exclusively_update_reactive_cache!, *args) if obj
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
