require 'spec_helper'

module BiblioTech
  describe CommandGenerator do
    let :generator do
      CommandGenerator.new(config)
    end

    let   (:db_name){    "db_name"       }
    let   (:username){   "user_name"     }
    let   (:password){   "password123"   }
    let   (:host){       "127.0.0.1"     }
    let   (:filename){   "export.pg"     }
    let   (:path){       "/some/path"    }
    let   (:base_options){{}}

    let :base_config do
      {
        :adapter => :postgres,
        :database => db_name,
        :username => username
      }
    end

    #
    # these two used in specs where command is a CommandChain containing two
    # commands
    let :first_cmd do command.commands.first end
    let :second_cmd do command.commands[1] end

    describe :export do
      let :command do generator.export(options) end

      subject do command end

      context 'with username and database' do
        let :config  do
          base_config
        end
        let :options do base_options end

        context 'and password' do
          let :config do
            base_config.merge(:password => password)
          end

          it { should be_a(Caliph::CommandLine) }
          it { command.executable.should == 'pg_dump' }
          it { command.options.should == ["-Fc", "-U #{username}", "#{db_name}"] }
          it { command.env['PGPASSWORD'].should == password }
        end

        context 'and hostname' do
          let :config do
            base_config.merge({ :host => host })
          end

          it { command.options.should == ["-Fc", "-h #{host}", "-U #{username}", "#{db_name}"] }
        end

        context 'plus filename and path' do
          let :options do base_options.merge({ :filename => filename, :path => path}) end

          context 'and compressor' do
            let :options do
              base_options.merge(
                :filename => filename,
                :path => path,
                :compressor => :gzip
              )
            end

            it { command.should be_a(Caliph::PipelineChain) }
            it { command.commands[1].redirections.should ==   [ "1>#{path}/#{filename}.gz" ] }

            context "first command" do
              it { first_cmd.executable.should == 'pg_dump' }
              it { first_cmd.options.should ==  ["-Fc", "-U #{username}", "#{db_name}"] }
            end
            context "second command" do
              it { second_cmd.executable.should == 'gzip' }
            end
          end
        end

        context 'with the whole shebang' do
          let :options do base_options.merge({ :filename => filename, :path => path, :compressor => :gzip}) end
          let :config  do base_config.merge({ :host => host, :password => password }) end

          it { second_cmd.redirections.should == ["1>#{path}/#{filename}.gz"] }

          context "first command" do
            it { first_cmd.executable.should == "pg_dump" }
            it { first_cmd.options.should == ["-Fc", "-h #{host}", "-U #{username}", "#{db_name}"] }
            it { first_cmd.env['PGPASSWORD'].should == password }
          end

          context "second command" do
            it { second_cmd.executable.should == 'gzip' }
          end
        end
      end
    end


    describe :import do
      let :command do generator.import(options) end

      subject do command end

      context 'with username, database, file, and path' do
        let :config  do base_config end
        let :options do
          base_options.merge({ :filename => filename, :path => path })
        end


        it { command.redirections.should == ["0<#{path}/#{filename}"] }
        it { command.executable.should == 'pg_restore'}
        it { command.options.should == ["-U #{username}", "-d #{db_name}" ] }

        context "plus password" do
          let :config do base_config.merge({ :password => password }) end

          it { command.options.should == ["-U #{username}", "-d #{db_name}"] }
          it { command.env['PGPASSWORD'].should == password }

          context 'and compressor' do
            let :options do base_options.merge({
              :filename => filename + '.gz',
              :path => path,
              :compressor => :gzip
            })
            end

            it { command.should be_a(Caliph::PipelineChain) }
            it { first_cmd.executable.should == 'gunzip' }
            it { first_cmd.options.should == ["#{path}/#{filename}.gz"] }
          end
        end
      end
    end
  end
end
