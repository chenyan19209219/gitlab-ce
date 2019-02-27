module Gitlab
  class Keys
    attr_accessor :auth_file

    def initialize(auth_file = nil)
      @auth_file = auth_file || File.join(ENV['HOME'], '.ssh/authorized_keys')
    end

    def add_key(id, key)
      lock do
        $logger.info('Adding key', id: id, key: key)
        auth_line = key_line(id, key)
        open_auth_file('a') { |file| file.puts(auth_line) }
      end

      true
    end

    def batch_add_keys(keys)
      lock(300) do # Allow 300 seconds (5 minutes) for batch_add_keys
        open_auth_file('a') do |file|
          keys.each do |key|
            public_key = strip(key[:key])
            $logger.info('Adding key', id: key[:id], key: public_key)
            file.puts(key_line(key[:id], public_key))
          end
        end
      end

      true
    end

    def rm_key(id)
      lock do
        $logger.info('Removing key', id: id)
        open_auth_file('r+') do |f|
          while line = f.gets # rubocop:disable Lint/AssignmentInCondition
            next unless line.start_with?("command=\"#{command(id)}\"")
            f.seek(-line.length, IO::SEEK_CUR)
            # Overwrite the line with #'s. Because the 'line' variable contains
            # a terminating '\n', we write line.length - 1 '#' characters.
            f.write('#' * (line.length - 1))
          end
        end
      end
      true
    end

    def clear
      open_auth_file('w') { |file| file.puts '# Managed by gitlab-rails' }
      true
    end

    private

    def lock(timeout = 10)
      File.open(lock_file, "w+") do |f|
        begin
          f.flock File::LOCK_EX
          Timeout.timeout(timeout) { yield }
        ensure
          f.flock File::LOCK_UN
        end
      end
    end

    def lock_file
      @lock_file ||= auth_file + '.lock'
    end

    def open_auth_file(mode)
      open(auth_file, mode, 0o600) do |file|
        file.chmod(0o600)
        yield file
      end
    end

    def key_line(id, key)
      key.chomp!

      if key.include?("\n")
        raise KeyError, "Invalid public_key: #{key.inspect}"
      end

      %Q(command="#{command(id)}",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty #{strip(key)})
    end

    def command(id)
      unless /\A[a-z0-9-]+\z/ =~ id
        raise KeyError, "Invalid ID: #{id.inspect}"
      end

      "#{File.join(Gitlab.config.gitlab_shell.path)}/bin/gitlab-shell #{id}"
    end

    def strip(key)
      key.split(/[ ]+/)[0, 2].join(' ')
    end
  end
end
