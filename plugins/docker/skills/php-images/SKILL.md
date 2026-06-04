---
description: |
    Use this skill when working with Specsnl PHP Docker images. It covers what the images are, their repository
    structure and variants, which PHP versions are maintained, and how to locate sibling images both on GitHub
    and locally.
name: php-images
---

# PHP Images Skill

This skill provides information about the PHP images used in the Specsnl projects, including where to find the source
files and how to locate sibling images for other PHP versions.

## What are the PHP images?

The PHP images are Docker images that serve as the base for the various PHP environments used in Specsnl projects. These
images are built on top of official PHP images and include additional dependencies and configurations specific to our
needs.

Each PHP image repository follows a consistent structure with three main Dockerfiles (variants):

- `fpm/Dockerfile`: The Dockerfile for the FPM variant of the image.
- `apache/Dockerfile`: The Dockerfile for the Apache variant of the image.
- `frankenphp/Dockerfile`: The Dockerfile for the FrankenPHP variant of the image.

Furthermore, there is a `files` directory that contains additional files used during the build process, such as
configuration files and scripts.

- `files/general`: Contains files that are shared across all PHP Dockerfiles.
- `files/<variant_name>`: Contains files specific to the `<variant_name>` variant of the image.

## Supported PHP versions

Specsnl maintains images for 3 supported PHP versions at any given time. To determine the current supported versions,
fetch the endoflife.date API: `https://endoflife.date/api/v1/products/php/`. This returns a JSON array of PHP releases
with their active-support and security-support end dates. Use the 3 most recent versions that have not yet reached
end-of-life as the supported set.

If a Specsnl repository for the newest PHP version does not exist yet, we are still supporting the previous version as
the latest one. For example, if PHP 8.5 is the newest version but the `php85` repository has not been created yet, we
are still treating PHP 8.4 as the latest.

## Where can I find the source files on GitHub?

The source files for the PHP images can be found in the repositories that follow the following structure:
`https://github.com/specsnl/php<major><minor>`. For example, for PHP 8.5, the source files are located in
`https://github.com/specsnl/php85`.

## How to find sibling images on GitHub

The sibling repositories follow the same URL pattern described above. For example, if you are looking at the `php85`
repository, the siblings are at `https://github.com/specsnl/php84` and `https://github.com/specsnl/php83`.

## How to find sibling images locally

If you are working locally in one of the PHP image repositories and want to find the sibling images for other PHP
versions, check if there are sibling directories in the same parent directory. For example, if you are in the `php85`
repository, check if `php84` and `php83` directories exist alongside it. If they do, they are most likely the sibling
images for PHP 8.4 and PHP 8.3 respectively. Verify by checking the remote repository URLs in the git configuration
or by reading the README files in those directories.
