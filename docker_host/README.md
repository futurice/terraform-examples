# Docker host

This module implements a host for docker containers on EC2, though it's generic enough to be easily transferred to e.g. DigitalOcean (where it originally used to run, in fact).

## Automated backups

A host based on this module uses [`docker-volume-backup`](https://github.com/futurice/docker-volume-backup) to automatically back up it's data volume (mounted at `/data`) nightly, and upload the backup to S3. The backup schedule and other settings can be customized per host.

The backup is always uploaded as `latest.tar.gz`, but the bucket has versioning enabled, and will thus retain non-latest backups as well. The retention period is 1 year, by default, after which old backups are automatically deleted by S3.

```
$ HOST=your-host
$ aws s3api list-object-versions --bucket "$HOST-backup" \
  | node -p 'JSON.parse(fs.readFileSync(0)).Versions.map(v => `${v.Key} - ${v.LastModified} - ${v.Size} bytes`).join("\n")'
latest.tar.gz - 2018-10-08T08:17:20.000Z - 4412057283 bytes
latest.tar.gz - 2018-10-08T07:08:36.000Z - 4439945753 bytes
latest.tar.gz - 2018-10-08T05:59:50.000Z - 4407786628 bytes
latest.tar.gz - 2018-10-08T04:51:03.000Z - 4406225026 bytes
latest.tar.gz - 2018-10-08T03:42:23.000Z - 4436695414 bytes
...
```
