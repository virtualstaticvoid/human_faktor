#!/bin/bash

sudo -u postgres pg_dump -Fc hf_test > db/backups/hf_test_db_$(date +%Y%m%d)_$(date +%H%M)-`hostname`.backup
sudo -u postgres pg_dump -Fc hf_development > db/backups/hf_development_db_$(date +%Y%m%d)_$(date +%H%M)-`hostname`.backup
sudo -u postgres pg_dump -Fc hf_production > db/backups/hf_production_db_$(date +%Y%m%d)_$(date +%H%M)-`hostname`.backup
sudo -u postgres pg_dump -Fc hf_heroku_live > db/backups/hf_heroku_live_db_$(date +%Y%m%d)_$(date +%H%M)-`hostname`.backup
