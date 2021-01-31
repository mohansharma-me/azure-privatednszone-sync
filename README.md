# Azure Private DNS Zone Sync
Script which sync A records from Azure Private DNS Zone to machine's host file

This script helps in copying A records from Private DNS zones to /etc/hosts file

## Prerequisites

- Install [JQ](https://stedolan.github.io/jq/)
- Install [HTTPie](https://httpie.io)
- Azure Account

## Steps

- Register app in Azure Portal with permission to read Private DNS Zone
- Update and copy dns.config file to `/path/to/some-directory/` path
- Run `dns-sync.sh /path/to/some-directory/` with appropriate permission

### Note

- dns.config file contains secret which should be kept in control in case access allows writes as well
- Pull requests are welcome :)
