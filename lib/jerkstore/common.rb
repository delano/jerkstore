


module JerkStore
  module CommonMethods

    def has_errors?
      (defined?(@errors) && !@errors.empty?)
    end
    
    def is_readable?
      #STDERR.puts "#{ self.path } is readable #{ File.readable?(self.path) }" 
      File.readable?(self.path)
    end
    
    def is_writeable?
      File.writable?(self.path)
    end
    
    def objtype
      self.class.name.gsub(/\W/, '')
    end
    
    def pu(*args)
      STDERR.puts args.join()
    end
    
    def fetch
      raise "#{ self.path } is not readable!" unless File.readable?(self.path)
      #STDERR.puts "Opening #{ self.path }"
      
      newobj = YAML.load_file( self.path ) 
      ##STDERR.puts  newobj
      return newobj
    end
    
    # NOTE USED
    # From: http://railstips.org/2008/6/13/a-class-instance-variable-update
    #def cattr_inheritable(*args)
    #  @cattr_inheritable_attrs ||= [:cattr_inheritable_attrs]
    #  @cattr_inheritable_attrs += args
    #  args.each do |arg|
    #    eval %(
    #      class << self; attr_accessor :#{arg} end
    #    )
    #  end
    #  @cattr_inheritable_attrs
    #end
    #
    #def inherited(subclass)
    #  #STDERR.puts "New subclass: #{subclass}"
    #
    #  @cattr_inheritable_attrs.each do |inheritable_attribute|
    #    instance_var = "@#{inheritable_attribute}" 
    #    subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
    #  end
    #end
  
    
    
  end
  
end

