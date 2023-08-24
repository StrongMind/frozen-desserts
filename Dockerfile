FROM ruby:3.2.1

RUN apt-get update \
  && apt-get install -y npm \
  && npm install -g yarn \
  && apt-get clean \
  && useradd --create-home ruby \
  && chown ruby:ruby -R /var/app

USER ruby

RUN mkdir -p /var/app
COPY --chown=ruby:ruby . /var/app
WORKDIR /var/app

RUN bundle install

ARG RAILS_ENV="production"
ENV RAILS_ENV="${RAILS_ENV}" \
    USER="ruby"

EXPOSE 3000

CMD ["rails", "s"]