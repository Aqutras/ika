require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group) }
  let(:group_user) { FactoryGirl.create(:group_user) }
  context '.export' do
    it 'get all relation' do
      ret = [
        {
          'id' => 1,
          'email' => 'user@mock.com',
          'name' => 'user name',
          'created_at' => JSON.parse(user.to_json)['created_at'],
          'updated_at' => JSON.parse(user.to_json)['updated_at'],
          'group_users' => [
            {
              'id' => 1,
              'user_id' => 1,
              'group_id' => 1,
              'created_at' => JSON.parse(group_user.to_json)['created_at'],
              'updated_at' => JSON.parse(group_user.to_json)['updated_at']
            }
          ],
          'groups' => [
            {
              'id' => 1,
              'domain_id' => 'domain id',
              'name' => 'group name',
              'created_at' => JSON.parse(group.to_json)['created_at'],
              'updated_at' => JSON.parse(group.to_json)['updated_at']
            }
          ]
        }
      ]
      expect(User.export).to match_json_expression(ret)
    end

    it 'get only self' do
      ret = [
        {
          'id' => 1,
          'email' => 'user@mock.com',
          'name' => 'user name',
          'created_at' => JSON.parse(user.to_json)['created_at'],
          'updated_at' => JSON.parse(user.to_json)['updated_at']
        }
      ]
      expect(User.export(nil)).to match_json_expression(ret)
    end
  end

  context '#export' do
    it 'get all relation' do
      ret = {
        'id' => 1,
        'email' => 'user@mock.com',
        'name' => 'user name',
        'created_at' => JSON.parse(user.to_json)['created_at'],
        'updated_at' => JSON.parse(user.to_json)['updated_at'],
        'group_users' => [
          {
            'id' => 1,
            'user_id' => 1,
            'group_id' => 1,
            'created_at' => JSON.parse(group_user.to_json)['created_at'],
            'updated_at' => JSON.parse(group_user.to_json)['updated_at']
          }
        ],
        'groups' => [
          {
            'id' => 1,
            'domain_id' => 'domain id',
            'name' => 'group name',
            'created_at' => JSON.parse(group.to_json)['created_at'],
            'updated_at' => JSON.parse(group.to_json)['updated_at']
          }
        ]
      }

      expect(User.first.export).to match_json_expression(ret)
    end

    it 'get only self' do
      ret = {
        'id' => 1,
        'email' => 'user@mock.com',
        'name' => 'user name',
        'created_at' => JSON.parse(user.to_json)['created_at'],
        'updated_at' => JSON.parse(user.to_json)['updated_at']
      }
      expect(User.first.export(nil)).to match_json_expression(ret)
    end
  end
end
