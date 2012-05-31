require "bento_search/engine"
require 'confstruct'

module BentoSearch
  @@registered_engine_confs = {}
  
  # Register a configuration for a BentoSearch search engine. 
  # While some parts of BentoSearch can be used without globally registering
  # a configuration, it is neccesary for features like AJAX load, and
  # convenient in other places. 
  #
  # BentoSearch.register_engine("gbs") do |conf|
  #    conf.engine = "GoogleBooksSearch"
  #    conf.api_key = "my_key"
  # end
  #
  # BentoSearch.get_engine("gbs")
  #    => a BentoSearch::GoogleBooksSearch, configured as specified. 
  #
  # The first parameter identifier, eg "gbs", may be used in some
  # URLs, for AJAX etc. 
  def self.register_engine(id, &block)
    conf = Confstruct::Configuration.new(&block)
    conf.id = id
            
    @@registered_engine_confs[id] = conf    
  end
  
  # Get a configured SearchEngine, using configuration and engine
  # class previously registered for `id` with #register_engine. 
  def self.get_engine(id)
    conf = @@registered_engine_confs[id]
    
    raise ArgumentError.new("No registered engine for identifier '#{id}'") unless conf
    
    # Figure out which SearchEngine class to instantiate
    klass = constantize(conf.engine)
    
    return klass.new( conf )
  end
  
  protected
  
  # Turn a string into a constant/class object, lexical lookup
  # within BentoSearch module. Can use whatever would be legal
  # in ruby, "A", "A::B", "::A::B" (force top-level lookup), etc. 
  def self.constantize(klass_string)        
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ klass_string
      raise NameError, "#{klass_string.inspect} is not a valid constant name!"
    end

    BentoSearch.module_eval(klass_string, __FILE__, __LINE__)
  end
  
  # Mostly just used for testing
  def self.reset_engine_registrations!
    @@registered_engine_confs = {}
  end
  
end
