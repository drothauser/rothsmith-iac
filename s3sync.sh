#!/bin/bash
aws s3 sync ~/git/rothsmith-iac s3://rothsmith-iac/ --exclude=".*" --delete