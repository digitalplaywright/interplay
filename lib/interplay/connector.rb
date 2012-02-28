#Fields and methods for a Task stored in Mongo
module Interplay
  module Connector
    extend ActiveSupport::Concern
    
    included do
      
      validates_presence_of :actor_id, :actor_type, :verb

    end
    
    module ClassMethods


      # Defines a new interaction type and registers a definition
      #
      # @param [ String ] name The name of the interaction
      #
      # @example Define a new interaction
      #   interaction(:enquiry) do
      #     actor :user, :cache => [:full_name]
      #     act_object :enquiry, :cache => [:subject]
      #     act_target :listing, :cache => [:title]
      #   end
      #
      # @return [Definition] Returns the registered definition
      def interaction(name, &block)
        definition = Interplay::DefinitionDSL.new(name)
        definition.instance_eval(&block)
        Interplay::Definition.register(definition)
      end


      # Publishes an interaction using an interaction name and data
      #
      # @param [ String ] verb The verb of the interaction
      # @param [ Hash ] data The data to initialize the interaction with.
      #
      # @return [Interplay::Activity] An Activity instance with data
      def interact(verb, data)
        new.interact({:verb => verb}.merge(data))
      end

=begin
      def interactions_for(actor, options={})
        query = {:receivers => {'$elemMatch' => {:id => actor.id, :type => actor.class.to_s}}}
        query.merge!({:verb => options[:type]}) if options[:type]
        self.where(query).desc(:created_at)
      end
=end
      
    end


    module InstanceMethods


      def assign_properties(arguments = {})



        write_attribute(:verb, arguments[:verb])
        arguments.delete(:verb)


        named_defs = [:actor, :act_object, :act_target]


        named_defs.each do |type|
          act_object = arguments[type]

          if act_object == nil
            if definition.send(type.to_sym) != nil
              raise Interplay::InvalidData.new(type)
            else
              next
            end
          end

          class_sym = act_object.class.name.to_sym

          raise Interplay::InvalidData.new(class_sym) unless definition.send(type) == class_sym

          write_attribute(type.to_s+"_id",   act_object.id.to_s)
          write_attribute(type.to_s+"_type", act_object.class.name)

          arguments.delete(type)
        end

        #Look for option definition for everything not defined
        #in named_defs

        def_options = definition.send(:options)
        def_options.each do |cur_option|
          act_object = arguments[cur_option]

          if act_object
            options[cur_option] = act_object
          else
            #all options defined must be used
            raise Interplay::InvalidData.new(act_object[0])
          end
        end



      end

      def reverse_definition
        reverse = definition.send(:reverses)

        if reverse
          @reverse_definition ||= Interplay::Definition.find(reverse)
        else
          @reverse_definition = nil
        end
      end

      #-- if there is a similar instance return it. If this is the reverse of another verb, return that verb.
      def find_similar_instance

        cur_verb = definition.send(:reverses)

        if cur_verb
          raise Interplay::InvalidData.new(cur_verb) unless reverse_definition
        else
          cur_verb = self.verb
        end

        ::Bond.where(verb: cur_verb,
                     actor_id:      self.actor_id,      actor_type:      self.actor_type,
                     act_object_id: self.act_object_id, act_object_type: self.act_object_type,
                     act_target_id: self.act_target_id, act_target_type: self.act_target_type
                     ).first
      end


      def increase_score
        self.increases+=1
        self.score+=1
      end

      def decrease_score
        self.decreases+=1
        self.score+=1
      end

      # Publishes the interaction
      #
      # @param [ Hash ] options The options to interact with.
      #
      def interact(options = {})
        assign_properties(options)
        actor = load_instance(:actor)

        similar_instance = find_similar_instance

        if similar_instance
          return_object = similar_instance
        else
          return_object = self
        end

        #decrease or increase score if this is the reverse action
        if reverse_definition
          return_object.decrease_score

        else
          return_object.increase_score
        end


        return_object.save
        return_object
      end


      def actor
        if actor_id.present?
          load_instance(:actor)
        else
          nil
        end
      end

      def act_object
        if act_object_id.present?
          load_instance(:act_object)
        else
          nil
        end
      end

      def act_target
        if act_target_id.present?
          load_instance(:act_target)
        else
          nil
        end
      end


      # Returns an instance of an actor, act_object or act_target
      #
      # @param [ Symbol ] type The data type (actor, act_object, act_target) to return an instance for.
      #
      # @return [Mongoid::Document] document A mongoid document instance
      def load_instance(type)
        data_type = self.send(type.to_s+'_type')
        data_id   = self.send(type.to_s+'_id')

        if data_id.present?
          data_type.constantize.find(data_id)
        else
          nil
        end
      end
    

      def definition
        @definition ||= Interplay::Definition.find(verb)
      end
      
    end
    
  end
end
