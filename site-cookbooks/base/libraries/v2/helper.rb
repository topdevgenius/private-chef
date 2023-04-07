require 'aws-sdk-secretsmanager'

module Company
  module V2
    class Helper
      def initialize(node, opts = {})
        @node = node
        @secrets_manager_client = Aws::SecretsManager::Client.new(region: 'us-west-2')
      end

      attr_reader :secrets_manager_client

      def get_secrets(path, region = node['ec2']['region'])
        begin
          secrets_manager_client.config.region = region
          yield JSON.parse secrets_manager_client.get_secret_value(secret_id: path)[:secret_string]
        rescue Aws::SecretsManager::Errors::ServiceError => e
          raise Chef::Log::error("secrets Manager has run in to an error.")
        end
      end
    end
  end
end