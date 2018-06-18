FROM alpine:3.5
LABEL maintainer="Black Carrot Ventures, LLC <dev@blackcarrot.be>"
LABEL description="Cryptocurrency Exchange Rate Service"

RUN /bin/echo 'set -o vi' >> /etc/profile
RUN /bin/echo 'gem: --no-document' > /etc/gemrc
RUN apk add --update --no-cache alpine-sdk ruby ruby-dev ruby-io-console ruby-irb ruby-bigdecimal ruby-json libstdc++ tzdata bash ca-certificates

WORKDIR /rate-service

# first copy package manifest & install, to avoid rebuilding layers every code change
COPY Gemfile Gemfile.lock /rate-service/

RUN gem install bundler
RUN bundle config --global silence_root_warning 1
RUN bundle install --path vendor

COPY . /rate-service

EXPOSE 4568

# /usr/bin/bundle exec puma -C config/puma.rb config.ru
CMD ["/usr/bin/bundle", "exec", "puma", "-C", "config/puma.rb", "config.ru"]
