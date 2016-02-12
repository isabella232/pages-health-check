require "net/dns"
require "net/dns/resolver"
require "addressable/uri"
require "ipaddr"
require "public_suffix"
require "singleton"
require "net/http"
require "typhoeus"
require "resolv"
require "timeout"
require "octokit"
require "json"
require_relative "github-pages-health-check/version"

if File.exists?(File.expand_path ".env", File.dirname(__FILE__))
  require 'dotenv'
  Dotenv.load
end

module GitHubPages
  module HealthCheck

    autoload :Cloudflare, "github-pages-health-check/cloudflare"
    autoload :Error,      "github-pages-health-check/error"
    autoload :Errors,     "github-pages-health-check/errors"
    autoload :Checkable,  "github-pages-health-check/checkable"
    autoload :Domain,     "github-pages-health-check/domain"
    autoload :Repository, "github-pages-health-check/repository"
    autoload :Site,       "github-pages-health-check/site"

    LEGACY_IP_ADDRESSES = %w[
      207.97.227.245
      204.232.175.78
      199.27.73.133
    ]

    CURRENT_IP_ADDRESSES = %w[
      192.30.252.153
      192.30.252.154
    ]

    # DNS and HTTP timeout, in seconds
    TIMEOUT = 10

    TYPHOEUS_OPTIONS = {
      :followlocation  => true,
      :timeout         => TIMEOUT,
      :accept_encoding => "gzip",
      :method          => :head,
      :headers         => {
        "User-Agent"   => "Mozilla/5.0 (compatible; GitHub Pages Health Check/#{VERSION}; +https://github.com/github/pages-health-check)"
      }
    }

    # surpress warn-level feedback due to unsupported record types
    def self.without_warnings(&block)
      warn_level, $VERBOSE = $VERBOSE, nil
      result = block.call
      $VERBOSE = warn_level
      result
    end
  end
end
