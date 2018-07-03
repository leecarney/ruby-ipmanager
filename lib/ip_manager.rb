require "cgi"
require "faraday"
require "json"
require "logger"
require "rbconfig"
require "securerandom"
require "set"
require "socket"
require "uri"
require 'base64'
require 'openssl'

# API operations
require "ip_manager/api_operations/create"
require "ip_manager/api_operations/delete"
require "ip_manager/api_operations/list"
require "ip_manager/api_operations/request"
require "ip_manager/api_operations/save"

# API resource support classes
require "ip_manager/errors"
require "ip_manager/util"
require "ip_manager/ipmanager_client"
require "ip_manager/ipmanager_object"
require "ip_manager/ipmanager_response"
require "ip_manager/list_object"
require "ip_manager/api_resource"

# Named API resources
require "ip_manager/ipaddress"
require "ip_manager/version"
require "ip_manager/account"
require "ip_manager/section"


module IpManager

  DEFAULT_CA_BUNDLE_PATH = File.dirname(__FILE__) + "/ip_manager/data/ca-certificates.crt"

  @ca_bundle_path = DEFAULT_CA_BUNDLE_PATH
  @ca_store = nil
  @verify_ssl_certs = true

  @api_base = nil
  @log_level = nil
  @logger = nil
  @token = nil
  $token = nil

  @max_network_retries = 0
  @max_network_retry_delay = 2
  @initial_network_retry_delay = 0.5

  @open_timeout = 30
  @read_timeout = 80

  @verify_ssl = nil

  class << self
    attr_accessor :api_base, :api_username, :api_password, :open_timeout, :read_timeout, :verify_ssl_certs

    attr_reader :max_network_retry_delay, :initial_network_retry_delay, :token
  end

  def self.ca_bundle_path
    @ca_bundle_path
  end

  def self.ca_bundle_path=(path)
    @ca_bundle_path = path

    # empty this field so a new store is initialized
    @ca_store = nil
  end

  def self.ca_store
    @ca_store ||= begin
      store = OpenSSL::X509::Store.new
      store.add_file(ca_bundle_path)
      store
    end
  end

  def self.auth
    $token = IpManager::Account.authenticate
  end

  LEVEL_DEBUG = Logger::DEBUG
  LEVEL_ERROR = Logger::ERROR
  LEVEL_INFO = Logger::INFO

  def self.log_level
    @log_level
  end

  def self.log_level=(val)
    if !val.nil? && ![LEVEL_DEBUG, LEVEL_ERROR, LEVEL_INFO].include?(val)
      raise ArgumentError, "log_level should only be set to `nil`, `debug` or `info`"
    end
    @log_level = val
  end

  def self.logger
    @logger
  end

  def self.logger=(val)
    @logger = val
  end

  def self.max_network_retries
    @max_network_retries
  end

  def self.max_network_retries=(val)
    @max_network_retries = val.to_i
  end

end

IpManager.log_level = IpManager::LEVEL_DEBUG
