# Freshclam Mirror

Private ClamAV mirror server which periodically syncs signatures using `freshclam`.
The `s6-overlay` is used as process supervisor for running `nginx` and `freshclam` daemons.

## Table of Contents<!-- omit in toc -->

- [Usage](#usage)
- [Building](#building)
- [Running](#running)
- [Manual signatures download](#manual-signatures-download)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

# Usage

## Directing freshclam to use this mirror

Update `freshclam.conf` file with the following settings to make `freshclam` to use this mirror:

```
PrivateMirror http://<ip>:<port>
ScriptedUpdates no
```

## Building
```
docker build -t <registry-name>/vmclarity-freshclam-mirror .
```

## Running
```
docker run -d -p <port>:80 --name vmclarity-freshclam-mirror <registry-name>/vmclarity-freshclam-mirror
```

## Manual signatures download 
```
curl -X GET http://<ip>:<port>/clamav/main.cvd --output main.cvd
```

## Contributing

If you are ready to jump in and test, add code, or help with documentation,
please follow the instructions on our [contributing guide](/CONTRIBUTING.md)
for details on how to open issues, setup VMClarity for development and test.

## Code of Conduct

You can view our code of conduct [here](/CODE_OF_CONDUCT.md).

## License

[Apache License, Version 2.0](/LICENSE)
