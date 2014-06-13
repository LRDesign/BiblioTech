module BiblioTech
  class Compression::SevenZip < Compression
    register /\.7z\Z/, self

    def default_extension
      '7z'
    end

    def compression
      '7zip'
    end

    def decompress
      'gunzip'
    end
  end
end
