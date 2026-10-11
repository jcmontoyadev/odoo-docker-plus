# odoo-docker-plus

> 🇬🇧 [Read this guide in English](README.md)

> **¿Vienes del video antiguo de Odoo 19 con Docker?** Usa este proyecto en lugar del PDF de ese video: está más actualizado y corrige los errores que daba aquella guía.

Odoo 20 en Docker a partir de la imagen oficial, con lo que a la oficial le falta. Para desarrollar y probar; también te sirve de base para algo más serio.

## Qué mejora sobre la imagen oficial

| | `odoo:20` oficial | odoo-docker-plus |
| --- | --- | --- |
| Abrir `localhost:8069` | ❌ No responde: Odoo 20 solo escucha en `127.0.0.1` | ✅ Corregido en `config/odoo.conf` |
| Compilación de Odoo | La de la imagen (se publica con días o semanas de retraso) | La última nightly, o la fecha que elijas |
| Paper Muncher (nuevo motor de PDF de Odoo 20) | ❌ No viene | ✅ Instalado (servidores amd64) |
| Dependencias extra | Te toca escribir tu propio Dockerfile | Una línea en `requirements.txt` o en `APT_PACKAGES` |
| `markdown2` | ❌ Falta (Odoo lo avisa en el log) | ✅ |
| `phonenumbers` | 8.12 (la de Ubuntu, prefijos viejos) | 9.0 |

## Requisitos

Necesitas **Docker** con **Docker Compose**, y **Git**. Docker Desktop y OrbStack ya traen Compose; en Linux se instala junto a Docker Engine siguiendo su guía oficial.

| Sistema | Docker |
| --- | --- |
| **Windows** | [Docker Desktop](https://www.docker.com/products/docker-desktop/). Activa WSL 2 para que vaya fluido: [cómo instalar WSL](https://learn.microsoft.com/windows/wsl/install) |
| **macOS** | [Docker Desktop](https://www.docker.com/products/docker-desktop/) o [OrbStack](https://orbstack.dev/) (más ligero y rápido en Mac) |
| **Linux** | [Docker Engine](https://docs.docker.com/engine/install/) con el plugin de Compose. Es lo mejor en Linux: no necesitas Docker Desktop |

Git: [descárgalo aquí](https://git-scm.com/downloads) si no lo tienes (en macOS y Linux suele venir instalado).

Comprueba que todo está listo:

```bash
docker -v
docker compose version
git --version
```

## Arranque en 3 pasos

```bash
git clone https://github.com/jcmontoyadev/odoo-docker-plus.git
cd odoo-docker-plus
docker compose up -d --build
```

Abre http://localhost:8069 y crea tu base de datos.

## Qué hay en el repo

| Fichero | Para qué |
| --- | --- |
| `compose.yaml` | Odoo + PostgreSQL 17. Aquí eliges la compilación y los paquetes del sistema |
| `Dockerfile` | Parte de `odoo:20` y añade compilación al día, Paper Muncher y tus dependencias |
| `requirements.txt` | Tus librerías de Python, una por línea |
| `config/odoo.conf` | La configuración de Odoo (se monta en `/etc/odoo`) |
| `custom_addons/` | Tus módulos |

## Odoo siempre al día

La imagen oficial no se publica cada día: cuando la descargas puede llevar semanas de correcciones atrasadas. En `compose.yaml`:

```yaml
ODOO_RELEASE: "latest"     # la última nightly publicada
ODOO_RELEASE: "20261008"   # una compilación concreta
ODOO_RELEASE: ""           # la que trae la imagen oficial
```

Para actualizar a la última:

```bash
docker compose build --pull --no-cache && docker compose up -d
```

La fecha de la compilación la ves en Ajustes, abajo del todo.

## Añadir dependencias

**Python:** una línea en `requirements.txt`, con versión fija:

```text
openpyxl==3.1.5
```

**Sistema (apt):** en `compose.yaml`, separados por espacios:

```yaml
APT_PACKAGES: "poppler-utils libzbar0"
```

Después: `docker compose up -d --build`.

## Tus módulos

1. Copia tu módulo dentro de `custom_addons/`.
2. Activa el modo desarrollador (Ajustes, abajo del todo).
3. Ve a Aplicaciones, pulsa **Actualizar lista de aplicaciones** y búscalo.

Si cambias el código Python de un módulo ya instalado, reinicia Odoo:

```bash
docker compose restart odoo
```

## Paper Muncher

Es el nuevo motor de PDF de Odoo 20. La plantilla lo instala en `/opt/paper-muncher/bin/`, donde Odoo lo busca.

Para usarlo:

1. Activa el modo desarrollador y, en Aplicaciones, quita el filtro "Aplicaciones" del buscador: el módulo **Report Engine: Paper Muncher** (`base_report_paper_muncher`) es técnico y no sale en la lista normal. Instálalo.
2. En el informe que quieras, cambia el tipo a **PDF (Paper Muncher)**.

> Paper Muncher solo publica paquetes para **amd64**. En un Mac con chip Apple (arm64) se omite y Odoo imprime con wkhtmltopdf como siempre. En tu servidor amd64, sí se instala.

## Comandos útiles

| Quiero… | Comando |
| --- | --- |
| Ver el log de Odoo | `docker compose logs -f odoo` |
| Ver qué contenedores están corriendo | `docker compose ps` |
| Ver cuánta memoria y CPU consumen | `docker stats` |
| Parar sin borrar nada | `docker compose stop` |
| Volver a arrancar | `docker compose up -d` |
| Borrar los contenedores (los datos se conservan) | `docker compose down` |
| Borrar todo, **bases de datos incluidas** | `docker compose down -v` |

## Buenas prácticas

- **PostgreSQL:** Odoo 20 necesita la 16 o superior. Si pasas a `postgres:18`, cambia el volumen a `/var/lib/postgresql` (la 18 movió la ruta de los datos).
- **Contraseña maestra:** ponla en `config/odoo.conf` (`admin_passwd`) antes de exponer Odoo fuera de tu equipo.
- **Dos proyectos a la vez:** clona el repo en otra carpeta y, en su `compose.yaml`, cambia los `container_name` y el puerto (por ejemplo `8070:8069`).

## ⚠️ Recomendaciones de seguridad

Los valores por defecto (`http_interface = 0.0.0.0`, puerto `8069` abierto) son para uso local y desarrollo. Si publicas Odoo en internet:

- **¿Vas a publicarlo en internet?** Querrás HTTPS y una configuración blindada. Te dejo este [video](https://youtu.be/k_EFDQkpAi8?t=110) para que veas cómo funciona en menos de 3 minutos.
- **Cambia la contraseña de PostgreSQL** en `compose.yaml` (`PASSWORD` y `POSTGRES_PASSWORD`, el mismo valor en ambas). La de por defecto es pública, porque está en el repo.
- **Pon `admin_passwd`** en `config/odoo.conf`.

## ¿Odoo en producción?

Esta plantilla es para desarrollar y probar. Para tener Odoo en tu negocio, hay dos caminos:

- **Por tu cuenta, con comandos:** Odoo en producción en 3 minutos. [Mira el video](https://youtu.be/k_EFDQkpAi8).
- **Sin comandos, con nuestra app:** una app completa que instala Odoo en producción con HTTPS y blinda el servidor contra los ataques de bots, algo habitual hoy en día. [Mira cómo funciona](https://youtu.be/k_EFDQkpAi8?t=110).

Nuestra app es para ti si:

- Quieres Odoo para tu negocio.
- Quieres montar Odoo público y seguro.
- Necesitas un instalador de múltiples instancias, todas con HTTPS automático.
- No tienes tiempo para dedicar a la instalación, o no tienes conocimientos técnicos.

Soporte y actualizaciones incluidos, sin coste adicional.

¿No tienes claro si te conviene Enterprise o Community, u Odoo.sh o tu propio VPS? Agenda una llamada gratis de 5 minutos y te ayudamos a decidir: [agenda](https://odooerpcloud.com/appointment)

Videos relacionados:

- **Odoo en producción:** cómo lo desplegamos, [video en YouTube](https://youtu.be/k_EFDQkpAi8)
- **Novedades de Odoo 20:** [video en YouTube](https://youtu.be/jeq7t1qoBRw)
- **Odoo 20 para desarrollo sin Docker** (Ubuntu 26.04, con Paper Muncher): [video en YouTube](https://youtu.be/_qqtEde-_5M)

## Licencia

MIT. Odoo es de Odoo S.A.; esta plantilla solo parte de su imagen oficial de Docker.
