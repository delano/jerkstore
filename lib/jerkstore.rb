
$: << File.expand_path(File.dirname(__FILE__))

require 'jerkstore/common'
require 'jerkstore/flyer'
require 'jerkstore/product'

# The JerkStore main module, serving as a namespace for all core JerkStore
# modules and classes.
#
# All modules meant for use in your application are <tt>autoload</tt>ed here,
# so it should be enough just to <tt>require jerkstore.rb</tt> in your code.

=begin
TODO: Extend UPC model to JerkStore
require 'xmlrpc/client'
server = XMLRPC::Client.new2('http://www.upcdatabase.com/rpc')
@resp = server.call('lookupUPC', '099482409463')
puts @resp['description']
puts @resp['upc']
=end

module JerkStore
  @@ROOT = '/tmp/JerkStore'
  @@flyers = {}
  
  # Return the Rack release as a dotted string.
  def self.release
    "0.3"
  end
  
  def JerkStore.ROOT
    @@ROOT
  end
  
  def JerkStore.set_root(path)
    @@ROOT = path
    
    @@ROOT.freeze
  end
  
  def JerkStore.add_flyer(n,flyer)
    
    @@flyers[n] = flyer
    #STDERR.puts pp(flyer)
    
  end
  
  def JerkStore.update_flyers(product, todisk=true)
    
    @@flyers.each do |n,flyer|
      if flyer.readonly?
        STDERR.puts "Slipping #{n}"
        next
      end
      
      flyer.add_product(product)
      flyer.save if todisk
      STDERR.puts "Flyer (#{n}): " << flyer.to_s
    end
    
  end
  
  def JerkStore.save_flyers()
    
    @@flyers.each do |n,flyer|
      flyer.save
      STDERR.puts "Flyer (#{n}): " << flyer.to_s
    end
    
  end
  
  def JerkStore.get_flyers
    @@flyers
  end
  
  def JerkStore.create_dir(dirpath)
    return if File.directory?(dirpath)
    
    STDERR.puts "Creating #{ dirpath }"
    File.makedirs(dirpath, true)
  end
  
  def JerkStore.write_file(path, content = '', flush = true)
    STDERR.puts "Writing to #{ path }..."
    
    open(path, 'w') do |f| 
      f.puts content
      f.flush if flush;
    end
  end
  
    
  autoload :Flyer, "jerkstore/flyer"
  autoload :Product, "jerkstore/product"


end

