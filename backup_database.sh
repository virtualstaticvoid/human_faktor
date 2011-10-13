#!/bin/bash

sudo -u postgres pg_dump -Fc --no-acl --no-owner hf_development > hf_development_$(date +%Y%m%d)_$(date +%H%M).dump
sudo -u postgres pg_dump -Fc --no-acl --no-owner hf_production > hf_production_$(date +%Y%m%d)_$(date +%H%M).dump

