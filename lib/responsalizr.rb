#Copyright (c) 2010, Nathaniel Ritmeyer. All rights reserved.

require 'rubygems'
require 'net/http'
require 'active_support/core_ext/string/inflections'

module Responsalizr
  class Response
    def self.from(url_string = nil, proxy = {:proxy_host => nil, :port => nil})
      raise ArgumentError if url_string.nil?
      Net::HTTP.Proxy(proxy[:proxy_host], proxy[:port]).get_response(URI.parse(url_string))
    end
  end

  Net::HTTPResponse.send :define_method, :code? do |expected_code|
    unless Net::HTTPResponse.const_get("CODE_TO_OBJ").keys.collect{|key| key.to_i}.include?(expected_code)
      raise ArgumentError.new("#{expected_code} not a valid response code")
    end
    self.code.to_i == expected_code
  end

  all_response_classes = []

  ObjectSpace.each_object(Class) do |some_class|
    next unless some_class.ancestors.include?(Net::HTTPResponse) and (some_class != Net::HTTPResponse)
    all_response_classes << some_class
  end

  all_response_classes.each do |response_class|
    underscored_class_name = response_class.name.demodulize.underscore
    question_method_name = underscored_class_name.gsub(/^http_?/, "") + "?"
    Net::HTTPResponse.send :define_method, question_method_name.to_sym do
      kind_of?(response_class)
    end
  end

  all_response_classes = nil
end