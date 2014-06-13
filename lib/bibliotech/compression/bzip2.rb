module BiblioTech
  class Compression::Bzip2 < Compression
    register /\.bz2\Z/, self
    register /\.bzip2\Z/, self

    def default_extension
      'bz2'
    end

    def compression_executable
      'bzip2'
    end

    def decompression_executable
      'bunzip2'
    end
  end
end
