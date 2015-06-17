require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  it '.export' do
    ret = "[{\"id\":1,\"email\":\"test@hoge.com\",\"name\":\"test name\",\"created_at\":#{user.created_at.to_json},\"updated_at\":#{user.updated_at.to_json}}]"
    expect(User.export).to eq ret
  end

  it '#export' do
    ret = "{\"id\":1,\"email\":\"test@hoge.com\",\"name\":\"test name\",\"created_at\":#{user.created_at.to_json},\"updated_at\":#{user.updated_at.to_json}}"
    expect(User.first.export).to eq ret
  end
end
