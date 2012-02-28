#An act_object that can create a new task on the queue
#need to include Interplay::TaskAgent
module Interplay
  
  module Interactor
    extend ActiveSupport::Concern

    included do
      cattr_accessor :interaction_store_klass



      #--- create task items using the ungrouped_tasks and grouped_tasks fields
      before_save :create_tasks

      #--- fields use to support generic mapping in the class from
      #--- monitored class fields to task items.
      @grouped_interaction_fields   = nil
      @ungrouped_interaction_fields = nil
      @all_interaction_fields       = nil
      @all_interaction_terms        = nil
      @all_tracked_interaction_terms     = nil
    end

    module ClassMethods
          
      def interaction_store_class(klass)
        self.interaction_store_klass = klass.to_s
      end

    end

    module InstanceMethods
      
      # Publishes the interaction
      #
      # @param [ Hash ] options The options to interact with.
      #
      # @example interact an interaction with a act_object and act_target
      #   current_user.interact_interaction(:enquiry, :act_object => @enquiry, :act_target => @listing)
      #
      def perform_interaction(name, options={})
        interaction = interaction_store_class.interact(name, {:actor => self}.merge(options))
      end

      def interaction_store_class
        @interaction_store_klass ||= interaction_store_klass ? interaction_store_klass.classify.constantize : ::Bond
      end

    end
    
  end
  
end
