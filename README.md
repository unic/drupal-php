# Unic Drupal PHP Base

A PHP-FPM base image tailored for running [Drupal](https://www.drupal.org/) projects. It bundles the PHP extensions, image optimization tools, and utilities that Drupal projects commonly require.

## Versions

| PHP | Branch | Notes |
|---|---|---|
| 7.4 | main | _EOL_ |
| 8.1 | release/8.1 | _EOL_ |
| 8.2 | — | not available |
| 8.3 | release/8.3 | |
| 8.4 | release/8.4 | current |

## Included Software

### PHP Extensions

| Extension | Notes |
|---|---|
| gd | Image processing with FreeType, JPEG, and WebP support |
| opcache | Bytecode caching for improved performance |
| pdo_mysql | MySQL / MariaDB database driver |
| pdo_pgsql | PostgreSQL database driver |
| zip | ZIP archive support |
| bcmath | Arbitrary precision mathematics |
| redis | Redis client via PECL |
| apcu | In-memory key-value cache via PECL |

### Tools

| Tool | Purpose |
|---|---|
| Composer | PHP dependency manager |
| Drush Launcher | Runs the project-local Drush version |
| git | Version control |
| rsync | File synchronization |
| mariadb-client | Database CLI tools |
| imagemagick | Image conversion and manipulation |
| graphicsmagick | Image conversion and manipulation |
| gifsicle | GIF optimization |
| jpegoptim | JPEG optimization |
| optipng | PNG optimization |
| pngquant | PNG lossy compression |
| pngcrush | PNG lossless compression |

### PHP Configuration

The following defaults are applied on top of the standard PHP-FPM configuration:

| Setting | Value |
|---|---|
| `upload_max_filesize` | 20M |
| `post_max_size` | 20M |
| `memory_limit` | 256M |
| `opcache.memory_consumption` | 128 |
| `opcache.interned_strings_buffer` | 8 |
| `opcache.max_accelerated_files` | 4000 |
| `opcache.revalidate_freq` | 60 |

## Usage

Pull the image from Docker Hub:

```bash
docker pull unicdocker/drupal-php:release-8.4
```

Or use it as a base image in your own `Dockerfile`:

```dockerfile
FROM unicdocker/drupal-php:release-8.4
```

The `latest` tag always points to the most recent build from the `main` branch.

## Build

### Local

Build the image locally using your Docker daemon. No additional dependencies are required:

```bash
docker build -t unicdocker/drupal-php:latest .
```

### CI/CD

Images are built and published to [Docker Hub](https://hub.docker.com/r/unicdocker/drupal-php) automatically via GitHub Actions whenever changes are pushed to `main` or any `release/**` branch, or when a version tag (`v*.*.*`) is created.
