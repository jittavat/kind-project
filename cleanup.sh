#!/bin/bash
docker rmi -f app-a:1.0
docker rmi -f app-b:1.0
kind delete cluster