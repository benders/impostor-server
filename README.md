# Impostor Server

A self-hosted [Among Us](https://www.innersloth.com/games/among-us/) server using [Impostor](https://github.com/Impostor/Impostor), with automatic HTTPS via Caddy and Cloudflare DNS.

For full server configuration options, see the [Impostor documentation](https://impostor.github.io/Impostor/).

## What's included

- **Impostor** — the game server, handling UDP game traffic directly on port 22023
- **Caddy** — an HTTPS reverse proxy for TCP traffic on port 22023, with automatic TLS certificates via Let's Encrypt (no port 80 required)
- **Plugins**: [Reactor](https://github.com/NuclearPowered/Reactor) and [Impostor.Http](https://github.com/Impostor/Impostor.Http)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with the Compose plugin
- A domain name with DNS hosted on **Cloudflare**
- A DNS record (A or CNAME) pointing your hostname to this server's public IP
- Port **22023** (TCP and UDP) forwarded to this server on your router

## Setup

### 1. Clone this repository

```sh
git clone <this-repo-url>
cd impostor-server
```

### 2. Create a Cloudflare API token

Caddy uses the Cloudflare API to obtain a TLS certificate without needing port 80 open.

The token can be either User-level (**My Profile** → **API Tokens**) or Account-level (**Manage Account** → **Account API Tokens**).

1. Go to the [Cloudflare dashboard](https://dash.cloudflare.com) and navigate to the appropriate API Tokens page
2. Click **Create Token**
3. Use the **Edit zone DNS** template
4. Under **Permissions**, ensure both of these are present:
   - `Zone` / `DNS` / **Edit**
   - `Zone` / `Zone` / **Read**
5. Under **Zone Resources**, select your domain (e.g. `example.com`)
6. Click **Continue to summary**, then **Create Token**
7. Copy the token — you won't be able to see it again

### 3. Configure environment

Copy the example file and fill in your values:

```sh
cp example.env .env
```

`.env` variables:

| Variable | Description |
|---|---|
| `PUBLIC_HOST` | Your server's public hostname (e.g. `impostor.example.com`) |
| `CF_API_TOKEN` | Cloudflare API token for DNS-based TLS certificate issuance |

### 4. Start the server

```sh
docker compose up -d --build
```

On first start, Caddy will automatically obtain a TLS certificate from Let's Encrypt. This takes about 10–15 seconds.

### 5. Verify everything is running

```sh
docker compose logs -f
```

Look for this line in the Caddy logs to confirm the certificate was issued:

```
certificate obtained successfully  identifier="impostor.example.com"
```

## Connecting

In Among Us, go to **Online** → **Change Server** and enter:

- **Server address**: your hostname (e.g. `impostor.example.com`)
- **Port**: `22023`

## Managing the server

| Command | Description |
|---|---|
| `docker compose up -d` | Start containers |
| `docker compose down` | Stop containers |
| `docker compose restart impostor` | Restart only the game server |
| `docker compose logs -f` | Follow logs from all containers |
| `docker compose logs -f impostor` | Follow game server logs only |
| `docker compose pull && docker compose up -d` | Update to latest images |

## File structure

```
.
├── docker-compose.yml   # Container orchestration
├── Dockerfile.caddy     # Custom Caddy build with Cloudflare DNS plugin
├── Caddyfile            # Caddy reverse proxy configuration
├── config.json          # Impostor server configuration
├── plugins/             # Impostor plugins (.dll files)
├── example.env          # Template for environment variables
└── .env                 # Your local environment variables (keep secret, don't commit)
```

## Backups

The `caddy_data` volume holds TLS certificates and should be backed up so you don't have to re-issue certificates on a new host.

### Create a backup

```sh
./backup.sh
```

This creates a timestamped archive in `backups/`, e.g. `backups/impostor-server_caddy_data-2025-01-01.tar.gz`.

### Restore from a backup

1. Create the volume (skip if it already exists):

   ```sh
   docker volume create impostor-server_caddy_data
   ```

2. Populate it from a backup archive:

   ```sh
   docker run --rm \
     -v impostor-server_caddy_data:/data \
     -v "$(pwd)/backups":/backup \
     alpine \
     tar -xzvf /backup/impostor-server_caddy_data-YYYY-MM-DD.tar.gz -C /data
   ```

   Replace `YYYY-MM-DD` with the date of the backup you want to restore.

3. Start the server normally — Caddy will use the restored certificates immediately.

## Configuration

Server behaviour (anti-cheat, timeouts, compatibility) is controlled by `config.json`. See the [Impostor configuration docs](https://impostor.github.io/Impostor/) for all available options. Restart the impostor container after making changes:

```sh
docker compose restart impostor
```
