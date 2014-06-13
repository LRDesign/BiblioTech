require 'spec_helper'

module BiblioTech
  describe Compression::Bzip2 do

    describe :compress do
      subject :compressor do
        Compression::Bzip2.new.compressor
      end

      it { should be_a(Caliph::CommandLine) }
      it { compressor.executable.should == 'bzip2' }
    end

    describe :decompressor do
      let :file do '/path/to/some_file.bz2' end

      subject :decompressor do
        Compression::Bzip2.new.decompressor(file)
      end

      it { should be_a(Caliph::CommandLine) }
      it { compressor.executable.should == 'bunzip2' }
      it { compressor.options.should    == ['some_file.bz2'] }
    end
  end
end


