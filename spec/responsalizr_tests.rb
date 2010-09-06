#while writing responsalizr, I had a bare bones rails app that
#I used to have the tests run against. This being a very small
#project, I didn't want to spend ages mocking out a web server
#or writing a sinatra app - the following commands are enough
#to get you to where you need to be:
#
#    rails test
#    cd test
#    script/server
#
#Having done that, the tests will run.
#
#I'm going to replace the following with something that doesn't
#break the "don't let your tests touch the wire" antipattern.

require 'rubygems'
$: << "./lib"
require 'responsalizr'

include Responsalizr

describe Response do
  it "should not allow a nil url string" do
    lambda { Response.from() }.should raise_error(ArgumentError)
  end

  it "should respond with a Net::HTTPResponse" do
    Response.from("http://localhost:3000").should be_a_kind_of(Net::HTTPResponse)
  end

  it "should allow the use of a proxy" do
    #beware, this uses a real proxy out on the interwebs somewhere
    Response.from("http://localhost:3000", {:proxy_host => "63.223.106.54", :port => 80}).should be_a_code(200)
  end

  it "should allow pretty testing api" do
    Response.from("http://localhost:3000").should be_ok
    Response.from("http://localhost:3000/dfshjidf").should be_not_found
  end

  it "should allow using testing success by response code" do
    Response.from("http://localhost:3000").should be_a_code(200)
    Response.from("http://localhost:3000/dfshjidf").should be_a_code(404)
  end

  it "should allow using testing failure by response code" do
    Response.from("http://localhost:3000").should_not be_a_code(404)
  end

  it "should allow using testing failure by response code without brackets" do
    Response.from("http://localhost:3000").should_not be_a_code 400
  end

  it "should now allow bad codes" do
    lambda { Response.from("http://localhost:3000").should be_a_code(999) }.should raise_error(ArgumentError)
  end
end