module CarrierWave
  module Uploader
    class Base
      @@json_with_raw_data = false
      def self.json_with_raw_data=(bool)
        @@json_with_raw_data = bool
      end

      def self.json_with_raw_data
        @@json_with_raw_data
      end

      def serializable_hash(options = nil)
        if @@json_with_raw_data
          if url
            mime = MIME::Types.type_for(file.file)[0].to_s
            md5 = Digest::MD5.file(file.file).to_s
            filename = Pathname.new(file.file).basename.to_s
            base64 = 'data:' + mime + ';base64,' + Base64.strict_encode64(read)
            {url: url, name: filename, data: base64, md5: md5}
          else
            {url: nil, name: nil, data: nil, md5: nil}
          end
        else
          {"url" => url}.merge Hash[versions.map { |name, version| [name, { "url" => version.url }] }]
        end
      end
    end
  end
end
