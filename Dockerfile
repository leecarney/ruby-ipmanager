FROM ruby:2.5-alpine
COPY ip_manager /tmp/build/ip_manager/

WORKDIR /tmp/build/ip_manager

RUN apk add -U g++ make; \
    gem build ip_manager.gemspec; \
    bundle install --quiet; \
    gem install -l ip_manager

ENTRYPOINT ["/usr/local/bundle/bin/ip_manager"]