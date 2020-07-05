require 'spec_helper'

module Xcoed
  describe Constants do
    before do
      @helper = Xcoed::Constants
    end

    describe '::common_build_settings' do
      it 'returns the build settings for a bundle' do
        settings = @helper.common_build_settings(:release, :osx, nil, Xcodeproj::Constants::PRODUCT_TYPE_UTI[:bundle])
        expect(settings['COMBINE_HIDPI_IMAGES']).to eq('YES')
      end
    end
  end
end
