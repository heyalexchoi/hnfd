brew install carthage
gem install bundler
bundle
bundle exec pod install
carthage bootstrap --platform ios --no-use-binaries

# node to build mercury (article parser) package
# nvm install 10.15.3
# brew install yarn
# yarn add @postlight/mercury-parser
