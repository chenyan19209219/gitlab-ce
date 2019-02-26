module Gitlab
  class Keys
    attr_accessor :auth_file, :key

    def self.command(whatever)
      "#{File.join(Gitlab.config.gitlab_shell.path)}/bin/gitlab-shell #{whatever}"
    end

    def self.command_key(key_id)
      unless /\A[a-z0-9-]+\z/ =~ key_id
        raise KeyError, "Invalid key_id: #{key_id.inspect}"
      end

      command(key_id)
    end

    def self.whatever_line(command, trailer)
      "command=\"#{command}\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty #{trailer}"
    end

    def self.key_line(key_id, public_key)
      public_key.chomp!

      if public_key.include?("\n")
        raise KeyError, "Invalid public_key: #{public_key.inspect}"
      end

      whatever_line(command_key(key_id), public_key)
    end

    def initialize(key_id, key = nil)
      @key_id = key_id
      @key = key.dup if key
      @auth_file = File.join(ENV['HOME'], '.ssh/authorized_keys')
    end

    def add_key
      lock do
        $logger.info('Adding key', key_id: @key_id, public_key: @key)
        auth_line = self.class.key_line(@key_id, @key)
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

    def batch_add_keys
      lock(300) do # Allow 300 seconds (5 minutes) for batch_add_keys
        open_auth_file('a') do |file|
          stdin.each_line do |input|
            tokens = input.strip.split("\t")
            abort("#{$0}: invalid input #{input.inspect}") unless tokens.count == 2
            key_id, public_key = tokens
            $logger.info('Adding key', key_id: key_id, public_key: public_key)
            file.puts(self.class.key_line(key_id, public_key))
          end
        end
      end
      true
    end

    def stdin
      $stdin
    end

    def rm_key
      lock do
        $logger.info('Removing key', key_id: @key_id)
        open_auth_file('r+') do |f|
          while line = f.gets # rubocop:disable Lint/AssignmentInCondition
            next unless line.start_with?("command=\"#{self.class.command_key(@key_id)}\"")
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
  end
end
