#!/usr/bin/ruby
require 'json'
@model_hash = {}

def add_property(parent, format, property_type)
  if !@model_hash[parent]
    @model_hash[parent] = []
  end
  @model_hash[parent].push(format.sub('^', property_type))
end

def generator_model(parent, h)
  if h.is_a? Hash
    h.each do |key,val|
      format = "@property (nonatomic, strong) ^ *#{key};"
      if val.is_a? Hash
        add_property(parent, format, 'NSDictionary')
        generator_model(key, val)
      elsif val.is_a? Array
        add_property(parent, format, 'NSArray')
        if (val.count > 0) && ((val[0].is_a? Hash) || (val[0].is_a? Array))
          generator_model(key, val[0])
        end
      else
        add_property(parent, format, 'NSString')
      end
    end
  elsif h.is_a? Array
    if (val.count > 0) && ((val[0].is_a? Hash) || (val[0].is_a? Array))
      generator_model(key, val[0])
    end
  end
end

def print_model(h = {})
  h.each do |key, val|
    puts "@interface <\##{key}\#> : NSObject"
    val.each do |item|
      puts item
    end
   puts '@end'
  end
end

filename = $*[0]
json = JSON.parse(File.read(filename))
generator_model('root', json)
print_model(@model_hash)
