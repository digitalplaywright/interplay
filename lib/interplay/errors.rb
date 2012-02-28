#Error messages for Interplay
module Interplay
  
  class InterplayError < StandardError
  end
  
  class InvalidQueueItem < InterplayError
  end
  
  # This error is raised when an act_object isn't defined
  # as an actor, act_object or act_target
  #
  # Example:
  #
  # <tt>InvalidField.new('field_name')</tt>
  class InvalidData < InterplayError
    attr_reader :message

    def initialize message
      @message = "Invalid Data: #{message}"
    end

  end
  
  # This error is raised when trying to store a field that doesn't exist
  #
  # Example:
  #
  # <tt>InvalidField.new('field_name')</tt>
  class InvalidField < InterplayError
    attr_reader :message

    def initialize message
      @message = "Invalid Field: #{message}"
    end

  end
  
  class QueueItemNotSaved < InterplayError
  end
  
  class NoFollowersDefined < InterplayError
  end
  
end
