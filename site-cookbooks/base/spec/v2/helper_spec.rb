# require 'spec_helper'
require '/Users/proserie/PycharmProjects/private-chef/base/libraries/v2/helper'

describe Company::V2::Helper do
  describe 'get_secrets' do
    let(:secrets_manager_client) { Aws::SecretsManager::Client.new(stub_responses: true) }
    describe "#get_secrets" do
      before do
        stub_request(:put, "http://169.254.169.254/latest/api/token")
          .with(
            headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent'=>'aws-sdk-ruby3/3.166.0',
              'X-Aws-Ec2-Metadata-Token-Ttl-Seconds'=>'21600'
            })
          .to_return(status: 200, body: "", headers: {})
        stub_request(:get, "http://169.254.169.254/latest/meta-data/iam/security-credentials/")
          .with(
            headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent'=>'aws-sdk-ruby3/3.166.0'
            })
          .to_return(status: 200, body: "", headers: {})
      end
      let(:secret_id) { 'terraform/service/staging' }
      let(:bad_secret_id) { 'terraform/service/stagin' }
      let(:secret_string) { { "AWS_ACCESS_KEY_ID": "ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY": "SECRET_ACCESS_KEY"} }
      context 'when retrieving secrets from AWS Secrets Manager' do
        before do
          secrets_manager_client.stub_responses(:get_secret_value, { secret_string: secret_string })
        end

        it 'returns the secret' do
          helper_double = double('Company::V2::Helper', new: Company::V2::Helper.new(nodes), secrets_manager_client: secrets_manager_client)
          allow(described_class).to receive(:new).and_return(helper_double)
          allow(helper_double).to receive(:get_secrets).and_return(secrets_manager_client.get_secret_value(secret_id: secret_id))
          secret_class = described_class.new(helper_double)
          result = my_class.get_secrets(secret_id)
          expect(result.secret_string).to eq(secret_string)
        end
      end
    end
  end
end