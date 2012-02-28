#DSL for Interplay
module Interplay
  
  class DefinitionDSL
    
    attr_reader :attributes
    
    def initialize(name)
      @attributes = {
        :name       => name.to_sym,
        :actor      => nil,
        :act_object => nil,
        :act_target => nil,
        :reverses   => nil,
        :options    => nil
      }
    end

    def add_option(option)
      @attributes[:options] ||= []

      @attributes[:options] << option
    end
    
    delegate :[], :to => :@attributes
        
    def self.data_methods(*args)
      args.each do |method|
        define_method method do |*args|

          @attributes[method] = args[0]

        end
      end
    end

    def option(text)
      add_option( text )
    end

    data_methods :actor, :act_object, :act_target, :reverses

  end
  
end