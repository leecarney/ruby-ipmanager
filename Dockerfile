FROM ruby:2.5-alpine

RUN mkdir -p /tmp/build/ip_manager/
COPY / /tmp/build/ip_manager/

RUN mkdir -p /usr/local/bundle/bin/ip_manager/

RUN chmod 777 -R /usr/local/bundle/bin/ip_manager

WORKDIR /usr/local/bundle/bin/ip_manager

COPY . ./

RUN apk add -U git g++ make; \
    gem build /tmp/build/ip_manager/ip_manager.gemspec; \
    bundle install --quiet; \
    gem install faraday; \
    rake install

ENTRYPOINT ["ruby", "/tmp/build/ip_manager/lib/ip_manager/example.rb"]
