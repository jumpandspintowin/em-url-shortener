require 'em-http-request'

module EventMachine
    module ShortURL
        class TinyURL
            include EventMachine::Deferrable

            # TinyURL API URL
            API_URL = 'http://tinyurl.com/api-create.php'

            
            ##
            # TinyURL has no accounts or users, so while the class accepts an
            # +account+ parameter, it is unused.

            def initialize(account={})
                @deferrable_args = [self]
            end


            ##
            # Shortens the given URL, returning self. The shortened URL is
            # passed to the success callback as the first parameter.

            def shorten(url)
                params = { :query => { :url => url } }
                request = EM::HttpRequest.new(API_URL).post(params)
                request.callback(&method(:on_success))
                request.errback(&method(:on_error))
                self
            end

            private


            ##
            # Callback for HttpRequest object upon success. The response should
            # just be the plaintest link.

            def on_success(http)
                if http.response_header.status != 200
                    fail(http.response_header.http_reason, *@deferrable_args)
                else
                    short_url = http.response
                    succeed(short_url, *@deferrable_args)
                end
            end


            ##
            # Callback for an error from HttpRequest (caused by a server
            # outage of lack of connectivity). Simply forwards the error
            # value and sets the deferrable status to fail.

            def on_error(http)
                error = http.error
                fail(error, *@deferrable_args)
            end
        end
    end
end
