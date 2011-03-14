module CartoDB
  class CartoError < Exception

    def initialize(uri, method, http_response)
      @uri            = uri
      @method         = method
      @error_messages = ['undefined CartoDB error']
      @status_code    = 400
      @error_messages = [uri] if method == nil && http_response == nil


      if http_response
        @status_code = http_response.code
        @error_messages = custom_error(http_response) || standard_error(@status_code)
      end

    end

    def initialize(error_message)
      @error_messages = [error_message]
    end

    def to_s
      <<-EOF
        #{http_error_message_header}
        #{format_error_messages}
      EOF
      .strip
    end

    def http_error_message_header
      if @method && @uri
        %{There were errors running the #{@method.upcase} request "#{@uri}":}
      end
    end
    private :http_error_message_header

    def custom_error(http_response)
      json = Utils.parse_json(http_response)
      json['errors'] if json
    end

    def standard_error(status_code)
      case status_code
      when 401
        ["401 - Unauthorized request"]
      else
        nil
      end
    end
    private :standard_error

    def format_error_messages
      return '' unless @error_messages
      if @error_messages.count == 1
        @error_messages.first
      else
        @error_messages.map{|e| "- #{e}"}.join("\n")
      end
    end
    private :format_error_messages

  end
end