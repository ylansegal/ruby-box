#encoding: UTF-8

require 'spec_helper'
require 'ruby-box'
require "webmock/rspec"

describe RubyBox::Session do
  before do
    @auth_code = double("OAuth2::Strategy::AuthCode")
    @client = double("OAuth2::Client")

    @client.stub(:auth_code) { @auth_code }
    OAuth2::Client.stub(:new) { @client }

    @session = RubyBox::Session.new({
      client_id: "client id",
      client_secret: "client secret"
    })
  end

  let(:redirect_uri) { "redirect_uri" }
  let(:state) { "state" }

  describe '#authorize_url' do
    it "should accept redirect_uri" do
      @auth_code.should_receive(:authorize_url).with({ redirect_uri: redirect_uri})
      @session.authorize_url(redirect_uri)
    end

    it "should accept redirect_uri and state" do
      @auth_code.should_receive(:authorize_url).with({ redirect_uri: redirect_uri, state: state})
      @session.authorize_url(redirect_uri, state)
    end
  end

  describe "timeout options" do
    let(:read_timeout) { 42 }
    let(:open_timeout) { 42.0 }
    let(:uri) { URI("https://www.google.com/") }
    let(:request) { Net::HTTP::Get.new(uri.request_uri) }

    before do
      stub_request(:get, uri.to_s).to_return(body: "Hello, World!", :status => 200)
    end

    context "when timeout options are set" do
      let(:session) {
        RubyBox::Session.new(client_id: "client id",
                             client_secret: "client secret",
                             read_timeout: read_timeout,
                             open_timeout: open_timeout)
      }

      it "passes them along to Net::HTTP" do
        Net::HTTP.any_instance.should_receive(:read_timeout=).with(read_timeout)
        Net::HTTP.any_instance.should_receive(:open_timeout=).with(open_timeout)
        session.request(uri, request)
      end
    end

    context "when the timeout options are not set" do
      let(:session) {
        RubyBox::Session.new(client_id: "client id",
                             client_secret: "client secret"
                             )
      }

      it "does not passes them along to Net::HTTP, in order to use that library's defaults" do
        Net::HTTP.any_instance.should_not_receive(:read_timeout=).with(read_timeout)
        Net::HTTP.any_instance.should_not_receive(:open_timeout=).with(open_timeout)
        session.request(uri, request)
      end
    end
  end
end
