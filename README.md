# FreeTube iOS Builder

This repository builds an unsigned iOS IPA from the current upstream Yattee source.

## What it does

- Clones `yattee/yattee` from GitHub.
- Builds the native iOS app with the upstream `Yattee` scheme.
- Disables Apple code signing during CI.
- Changes the installed display name to `FreeTube` after compilation.
- Packages the resulting `.app` into `FreeTube.ipa`.
- Uploads the IPA as a GitHub Actions artifact for sideloading with SideStore / AltStore.

## Build

Open **Actions** -> **Build FreeTube iOS IPA** -> **Run workflow**.

A build also runs automatically whenever this builder configuration is changed on `main`.

When the workflow completes, download the `FreeTube-iOS-unsigned` artifact and extract `FreeTube.ipa`.

## Source

Application source is pulled from:

- https://github.com/yattee/yattee

The upstream project is licensed under GPL-3.0. This builder does not remove or replace upstream licensing.
