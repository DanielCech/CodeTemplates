#! /bin/bash
swift build
cp -rf .build/x86_64-apple-macosx/debug/codeTemplate Bin
cp -rf .build/x86_64-apple-macosx/debug/codeTemplate /usr/local/bin
