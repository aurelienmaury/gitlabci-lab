#!/usr/bin/env bash

ansible-playbook ansible/undeploy.yml -e@service_zone.vars.yml
