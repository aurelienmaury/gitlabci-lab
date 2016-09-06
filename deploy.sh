#!/usr/bin/env bash

ansible-playbook ansible/deploy.yml -e@gitlab_farm.vars.yml
