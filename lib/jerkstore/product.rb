require 'digest/sha1'
require 'ftools'

module JerkStore
  # JerkStore::Objects is  implements disk-based directory containing  
  # many JerkStore::Objects
  #
  # Example:
  #
  #  store = JerkStore::Container.new
  #
  class Product
    include CommonMethods
    
    VERSION = '0.1'   # TODO: Store Product and implementing class versions in file
    @@prefix = 'p-'
    
    attr_reader :versions 
    attr_reader :errors
    attr_writer :guid     

    def seed
      raise "Override with the value to use for the guid"
    end
    def shelf
      raise "Override with the value to use for the shelf"
    end
    
    def save
      JerkStore.create_dir(File.dirname(self.path))
      
      #raise "Cannot write to #{ self.path }!" unless is_writeable?
      
      JerkStore.write_file(self.path, YAML.dump(self))

      true
    end
    
    
    
    def path
      
      path = JerkStore.ROOT + '/products/' << objtype 
      
      path << "/#{(has_shelf?) ? self.shelf : default_shelf}" 
      path << "/#{ @@prefix }" << guid
    end
    
    def default_shelf
      guid[0,2]     # Gives us 4096 directories by default
    end
    
    def has_shelf?
      return defined?(self.shelf) != nil && !self.shelf.nil? && !self.shelf.empty?
    end
     
    def guid
      raise "What field do I use to see the guid?" if self.seed.nil?
      @guid = Digest::SHA1.hexdigest(self.seed) if (@guid.nil?)
      @guid
    end
     
    def valid?
      raise "You must define Object#valid?!"
    end
    
end



end
