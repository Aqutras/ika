module CarrierWave
  module Base64Uploader
    # https://gist.github.com/hilotter/6a4c356499b55e8eaf9a/
    def base64_conversion(uri_str, filename = 'base64')
      image_data = split_base64(uri_str)
      image_data_string = image_data[:data]
      image_data_binary = Base64.decode64(image_data_string)

      temp_img_file = Tempfile.new(filename)
      temp_img_file.binmode
      temp_img_file << image_data_binary
      temp_img_file.rewind

      img_params = {:filename => "#{filename}", :type => image_data[:type], :tempfile => temp_img_file}
      ActionDispatch::Http::UploadedFile.new(img_params)
    end

    def split_base64(uri_str)
      # uri_str.match(%r{data:(.*?);(.*?),(.*)$})
      a = uri_str.index(/^data:/)
      return nil unless a
      b = uri_str.index(/;/, a + 1)
      return nil unless b
      c = uri_str.index(/,/, b + 1)
      return nil unless c

      type = uri_str[a + 5, b - a - 5]
      {
        type: type,
        encoder: uri_str[b + 1, c - b - 1],
        data: uri_str[c + 1, uri_str.length - c - 1],
        extension: type.split('/')[1]
      }
    end
  end
end
