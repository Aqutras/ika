require 'rails_helper'
require 'fileutils'
require 'pry'
require 'pry-byebug'

RSpec.describe User, type: :model do
  let(:user) { create(:user, id: 1) }
  let(:group) { create(:group, id: 1) }
  let(:group_user) { create(:group_user, user_id: 1, group_id: 1) }

  context '.import' do
    let(:export_data) { File.read(File.expand_path('spec/tmp/export_string')) }
    let(:user) { User.find_by(id: 1) }

    context 'no sync' do
      before do
        FileUtils.rm_rf(File.expand_path('spec/dummy/public/uploads'))
        User.import(export_data)
      end
      it 'id has been imported' do
        expect(user.id).to eq 1
      end
      it 'email has been imported' do
        expect(user.email).to eq 'a'
      end
      it 'name has been imported' do
        expect(user.name).to eq 'b'
      end
      it 'image has been imported as CarrierWave' do
        expect(user.image.class.superclass).to eq CarrierWave::Uploader::Base
      end
      it 'image file has been imported' do
        expect(File.exist?(user.image.path)).to eq true
      end
    end

    context 'sync' do
      before do
        create(:user, id: 2)
        FileUtils.rm_rf(File.expand_path('spec/dummy/public/uploads'))
        User.import(export_data, sync: true)
      end
      it 'existed data is deleted' do
        expect(User.exists?(id: 2)).to eq false
      end
      it 'id has been imported' do
        expect(user.id).to eq 1
      end
      it 'email has been imported' do
        expect(user.email).to eq 'a'
      end
      it 'name has been imported' do
        expect(user.name).to eq 'b'
      end
      it 'image has been imported as CarrierWave' do
        expect(user.image.class.superclass).to eq CarrierWave::Uploader::Base
      end
      it 'image file has been imported' do
        expect(File.exist?(user.image.path)).to eq true
      end
    end
  end

  context '.export' do
    it 'get all relation' do
      ret = [
        {
          'id' => 1,
          'email' => 'user@mock.com',
          'name' => 'user name',
          'created_at' => JSON.parse(user.to_json)['created_at'],
          'updated_at' => JSON.parse(user.to_json)['updated_at'],
          'image' => {
            'url' => nil,
            'name' => nil,
            'data' => nil,
            'md5' => nil
          },
          'groups' => [
            {
              'id' => 1,
              'domain_id' => 'domain id',
              'name' => 'group name',
              'created_at' => JSON.parse(group.to_json)['created_at'],
              'updated_at' => JSON.parse(group.to_json)['updated_at']
            }
          ],
          'group_users' => [
            {
              'id' => 1,
              'user_id' => 1,
              'group_id' => 1,
              'created_at' => JSON.parse(group_user.to_json)['created_at'],
              'updated_at' => JSON.parse(group_user.to_json)['updated_at']
            }
          ]
        }
      ]
      export = User.export(include: [:groups, :group_users])
      expect(export).to match_json_expression(ret)
    end

    it 'get only self' do
      ret = [
        {
          'id' => 1,
          'email' => 'user@mock.com',
          'name' => 'user name',
          'created_at' => JSON.parse(user.to_json)['created_at'],
          'updated_at' => JSON.parse(user.to_json)['updated_at'],
          'image' => {
            'url' => nil,
            'name' => nil,
            'data' => nil,
            'md5' => nil
          }
        }
      ]
      expect(User.export).to match_json_expression(ret)
    end

    it 'get selected relation' do
      ret = [
        {
          'id' => 1,
          'email' => 'user@mock.com',
          'name' => 'user name',
          'created_at' => JSON.parse(user.to_json)['created_at'],
          'updated_at' => JSON.parse(user.to_json)['updated_at'],
          'image' => {
            'url' => nil,
            'name' => nil,
            'data' => nil,
            'md5' => nil
          },
          'group_users' => [
            {
              'id' => 1,
              'user_id' => 1,
              'group_id' => 1,
              'created_at' => JSON.parse(group_user.to_json)['created_at'],
              'updated_at' => JSON.parse(group_user.to_json)['updated_at']
            }
          ]
        }
      ]
      expect(User.export(include: :group_users)).to match_json_expression(ret)
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
        'image' => {
          'url' => nil,
          'name' => nil,
          'data' => nil,
          'md5' => nil
        },
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

      export = User.find_by(id: 1).export(include: [:group_users, :groups])
      expect(export).to match_json_expression(ret)
    end

    it 'get only self' do
      ret = {
        'id' => 1,
        'email' => 'user@mock.com',
        'name' => 'user name',
        'created_at' => JSON.parse(user.to_json)['created_at'],
        'updated_at' => JSON.parse(user.to_json)['updated_at'],
        'image' => {
          'url' => nil,
          'name' => nil,
          'data' => nil,
          'md5' => nil
        }
      }
      expect(User.first.export).to match_json_expression(ret)
    end

    it 'get selected relation' do
      ret = {
        'id' => 1,
        'email' => 'user@mock.com',
        'name' => 'user name',
        'created_at' => JSON.parse(user.to_json)['created_at'],
        'updated_at' => JSON.parse(user.to_json)['updated_at'],
        'image' => {
          'url' => nil,
          'name' => nil,
          'data' => nil,
          'md5' => nil
        },
        'group_users' => [
          {
            'id' => 1,
            'user_id' => 1,
            'group_id' => 1,
            'created_at' => JSON.parse(group_user.to_json)['created_at'],
            'updated_at' => JSON.parse(group_user.to_json)['updated_at']
          }
        ]
      }
      export = User.find_by(id: 1).export(include: :group_users)
      expect(export).to match_json_expression(ret)
    end
  end
end
