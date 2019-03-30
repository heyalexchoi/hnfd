# Hacker News For Dogs

### Setup
- `sh setup.sh`

Uses Swift 4.2. Open in Xcode10.1. Xcode10.2 throws a build error about not being able to import carthage dependencies built in swift 5, even though the rest of the project is in swift 4.

### Documentation / Site
hopefully you already have rbenv and ruby and know how to use bundler.
```
cd docs
jekyll serve
```
push to `origin master` to deploy
