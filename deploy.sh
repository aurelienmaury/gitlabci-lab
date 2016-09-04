#!/usr/bin/env bash

ansible-playbook ansible/deploy.yml -e@service_zone.vars.yml
