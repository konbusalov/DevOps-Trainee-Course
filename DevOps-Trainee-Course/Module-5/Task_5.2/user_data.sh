#!/bin/bash

hostname -I | awk '{print $1}' > /home/ubuntu/private-ip-address.txt