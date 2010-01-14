require File.expand_path("../spec_helper", File.dirname(__FILE__))
require 'stumb/servlet'

describe Stumb::Servlet do
  before do
    @server = Stumb::Servlet.base do
      get("/") do
        response.status = 200
        response["Content-Type"] = "text/plain"
        response.body = "Hello World"
      end
    end
  end
  subject{ @server }
  it { should be_instance_of Class }

  describe "GET /" do
    subject do
      @server.new.call( Rack::MockRequest.env_for("/", :method => "GET"))
    end

    it { should == [200, {"Content-Type"=>"text/plain", "Content-Length"=>"11"}, ["Hello World"]] }
  end

  describe "stub(:get, '/dynamic_add')" do
    before do
      @server.stub(:get, '/dynamic_add') do
        response.status = 200
        response["Content-Type"] = "text/plain"
        response.body = "Hi World"
      end
    end

    subject{
      @server.new.call( Rack::MockRequest.env_for("/dynamic_add", :method => "GET"))
    }

    it { should == [200, {"Content-Type"=>"text/plain", "Content-Length"=>"8"}, ["Hi World"]] }
  end

  describe "stub(:get, '/') # override" do
    before do
      @server.stub(:get, '/') do
        response.status = 200
        response["Content-Type"] = "text/plain"
        response.body = "Hi World"
      end
    end

    subject{
      @server.new.call( Rack::MockRequest.env_for("/", :method => "GET"))
    }

    it { should == [200, {"Content-Type"=>"text/plain", "Content-Length"=>"8"}, ["Hi World"]] }
  end

  describe "stub(:get, '/') # re-define after app initialized" do
    before do
      @app = @server.new

      @server.stub(:get, '/') do
        response.status = 200
        response["Content-Type"] = "text/plain"
        response.body = "Hi! World"
      end
    end

    subject{
      @app.call( Rack::MockRequest.env_for("/", :method => "GET"))
    }

    it { should == [200, {"Content-Type"=>"text/plain", "Content-Length"=>"9"}, ["Hi! World"]] }
  end

  describe "mock(:get, '/')" do
    before do
      @server.mock(:get, '/') do
        response.status = 200
        response["Content-Type"] = "text/plain"
        response.body = "Hi World"
      end
    end

    describe "call" do
      before do
        app = @server.new
        @response = app.call( Rack::MockRequest.env_for("/", :method => "GET"))
      end

      subject{ @response }

      it { should == [200, {"Content-Type"=>"text/plain", "Content-Length"=>"8"}, ["Hi World"]] }
      it {
        expect{ @server.verify }.should_not raise_error Stumb::Servlet::Double::Error
      }
    end

    describe "don't call" do
      it { expect{ @server.verify }.should raise_error Stumb::Servlet::Double::Error }
    end
  end
end

