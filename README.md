# TenX

TenX Technical Exercise.

## Requirements

1. MacOS X
2. "XCode 9.2" should be installed

## How to build (debug mode)

$ swift build

Output example for Mac OS X:

### Compile Swift Module 'AppLogic' (6 sources)
### Linking ./.build/x86_64-apple-macosx10.10/debug/TenX

## How to run

$ ./.build/x86_64-apple-macosx10.10/debug/TenX < test_data1.txt

## How to test

$ swift test

## How to generate "xcodeproj" file

$ swift package generate-xcodeproj
