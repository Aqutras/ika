require 'rails_helper'

RSpec.describe Animal, type: :model do
  describe 'ika_export' do
    let(:dog) { Dog.new }
    let(:json) { JSON.parse(dog.ika_export) }

    it 'exported json should have `type`' do
      expect(json['type']).to eq('Dog')
    end
  end

  describe 'ika_export' do
    let(:exported_data) { File.read('spec/tmp/dogs.ika') }
    let(:dog) { Dog.first }

    before { Dog.ika_import exported_data }

    it 'after import dog record should have "Dog" in `type` field' do
      expect(dog.type).to eq('Dog')
    end
  end
end
