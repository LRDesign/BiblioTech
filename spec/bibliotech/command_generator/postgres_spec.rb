require 'spec_helper'

module BiblioTech
  describe CommandGenerator::Postgres do
    let :generator do CommandGenerator::Postgres.new end
    let :db_name   do "db_name"         end
    let :username  do "user_name"       end
    let :password  do "password123"     end
    let :host      do "127.0.0.1"       end
    let :filename  do "export.pg"       end
    let :filepath  do "/some/path"      end

    let :base_config do
      { :database => db_name,
        :username => username
      }
    end
    let :base_options do {} end

    describe :export do
      let :command do generator.export(config, options) end
      subject do command end

      context 'with username and database' do
        let :config  do base_config end
        let :options do base_options end

        it { should == "pg_dump -Fc -U #{username} -d #{db_name}" }

        context 'and password' do
          let :config do base_config.merge({ :password => password }) end

          it { should == "PGPASSWORD=#{password} pg_dump -Fc -U #{username} -d #{db_name}" }
        end

        context 'and hostname' do
          let :config do base_config.merge({ :host => host }) end

          it { should == "pg_dump -Fc -h #{host} -U #{username} -d #{db_name}" }
        end

        context 'plus filename and path' do
          let :options do base_options.merge({ :filename => filename, :path => filepath}) end

          it { should == "pg_dump -Fc -U #{username} -d #{db_name} > #{filepath}/#{filename}" }

          context 'and compressor' do
            let :options do base_options.merge({
              :filename => filename,
              :path => filepath,
              :compressor => :gzip
            })
            end

            it { should == "pg_dump -Fc -U #{username} -d #{db_name} | gzip > #{filepath}/#{filename}.gz" }
          end
        end

        context 'with the whole shebang' do
          let :options do base_options.merge({ :filename => filename, :path => filepath, :compresor => :gzip}) end
          let :config  do base_config.merge({ :host => host, :password => password }) end

        end
      end
    end
  end
end
