module BiblioTech
  class Compression::Gzip < Compression
    register /\.gz\Z/, self
    register /\.gzip\Z/, self

    def default_extension
      'gz'
    end

    def compression_executable
      'gzip'
    end

    def decompression_executable
      'gunzip'
    end
  end
end
