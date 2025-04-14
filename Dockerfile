# Use the official Ruby image from the Docker Hub
FROM ruby:3.3.3

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client redis

# Set an environment variable for the application's root directory
ENV RAILS_ROOT /docker-myapp
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

# Set environment variables for the RAILS environment
ENV RAILS_ENV=development
ENV RACK_ENV=development

# Install Gems
COPY Gemfile Gemfile.lock ./
RUN bundle install
CMD ["bundle", "exec", "rails", "db:migrate"]


RUN bundle exec rails assets:precompile

# Copy the rest of the application code
COPY . .


# Expose port 3000 to the Docker host, so we can access it
EXPOSE 81

# Start the main process
# CMD ["rails", "server", "-b", "0.0.0.0"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

# CMD ["bundle", "exec", "thrust", "./bin/rails", "server"]

