module Chronic

  class Scalar < Tag #:nodoc:
    def self.scan(tokens)
      # for each token
      tokens.each_index do |i|
        if t = self.scan_for_scalars(tokens[i], tokens[i + 1]) then tokens[i].tag(t) end
        if t = self.scan_for_days(tokens[i], tokens[i + 1]) then tokens[i].tag(t) end
        if t = self.scan_for_months(tokens[i], tokens[i + 1]) then tokens[i].tag(t) end
        if t = self.scan_for_years(tokens[i], tokens[i + 1]) then tokens[i].tag(t) end
      end
      tokens
    end
  
    def self.scan_for_scalars(token, post_token)
      if token.word =~ /^\d*$/
        unless post_token && %w{am pm morning afternoon evening night}.include?(post_token)
          return Scalar.new(token.word.to_i)
        end
      end
      return nil
    end
    
    def self.scan_for_days(token, post_token)
      if token.word =~ /^\d\d?$/
        toi = token.word.to_i
        unless toi > 31 || toi < 1 || (post_token && %w{am pm morning afternoon evening night}.include?(post_token.word))
          return ScalarDay.new(toi)
        end
      end
      return nil
    end
    
    def self.scan_for_months(token, post_token)
      if token.word =~ /^\d\d?$/
        toi = token.word.to_i
        unless toi > 12 || toi < 1 || (post_token && %w{am pm morning afternoon evening night}.include?(post_token.word))
          return ScalarMonth.new(toi)
        end
      end
      return nil
    end
    
    def self.scan_for_years(token, post_token)
      if token.word =~ /^([1-9]\d)?\d\d?$/
        unless post_token && %w{am pm morning afternoon evening night}.include?(post_token.word)
          # Ruby 1.9.2 accepts 2 digit years so we need to guess
          # Of course, this means there is no way to enter a date
          # that happened before 100.  Probably an OK tradeoff
          # as it didn't work before, either.
          year = token.word.to_i
          if year < 100 
            this_year = Chronic.time_class.now.year      
            suffix = this_year.to_s.slice(-2,2).to_i
            year = this_year + (year - suffix)

            # We could just split 50/50 to decide if the user
            # meant the future, however, a user is more likely 
            # going to use a 2 digit number while looking back 
            # unless in the near future.  Splitting the difference
            # at 80/20, however, this could probably be even 
            # more conservative (90/10 even)
            year -= 100 if (year - this_year).to_i >= 20
          end

          return ScalarYear.new(year)
        end
      end
      return nil
    end
    
    def to_s
      'scalar'
    end
  end
  
  class ScalarDay < Scalar #:nodoc:
    def to_s
      super << '-day-' << @type.to_s
    end
  end
  
  class ScalarMonth < Scalar #:nodoc:
    def to_s
      super << '-month-' << @type.to_s
    end
  end
  
  class ScalarYear < Scalar #:nodoc:
    def to_s
      super << '-year-' << @type.to_s
    end
  end

end
