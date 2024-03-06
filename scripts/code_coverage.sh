#!/bin/bash

# Generate `coverage/lcov.info` file
# flutter test --coverage
# Generate HTML report
# Note: on macOS you need to have lcov installed on your system (`brew install lcov`) to use this:
genhtml coverage/lcov.info -o coverage/html
# Open the report
# open coverage/html/index.html
