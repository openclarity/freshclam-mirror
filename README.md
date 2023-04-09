# Freshclam Mirror

A private ClamAV freshclam mirror server which periodically syncs signatures
using freshclam.

This is achieved using nginx, freshclam and cron.

The Dockerfile provides the definition for a server that serves the ClamAV signature files and updates them every 3 hours.


## Table of Contents<!-- omit in toc -->

- [Usage](#usage)
- [Building](#building)
- [Running](#running)
- [Manual signatures download](#Mmanual-signatures-download)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

# Usage

## Directing freshclam to use this mirror
To direct your freshclam instance to this mirror, configure your freshclam.conf file as such:
```
PrivateMirror http://<ip>:1000
ScriptedUpdates no
```

## Building
```
docker build -t <registry-name>/vmclarity-freshclam-mirror .
```

## Running
```
docker run -d -p 1000:80 --name vmclarity-freshclam-mirror <registry-name>/vmclarity-freshclam-mirror
```

## Manual signatures download 
```
curl -X GET http://<ip>:1000/clamav/main.cvd --output main.cvd
```

## Contributing

If you are ready to jump in and test, add code, or help with documentation,
please follow the instructions on our [contributing guide](/CONTRIBUTING.md)
for details on how to open issues, setup VMClarity for development and test.

## Code of Conduct

You can view our code of conduct [here](/CODE_OF_CONDUCT.md).

## License

[Apache License, Version 2.0](/LICENSE)
