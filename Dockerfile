FROM ruby:2.5-alpine

RUN mkdir -p /usr/local/bundle/bin/ip_manager/

WORKDIR /usr/local/bundle/bin/ip_manager

COPY . ./

RUN apk add -U git g++ make; \
    gem build /usr/local/bundle/bin/ip_manager/ip_manager.gemspec; \
    bundle install --quiet; \
    gem install faraday; \
    rake install

ENTRYPOINT ["ruby", "/usr/local/bundle/bin/ip_manager/lib/ip_manager/sbgipmanager.rb"]
