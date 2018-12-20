module Gitlab
  class SslChecker
    attr_reader :remote_host, :remote_port, :error

    def initialize(host, port)
      @host = host
      @port = port
    end

    def remote
      "#{@host}:#{@port}"
    end

    def check
      tcp_client = TCPSocket.new(@host, @port)
      @ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, ssl_context
      @ssl_client.connect
      @ssl_client.close
      return true
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET,
           Errno::EHOSTUNREACH, SocketError => e
      @error = 'Network Failure: ' + e.message

      false
    rescue OpenSSL::SSL::SSLError => e
      @error = 'SSL Error: ' + e.message
      ssl_print_stores
      false
    end

    def output
      out = "---\nCertificate chain\n"
      @ssl_client.peer_cert_chain.each_with_index do |cert, i|
        out += "#{i}: s: #{cert.subject}\n #{cert.issuer}"
      end

      out += "---\n---Server certificate---\n#{@ssl_client.peer_cert}"
      out += "\n---Chain Certificates---\n"
      out += @ssl_client.peer_cert_chain.map(&:to_s).join("\n")
      out
    end

    private

    def ssl_print_stores
      tcp_client = TCPSocket.new(@host, @port)
      @ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, ssl_context(false)
      @ssl_client.connect

      peers = @ssl_client.peer_cert_chain.map do |cert|
        "Subject: #{cert.subject}\n Issuer: #{cert.issuer}"
      end

      @ssl_client.close

      store = store_entries
      @error += "\nReceived Peer Certificates:\n#{peers.join("\n")}"
      
      if store.empty?
        @error += "\nNo Additional Trusted Certificates"
      else
        @error += "\nStore Certificates:\n#{store.join("\n")}" 
      end
    end

    def store_entries
      Dir.entries(OpenSSL::X509::DEFAULT_CERT_DIR).grep(/.0/).each do |cert|
        raw = File.read("#{OpenSSL::X509::DEFAULT_CERT_DIR}/#{cert}")
        raw.split("-----END CERTIFICATE-----\n").each do |entry|
          certificate = OpenSSL::X509::Certificate.new(
            entry + "-----END CERTIFICATE-----\n"
          )
          certificate.subject.to_s
        end
      end
    end

    def ssl_context(verify = true)
      context = OpenSSL::SSL::SSLContext.new
      if verify
        context.verify_mode = OpenSSL::SSL::VERIFY_PEER
      else
        context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      cert_store = OpenSSL::X509::Store.new
      cert_store.set_default_paths
      context.cert_store = cert_store
      context
    end
  end
end
