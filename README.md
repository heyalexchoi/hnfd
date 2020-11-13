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

# NOTE
Currently developing with XCode 12.2. There is an issue right now where Carthage and XCode 12 do not work together.

Error:
`Building for simulator gives me ‘building for iOS simulator but linked framework alamofire.framework was bui…`

[Carthage Github Issue](https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md)

To workaround, use carthage like so: `carthage.sh bootstrap --platform iOS --cache-builds` (assuming you already took `carthage.sh` script from GH issue, which I did)
