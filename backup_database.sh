#!/bin/bash

sudo -u postgres pg_dump -Fc --no-acl --no-owner hf_test > db/backups/hf_test_db_$(date +%Y%m%d)_$(date +%H%M)-`hostname`.backup
sudo -u postgres pg_dump -Fc --no-acl --no-owner hf_development > db/backups/hf_development_db_$(date +%Y%m%d)_$(date +%H%M)-`hostname`.backup
sudo -u postgres pg_dump -Fc --no-acl --no-owner hf_production > db/backups/hf_production_db_$(date +%Y%m%d)_$(date +%H%M)-`hostname`.backup
