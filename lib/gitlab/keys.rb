module Gitlab
  class Keys
    attr_accessor :key_id, :key, :auth_file

    def initialize(key_id: nil, key: nil, auth_file: nil)
      @key_id = key_id
      @key = key
      @auth_file = auth_file || File.join(ENV['HOME'], '.ssh/authorized_keys')
    end

    def add_key
      lock do
        $logger.info('Adding key', key_id: key_id, public_key: key)
        auth_line = key_line(key_id, key)
        open_auth_file('a') { |file| file.puts(auth_line) }
      end

      true
    end

    def list_keys
      $logger.info 'Listing all keys'
      keys = ''
      File.readlines(auth_file).each do |line|
        # key_id & public_key
        # command=".../bin/gitlab-shell key-741" ... ssh-rsa AAAAB3NzaDAxx2E\n
        #                               ^^^^^^^              ^^^^^^^^^^^^^^^
        matches = /^command=\".+?\s+(.+?)\".+?(?:ssh|ecdsa)-.*?\s(.+)\s*.*\n*$/.match(line)
        keys << "#{matches[1]} #{matches[2]}\n" unless matches.nil?
      end
      keys
    end

    def list_key_ids
      $logger.info 'Listing all key IDs'
      open_auth_file('r') do |f|
        f.each_line do |line|
          matchd = line.match(/key-(\d+)/)
          next unless matchd
          puts matchd[1]
        end
      end
    end

    def batch_add_keys(keys)
      lock(300) do # Allow 300 seconds (5 minutes) for batch_add_keys
        open_auth_file('a') do |file|
          keys.each do |key|
            $logger.info('Adding key', key_id: key[:id], public_key: key[:public_key])
            file.puts(key_line(key[:id], key[:public_key]))
          end
        end
      end

      true
    end

    def rm_key
      lock do
        $logger.info('Removing key', key_id: key_id)
        open_auth_file('r+') do |f|
          while line = f.gets # rubocop:disable Lint/AssignmentInCondition
            next unless line.start_with?("command=\"#{command(key_id)}\"")
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

    def key_line(key_id, public_key)
      public_key.chomp!

      if public_key.include?("\n")
        raise KeyError, "Invalid public_key: #{public_key.inspect}"
      end

      %Q(command="#{command(key_id)}",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty #{public_key})
    end

    def command(key_id)
      unless /\A[a-z0-9-]+\z/ =~ key_id
        raise KeyError, "Invalid key_id: #{key_id.inspect}"
      end

      "#{File.join(Gitlab.config.gitlab_shell.path)}/bin/gitlab-shell #{key_id}"
    end
  end
end
