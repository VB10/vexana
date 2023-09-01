#!/bin/bash

git push --delete origin publish_$1
git tag delete publish_$1

