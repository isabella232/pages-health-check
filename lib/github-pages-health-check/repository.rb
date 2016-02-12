module GitHubPages
  module HealthCheck
    class Repository < GitHubPages::HealthCheck::Checkable

      attr_reader :name, :owner

      REPO_REGEX = %r{\A[a-z0-9_\-]+/[a-z0-9_\-\.]+\z}i

      def initialize(name_with_owner, access_token: nil)
        unless name_with_owner =~ REPO_REGEX
          raise GitHubPages::HealthCheck::Errors::InvalidRepositoryError
        end
        parts = name_with_owner.split("/")
        @owner = parts.first
        @name  = parts.last
        @access_token = access_token || ENV["OCTOKIT_ACCESS_TOKEN"]
      end

      def name_with_owner
        @name_with_owner ||= [owner,name].join("/")
      end
      alias_method :nwo, :name_with_owner

      def check!
        raise Errors::BuildError, build_error unless built?
        true
      end

      def last_build
        @last_build ||= client.latest_pages_build(name_with_owner)
      end

      def built?
        last_build && last_build.status == "built"
      end

      def build_error
        last_build.error.message unless built?
      end
      alias_method :reason, :build_error

      def build_duration
        last_build.duration unless last_build.nil?
      end

      def last_built
        last_build.updated_at unless last_build.nil?
      end

      def domain
        @domain ||= GitHubPages::HealthCheck::Domain.new(cname)
      end

      private

      def client
        raise MissingAccessTokenError if @acecss_token.nil?
        @client ||= Octokit::Client.new(@access_token)
      end

      def pages_info
        @pages_info ||= client.pages(name_with_owner)
      end

      def cname
        @pages_info.cname
      end
    end
  end
end
