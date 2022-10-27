# Dockerfile for code-server with Python 3 environment

[![GitHub Discussions](https://badgen.net/badge/GitHub/Discussions?color=blue&icon=github)](https://github.com/eisimoes/code-server/discussions)
[![Latest Release](https://badgen.net/github/release/eisimoes/code-server?color=blue&label=Latest%20Release)](https://github.com/eisimoes/code-server/releases)
[![Latest Tag](https://badgen.net/github/tag/eisimoes/code-server?color=blue&label=Latest%20Tag)](https://github.com/eisimoes/code-server/tags)
[![Open Issues](https://badgen.net/github/open-issues/eisimoes/code-server?color=blue&label=Open%20Issues)](https://github.com/eisimoes/code-server/issues)
[![License](https://badgen.net/github/license/eisimoes/code-server?color=blue&label=License)](https://github.com/eisimoes/code-server/blob/master/LICENSE)

Code-server is Visual Studio Code running on a remote server, accessible through a browser.

## Build

If you want to make local modifications to the images for development purposes or just to customize the logic.

```bash
git clone https://github.com/eisimoes/code-server
cd code-server
# Customize
docker image build --pull --build-arg CODE_RELEASE=3.XX.XX -t code-server:3.XX.XX .
```

## Examples of usage

### Basic

Create a *code-server* container using the image's default configuration.

```bash
docker container run -d -p 80:8080 -e TZ=America/Sao_Paulo eisimoes/code-server
```

Enable SSL with a Self-Signed certificate.

```bash
docker container run -d -p 443:8443 -e TZ=America/Sao_Paulo eisimoes/code-server --bind-addr 0.0.0.0:8443 --auth none --cert "" /workspace
```

For more configuration options.

```bash
docker container run --rm eisimoes/code-server --help
```

### Advanced

Create a *code-server* using the host's user and storage. 

```bash
docker container run -d -p 443:8443 -e TZ=America/Sao_Paulo -u $(id -u):$(id -g) -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /etc/shadow:/etc/shadow:ro -v /home/myuser/:/home/myuser/ eisimoes/code-server --bind-addr 0.0.0.0:8443 --auth none --cert "" /home/myuser/workspace
```

Use a pre-existing certificate.

```bash
docker container run -d -p 443:8443 -e TZ=America/Sao_Paulo -v /etc/ssl/server.crt:/etc/ssl/server.crt:ro -v /etc/ssl/server.key:/etc/ssl/server.key:ro eisimoes/code-server --bind-addr 0.0.0.0:8443 --auth none --cert /etc/ssl/server.crt --cert-key /etc/ssl/server.key /workspace
```

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

<https://github.com/eisimoes/code-server/issues>

## Credits

Based on <https://github.com/linuxserver/docker-code-server>.

## License

- eisimoes/code-server: [MIT License](./LICENSE)
- cdr/code-server : [MIT License](https://github.com/cdr/code-server/blob/main/LICENSE)
