#!/bin/bash
docker run --rm -v "$PWD/data:/data" -e POSTGRES_PASSWORD=dummy  postgres2zodb