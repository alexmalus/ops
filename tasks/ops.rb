task "default" do
  Rake.application.options.show_task_pattern = //
  Rake.application.display_tasks_and_comments()
end

## Project Initialization

desc I18n.t( "ops.init.desc" )
task "init" do

  name = ENV[ 'name' ]
  fail I18n.t( "ops.init.no_name" ) if name.nil? || name.empty?

  FileUtils.cp_r( File.join( root_dir, "res", "samples", "default" ),
    File.join( pwd, name ) )
end

# Host Configuration

## Load configuration

host_files = [
  File.join( pwd_dir, 'hosts.json' ),
  File.join( pwd_dir, 'tmp', 'hosts.json' ) ]

config_file = File.join( pwd_dir, 'config.json' )

$hosts = {} unless defined? $hosts

if ( File.exists? config_file )

  raw_config = File.read( config_file )

  config = {}

  begin
    json = JSON.parse raw_config
  rescue => e
    exit_failure( "Error: #{ e.message }" )
  end

  $config = json
end

## Load Hosts

host_files.each do | hosts_file |
  if ( File.exists? hosts_file )

    raw_hosts = File.read( hosts_file )

    json = {}

    begin
      json = JSON.parse raw_hosts
    rescue => e
      exit_failure( "Error: #{ e.message }" )
    end

    json.each do | h, i |
      class_name = i[ "Type" ]
      $hosts[ h ] = Host.const_get( class_name ).new( h, i, $config )
    end
  end
end

## Host Tasks

$hosts.each do | i, host |

  namespace host.alias do

    desc I18n.t( "host.ssh", :host => host.alias )
    task "ssh" do
      host.shell!
    end
  end
end
