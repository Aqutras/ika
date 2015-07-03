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
      if uri_str.match(%r{data:(.*?);(.*?),(.*)$})
        uri = Hash.new
        uri[:type] = $1
        uri[:encoder] = $2
        uri[:data] = $3
        uri[:extension] = $1.split('/')[1]
        return uri
      else
        return nil
      end
    end
  end
end
