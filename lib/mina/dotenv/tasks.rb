require 'mina/dotenv/utils'
require 'mina/scp'

namespace :dotenv do
  desc 'Copies the local .env file to the server'
  task :push do
    dotenv = Mina::Dotenv::Utils.read_file(fetch(:dotenv_location))
    queue! %(
      echo #{dotenv.shellescape} | sed -e 's/^[ \t]*//' > #{remote_dotenv_path}
    )
    queue! %(rm -f .env.production)
    queue! %(ln -nFs #{remote_dotenv_path} .env.production)
  end

  desc 'Copies the remote .env.production file to the current directory'
  task :pull do
    scp_download(remote_dotenv_path, fetch(:dotenv_location))
    add_to_gitignore_command = %(
      if [[ -z $(grep #{fetch(:dotenv_location)} .gitignore) ]];
        then echo #{fetch(:dotenv_location)} >> .gitignore;
      fi;
    )
    `#{add_to_gitignore_command}`
  end
end

def remote_dotenv_path
  "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/.env.production"
end
