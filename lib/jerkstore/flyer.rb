
require 'date'

module JerkStore
  # JerkStore::Container implements disk-based directory containing  
  # many JerkStore::Products
  #
  # Example:
  #
  #  flyer = Flyer.new
  #
  class Flyer
    include CommonMethods
    
    @@prefix = 'f'              # Used as the leading character in the filename
    
    attr_accessor :classtype
    attr_accessor :timespan     # hour, day, week, month, year
    attr_accessor :duration     # 1, 12, 48, ...
    attr_accessor :offset       # duration offset. i.e. -1 is last [:timespan]
    attr_accessor :products
    attr_accessor :readonly
    attr_accessor :now
    
    attr_reader :errors
    
    def initialize(args = {})
      
      if !args.empty?
        self.classtype = args[:classtype]
        self.timespan = args[:timespan]
        self.duration = args[:duration]
        self.offset = args[:offset]
      end
      
      self.products = []
      
      @readonly = @offset.is_a? Integer
      
      @now = now_with_offset
    end
    
    def readonly?
      @readonly || false
    end
    
    # Developed for MySQL migration. See SummariesFlyer::add_product
    def add_product(p)
      
      raise "This Flyer is readonly!" if @readonly
      
      @now = now_with_offset
      
      # We compare the datetime the product was created with the current datetime
      # so that if we can use this object in other places (for example when converting from a csv file to JerkStore). It ensures that only products from a given datetime will appear in this flyer.
      tmp_now = p.datesummarized
      val_now = 0
      val_then = 0
      if ("day".eql?(self.timespan))
        val_now = @now.yday
        val_then = tmp_now.yday
      elsif ("week".eql?(self.timespan))
        val_now = @now.cweek
        val_then = tmp_now.cweek
      elsif ("month".eql?(self.timespan))
        val_now = @now.mon
        val_then = tmp_now.mon
      end
      
      #STDERR.puts "Comparing #{val_now} to #{val_then} for #{ self.timespan }"
      
      if (val_now == val_then)
        self.products.unshift(p) 
      else
        nil
      end
      
      p
    end
    
    def path
      @now = now_with_offset
      
      components = [
        @@prefix, 
        self.classtype.gsub(/\W/, ''),
        self.duration.to_s,
        self.timespan.to_s,
        @now.year
      ]
      
      case self.timespan
      when "day"
        components << [@now.mon.to_s, @now.day.to_s]
      when "week"
        components << [@now.cweek.to_s]
      when "month"
        components << [@now.mon.to_s]
      end
      
      
      path = JerkStore.ROOT + "/flyers/" + components.join('-')
      
      #STDERR.puts "#{ @offset.to_s }" + path
      path
    end
    
    def now_with_offset
      tmp_now = DateTime.now
      
      if (self.offset.is_a? Integer)
        case self.timespan
        when "day"
          tmp_now = DateTime.new(tmp_now.year, tmp_now.mon, tmp_now.day)+@offset
        when "week"
          tmp_now = DateTime.new(tmp_now.year, tmp_now.mon, tmp_now.day)+(@offset*7)
        when "month"
          d=tmp_now.day
          # This makes offsets the month, but the day might be incorrect
          tmp_now = DateTime.new(tmp_now.year, tmp_now.mon, d)+(@offset*30)
          # This corrects the day 
          tmp_now = DateTime.new(tmp_now.year, tmp_now.mon, d)
        end
      end
      
      tmp_now
    end
    
    
    def fetch
      STDERR.puts "Opening #{ self.path }"
      
      raise "#{ self.path } is not readable!" unless File.readable?(self.path)
      
      newobj = YAML.load_file( self.path ) 
      
      
      tmp_now = DateTime.now
      
      # We don't want to modify flyers from the past.
      newobj.readonly = @offset.is_a? Integer
      
      newobj
    end
    
    
    def save
      JerkStore.create_dir(File.dirname(self.path))
      
      #raise "Cannot write to #{ self.path }!" unless is_writeable?
      
      JerkStore.write_file(self.path, YAML.dump(self))

      true
    end
    
    
  end

end


