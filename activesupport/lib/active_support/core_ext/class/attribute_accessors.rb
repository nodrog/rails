require 'active_support/core_ext/array/extract_options'

# Extends the class object with class and instance accessors for class attributes,
# just like the native attr* accessors for instance attributes.
#
#  class Person
#    cattr_accessor :hair_colors
#  end
#
#  Person.hair_colors = [:brown, :black, :blonde, :red]
class Class
  def cattr_reader(*syms)
    options = syms.extract_options!
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        unless defined? @@#{sym}  # unless defined? @@hair_colors
          @@#{sym} = nil          #   @@hair_colors = nil
        end                       # end
                                  #
        def self.#{sym}           # def self.hair_colors
          @@#{sym}                #   @@hair_colors
        end                       # end
      EOS
      unless options[:instance_reader] == false
        class_eval(<<-EOS, __FILE__, __LINE__)
          def #{sym}              # def hair_colors
            @@#{sym}              #   @@hair_colors
          end                     # end
        EOS
      end
    end
  end

  def cattr_writer(*syms)
    options = syms.extract_options!
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        unless defined? @@#{sym}                       # unless defined? @@hair_colors
          @@#{sym} = nil                               #   @@hair_colors = nil
        end                                            # end
                                                       #
        def self.#{sym}=(obj)                          # def self.hair_colors=(obj)
          @@#{sym} = obj                               #   @@hair_colors = obj
        end                                            # end
                                                       #
        #{"                                            #
        def #{sym}=(obj)                               # def hair_colors=(obj)
          @@#{sym} = obj                               #   @@hair_colors = obj
        end                                            # end
        " unless options[:instance_writer] == false }  # # instance writer above is generated unless options[:instance_writer] == false
      EOS
      self.send("#{sym}=", yield) if block_given?
    end
  end

  def cattr_accessor(*syms, &blk)
    cattr_reader(*syms)
    cattr_writer(*syms, &blk)
  end
end
