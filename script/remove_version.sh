#!/bin/bash
git tag -d publish_$1
git push --delete origin publish_$1

