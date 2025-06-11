Zodbconvert script
==================

Intro
-----

This repository show a (work in progress) example to quickly convert an already exported Plone RelStorage postgresql dump file to filesystem based ZODB filestorage/blobstorages. This can be done with the relstorage provided zodbconvert.

The effort to configure zodbconvert correctly and run a local postgresql instance temporarily just for the conversion steps if somebody hands you a relational database dump, is unnecessary overhead for a 'one trick pony'. 

PLEASE NOTE: if you are already running Plone in a containerised environment with Relstorage and also a relational database, you already have a running database you can connect to with zodbconvert. With adequate devops skills you can create a service container/pod that connects to that database and exports the Plone site to filestorage/blobstage on any attached volume. 

Usage
-----

build.sh builds a container image based on postgresql 16, installs zodbconvert and installs a conversion script that automatically loads the dump file, and runs zodbconvert to output the filestorage/blobstorage from a mounted volume. 

You should mount a volume on /data,  where /data/zodb.dump is the source dump file. See the run.sh script.  the filestorage/blobstorage willl be written to /data/output/

The main use case for me is providing local filestorage/blobstraoge exports of our public Plone Foundatation website that use Relstorage There's some tricks and annoyances here that I'm still working / deliberating upon. 

* As we are using a hosted postrgresql_cluster, I tried to remove  aiven_extras using some low level pg_restore mangling before loading the dump file.  Your  SAAS-managed PostgreSQL cluster might install its own extensions, where loading the dump file in this container image will crash because it doesn't have the same extension installed. 

 cluster is managed by aiven and they install extensions that are almost impossible to remove when you create the dump. This is the only fool proof way me and ChatGPT could figure out after quite some time.

* postgresql container throws a weird error, I have to exit the convert.sh explicitly, otherwise Postgres keeps running. But the exit error is now also strange.

* It would be nice to be able to cat the dump fiile using stdin and getting a tar.gz as stdout. Then I could skip the Volume hassle. The container will need some scratch space, and larger dumps (> 1GB0) will likely crash without an extra temporary volume. Also the time out between creating the filestorage/blobstorage, zipping it and streaming it to stdout will likely not work or it timeouts.  For larger systems a dedicated export container/pod would be much more stable (see 'Please note' above)

Fred van Dijk