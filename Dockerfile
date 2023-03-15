ARG ruby_version=3.1.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version


FROM $builder_image AS builder

WORKDIR $APP_HOME
COPY Gemfile* .ruby-version ./
RUN bundle install
COPY package.json yarn.lock ./
RUN yarn set version berry && yarn install --immutable
COPY . .
RUN rails assets:precompile && rm -fr log
RUN bootsnap precompile --gemfile .


FROM $base_image

ENV GOVUK_APP_NAME=collections

WORKDIR $APP_HOME
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder $BOOTSNAP_CACHE_DIR $BOOTSNAP_CACHE_DIR
COPY --from=builder $APP_HOME .

USER app
CMD ["puma"]
