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

1. Go to [Cloudflare dashboard](https://dash.cloudflare.com) → **My Profile** → **API Tokens**
2. Click **Create Token**
3. Use the **Edit zone DNS** template
4. Under **Zone Resources**, select your domain (e.g. `example.com`)
5. Click **Continue to summary**, then **Create Token**
6. Copy the token — you won't be able to see it again

### 3. Configure environment

Create a `.env` file in this directory:

```sh
CF_API_TOKEN=your_cloudflare_token_here
```

### 4. Update the hostname

Edit `Caddyfile` and replace `impostor.example.com` with your own hostname:

```
impostor.yourdomain.com:22023 {
    reverse_proxy impostor:8080
}
```

Also update `config.json` to set your public hostname:

```json
"Server": {
    "PublicIp": "impostor.yourdomain.com",
    ...
}
```

### 5. Start the server

```sh
docker compose up -d --build
```

On first start, Caddy will automatically obtain a TLS certificate from Let's Encrypt. This takes about 10–15 seconds.

### 6. Verify everything is running

```sh
docker compose logs -f
```

Look for this line in the Caddy logs to confirm the certificate was issued:

```
certificate obtained successfully  identifier="impostor.yourdomain.com"
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
└── .env                 # Cloudflare API token (keep secret, don't commit)
```

## Configuration

Server behaviour (anti-cheat, timeouts, compatibility) is controlled by `config.json`. See the [Impostor configuration docs](https://impostor.github.io/Impostor/) for all available options. Restart the impostor container after making changes:

```sh
docker compose restart impostor
```
