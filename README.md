# CLIProxyAPI-CF

Deploy [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) via Cloudflare Workers and Container (serverless).

## Get started

Before you get going: this project **requires the Worker Paid Plan (5$/month)** as it uses Cloudflare Container and Durable Object for the backend service, both are paid features.

First, put these environment variables in your Cloudflare secrets:

```toml
# Your Cloudflare Account ID
R2_ACCOUNT_ID=xxx 

# Your Cloudflare R2 Access Key ID
AWS_ACCESS_KEY_ID=xxx

# Your Cloudflare R2 Access Key
AWS_SECRET_ACCESS_KEY=xxx
```

Visit the cloudflare [official guide](https://developers.cloudflare.com/r2/api/tokens/) to get R2 access key and secret.

Second, copy `./container_src/config.example.yaml` to `./container_src/config.yaml` and follow instruction on [CLIProxyAPI docs](https://help.router-for.me/hands-on/tutorial-0.html) to fill out required fields.

These fields are mandatory:

- `secret-key`
- `api-keys`

Third, run the command to deploy to Cloudflare:

```bash
bun install && bun deploy
```

> Note: [bun](https://bun.com/) have to be installed on your machine, or you cloud use`npm`, `pnpm` instead.

The base url for endpoint is: `https://your-project-name.smycd.workers.dev/`. For more details, refer to [CLIProxyAPI docs](https://help.router-for.me/).

## Configuration

After installation, you'll need [EasyCLI](https://github.com/router-for-me/EasyCLI) to set up your providers.