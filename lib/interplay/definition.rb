module Interplay
  
  class Definition
    
    attr_reader :name, :actor, :act_object, :act_target, :options, :reverses, :actor_class_names
    
    # @param dsl [Interplay::DefinitionDSL] A DSL act_object
    def initialize(definition)
      @name       = definition[:name]
      @actor      = definition[:actor]      || nil
      @act_object = definition[:act_object] || nil
      @act_target = definition[:act_target] || nil
      @options    = definition[:options]    || []
      @reverses   = definition[:reverses]   || nil

      @actor_class_names = nil
    end
    
    #
    # Registers a new definition
    #
    # @param definition [Definition] The definition to register
    # @return [Definition] Returns the registered definition
    def self.register(definition)
      return false unless definition.is_a? DefinitionDSL
      definition = new(definition)
      self.registered << definition
      return definition || false
    end
    
    # List of registered definitions
    # @return [Array<Interplay::Definition>]
    def self.registered
      @definitions ||= []
    end
    
    def self.find(name)
      unless definition = registered.find{|definition| definition.name == name.to_sym}
        raise Interplay::InvalidQueueItem, "Could not find a definition for `#{name}`"
      else
        definition
      end
    end

    def self.actor_class_names
      if @actor_class_names == nil
        @actor_class_names = []
        self.registered.each do |reg|
          @actor_class_names <<  reg.actor
        end
      end
      return @actor_class_names
    end



  end
  
end
