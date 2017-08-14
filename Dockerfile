FROM alpine:3.5

RUN /bin/echo 'set -o vi' >> /etc/profile
RUN /bin/echo 'gem: --no-document' > /etc/gemrc
RUN apk update && apk upgrade
RUN apk add --no-cache alpine-sdk ruby ruby-dev ruby-io-console ruby-irb ruby-bigdecimal ruby-json libstdc++ tzdata bash ca-certificates
RUN rm -fr /var/cache/apk/*

WORKDIR /rate-service

COPY . /rate-service

RUN gem install bundler
RUN bundle config --global silence_root_warning 1
RUN bundle install --path vendor

EXPOSE 4568

# /usr/bin/bundle exec puma -C config/puma.rb config.ru
CMD ["/usr/bin/bundle", "exec", "puma", "-C", "config/puma.rb", "config.ru"]

MAINTAINER BlackCarrot <dev@blackcarrot.be>
LABEL description="Cryptocurrency Exchange Rate Service"
