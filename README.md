# odoo-docker-plus

> 🇪🇸 [¿Quieres ver la guía en español?](README_es.md)

> **Coming from the old Odoo 19 Docker video?** Use this project instead of the PDF guide from that video: it's more up to date and fixes the errors that guide had.

**A complete, ready-configured project to deploy Odoo 20 in under 5 minutes. No coding: one command.**

Built on the official Odoo image: safe and open source.

- ✅ Odoo 20 Community by default, no restrictions
- ✅ Enterprise (requires a license or token)
- ✅ Your own modules folder: custom, third-party, purchased or AI-built
- ✅ Opens in the browser out of the box, with `odoo.conf` already set up
- ✅ Always up to date: the latest nightly, or the date you choose
- ✅ Paper Muncher, Odoo 20's new PDF engine
- ✅ Linux philosophy: it does what it promises, with no extra features making it heavy to maintain
- ✅ Up-to-date docs in English and Spanish

Made for development and testing; also a solid base for something more serious.

## What it improves over the official image

| | Official `odoo:20` | odoo-docker-plus |
| --- | --- | --- |
| Configuration (`odoo.conf`) | ❌ Odoo 20 only listens on `127.0.0.1`: `localhost:8069` doesn't respond until you write your own config | ✅ Ready-made `config/odoo.conf`: opens in the browser out of the box, and every Odoo setting is one edit away |
| Your modules (`custom_addons`) | You create the folder, mount it and check `addons_path` | ✅ Drop your own, third-party or purchased modules into `custom_addons/` and Odoo picks them up |
| Odoo build | The one in the image (published days or weeks late) | The latest nightly, or the date you choose |
| Paper Muncher (Odoo 20's new PDF engine) | ❌ Not included | ✅ Installed (amd64 servers) |
| Extra dependencies | You write your own Dockerfile | One line in `requirements.txt` or `APT_PACKAGES` |
| `markdown2` | ❌ Missing (Odoo warns about it in the log) | ✅ |
| `phonenumbers` | 8.12 (Ubuntu's, outdated prefixes) | 9.0 |

## Requirements

You need **Docker** with **Docker Compose**, and **Git**. Docker Desktop and OrbStack already include Compose; on Linux it installs alongside Docker Engine following its official guide.

| System | Docker |
| --- | --- |
| **Windows** | [Docker Desktop](https://www.docker.com/products/docker-desktop/). Enable WSL 2 for good performance: [how to install WSL](https://learn.microsoft.com/windows/wsl/install) |
| **macOS** | [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [OrbStack](https://orbstack.dev/) (lighter and faster on Mac) |
| **Linux** | [Docker Engine](https://docs.docker.com/engine/install/) with the Compose plugin. Best option on Linux: you don't need Docker Desktop |

Git: [download it here](https://git-scm.com/downloads) if you don't have it (usually preinstalled on macOS and Linux).

Check that everything is ready:

```bash
docker -v
docker compose version
git --version
```

## Deploy Odoo with one command

```bash
git clone https://github.com/jcmontoyadev/odoo-docker-plus.git && cd odoo-docker-plus && docker compose up -d --build
```

Open http://localhost:8069 and create your database.

## What's in this project (repo)

| File | Purpose |
| --- | --- |
| `compose.yaml` | Odoo + PostgreSQL 17. Choose the build and system packages here |
| `Dockerfile` | Starts from `odoo:20` and adds the up-to-date build, Paper Muncher and your dependencies |
| `requirements.txt` | Your Python libraries, one per line |
| `config/odoo.conf` | Odoo configuration (mounted at `/etc/odoo`) |
| `custom_addons/` | Your modules |

## Always up-to-date Odoo

The official image isn't published every day: by the time you pull it, it can be weeks behind on fixes. In `compose.yaml`:

```yaml
ODOO_RELEASE: "latest"     # the latest published nightly
ODOO_RELEASE: "20261008"   # a specific build
ODOO_RELEASE: ""           # the one shipped in the official image
```

To update to the latest:

```bash
docker compose build --pull --no-cache && docker compose up -d
```

You can see the build date in Settings, at the very bottom.

## Adding dependencies

**Python:** one line in `requirements.txt`, with a pinned version:

```text
openpyxl==3.1.5
```

**System (apt):** in `compose.yaml`, space separated:

```yaml
APT_PACKAGES: "poppler-utils libzbar0"
```

Then: `docker compose up -d --build`.

## Your modules

1. Copy your module into `custom_addons/`.
2. Enable developer mode (Settings, at the very bottom).
3. Go to Apps, click **Update Apps List** and search for it.

If you change the Python code of an already installed module, restart Odoo:

```bash
docker compose restart odoo
```

## Paper Muncher

Odoo 20's new PDF engine. The template installs it in `/opt/paper-muncher/bin/`, where Odoo looks for it.

To use it:

1. Enable developer mode and, in Apps, remove the "Apps" filter from the search bar: the **Report Engine: Paper Muncher** module (`base_report_paper_muncher`) is technical and doesn't show up in the default list. Install it.
2. On the report you want, change the type to **PDF (Paper Muncher)**.

> Paper Muncher only publishes packages for **amd64**. On an Apple Silicon Mac (arm64) it is skipped and Odoo prints with wkhtmltopdf as usual. On your amd64 server, it is installed.

## Useful commands

| I want to… | Command |
| --- | --- |
| See the Odoo log | `docker compose logs -f odoo` |
| See which containers are running | `docker compose ps` |
| See memory and CPU usage | `docker stats` |
| Stop without deleting anything | `docker compose stop` |
| Start again | `docker compose up -d` |
| Remove the containers (data is kept) | `docker compose down` |
| Remove everything, **databases included** | `docker compose down -v` |

## Good practices

- **PostgreSQL:** Odoo 20 needs 16 or later. If you move to `postgres:18`, change the volume to `/var/lib/postgresql` (18 moved the data path).
- **Master password:** set it in `config/odoo.conf` (`admin_passwd`) before exposing Odoo outside your machine.
- **Two projects at once:** clone the repo into another folder and, in its `compose.yaml`, change the `container_name`s and the port (for example `8070:8069`).

## ⚠️ Security recommendations

The defaults (`http_interface = 0.0.0.0`, port `8069` open) are meant for local and development use. If you publish Odoo on the internet:

- **Going to publish it on the internet?** You'll want HTTPS and a hardened setup. Here's a [video](https://youtu.be/k_EFDQkpAi8?t=126) showing how it works in under 3 minutes.
- **Change the PostgreSQL password** in `compose.yaml` (`PASSWORD` and `POSTGRES_PASSWORD`, same value in both). The default one is public, since it's in the repo.
- **Set `admin_passwd`** in `config/odoo.conf`.

## Odoo in production?

This template is for development and testing. To run Odoo for your business, there are two ways:

- **Do it yourself, with commands:** production Odoo in 3 minutes. [Watch the video](https://youtu.be/k_EFDQkpAi8).
- **No commands, with our app:** a complete app that installs Odoo in production with HTTPS and hardens the server against bots, a constant threat today. [See how it works](https://youtu.be/k_EFDQkpAi8?t=126).

Our app is for you if:

- You want Odoo for your business.
- You want to publish Odoo securely.
- You need an installer for multiple instances, all with automatic HTTPS.
- You don't have time for the installation, or you don't have technical knowledge.

Support and updates are included at no extra cost.

Not sure whether Enterprise or Community, or Odoo.sh or your own VPS, suits you? Book a free 5-minute call and we'll help you decide: [book here](https://odooerpcloud.com/appointment)

Related videos (in Spanish):

- **Odoo in production:** how we deploy it, [YouTube video](https://youtu.be/k_EFDQkpAi8)
- **What's new in Odoo 20:** [YouTube video](https://youtu.be/jeq7t1qoBRw)
- **Odoo 20 for development without Docker** (Ubuntu 26.04, with Paper Muncher): [YouTube video](https://youtu.be/_qqtEde-_5M)

## License

MIT. Odoo belongs to Odoo S.A.; this template only builds on its official Docker image.
