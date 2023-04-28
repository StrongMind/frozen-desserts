# syntax=docker/dockerfile:1
FROM ruby:3.2.1
WORKDIR /myapp
ADD . /myapp

RUN bundle install

EXPOSE 3000

ENTRYPOINT ["sh", "-c", "rails db:prepare db:migrate db:seed && rails assets:precompile && rails server -b 0.0.0.0"]
