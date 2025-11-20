# Wowza

This is the containerized UC Berkeley Library installation of the [Wowza](https://www.wowza.com/) commercial media server. This is one piece of the overall A/V stack which also includes [github.com/BerkeleyLibrary/avplayer](https://github.com/BerkeleyLibrary/avplayer). For overall process documentation, see [Google Docs](https://docs.google.com/document/d/1xckZnP0MeRThHRtlV8asf_ehitWaXT5rXqxp1zVq4qU/edit).

For the old standalone installation and associated code, see the [lap/wowza-legacy](https://git.lib.berkeley.edu/lap/wowza-legacy) project.

## Structure of this stack

The stack consists of a single container running both the Wowza streaming media engine application, and the Wowza streaming engine manager UI (as in a typical uncontainerized Wowza installation).

## Development

Create a local `.env` file based on `env.example` if you do not have one in your working copy.

```sh
docker compose build --pull
docker compose up
docker compose exec app bash
```

### Accessing Wowza Streaming Engine Manager

To access Wowza Streaming Engine Manager, use the URL [`http://localhost:8088/enginemanager/login.htm`](http://localhost:8088/enginemanager/login.htm) with username and password specified as `$WOWZA_MANAGER_USER` and `$WOWZA_MANAGER_PASSWORD` in a `.env` file (see [`env.example`](env.example)).

## Testing

See the [README](test/README.md) in the test directory.

## Updating the development license

The Wowza staging server uses a development license key that is only good
for six months. The same key is also used in CI for testing Wowza container
and configuration changes.

## Prerequisites:

- Access to the `libraryit@berkeley.edu` SPA

## Steps:

### Obtain the new license key

#### 1-year R&D license

- Log into https://www.wowza.com/ using the Library IT institutional account (username `libraryit@berkeley.edu`, password in LPE under Shared-LIT-Applications)
- [Open a support ticket](https://www.wowza.com/portal/help/engine) for Wowza Streaming Engine, requesting a 1-year R&D license.
- Look for email from Wowza to `libraryit@berkeley.edu` in response to the ticket, or check [My Account / Support](https://portal.wowza.com/account/support). Once the request is approved (which may take a few days), `libraryit` should receive an email containing the license key (a string of the form `ERDA4-XXXXX-XXXXX-XXXXX-XXXXX-XXXXX-XXXXXXXXXXXX`).
  - **Note:** this email should also include the expiration information

#### 30-day demo license

In a pinch, it should be possible to get a 30-day demo license quickly, without any human intervention on the Wowza side.

- Log into https://www.wowza.com/ using the Library IT institutional account (username `libraryit@berkeley.edu`, password in LPE under Shared-LIT-Applications)
- Navigate to https://www.wowza.com/media-server/developers/license, agree to the EULA, and submit
- Look for email from Wowza to `libraryit@berkeley.edu` containing the license key (should be a string of the form `EDEV4-XXXXX-XXXXX-XXXXX-XXXXX-XXXXX-XXXXXXXXXXXX`)
  - **Note:** this email should also include the expiration information

### Update the new license key in the repo's secrets

On the `main` branch of this repository:

- Locate your `.env` file in your working copy
- Update:
  1. the WOWZA_LICENSE_KEY value
  2. the "generated" date comment
  3. the "expires" date comment
- Test the installation:
  1. build an image with `docker-compose build --pull`
  2. run tests with `docker-compose run app /opt/app/test/run_tests.py`
- If the tests pass, update the `WOWZA_LICENSE_KEY` [repository secret for Github Actions](https://github.com/BerkeleyLibrary/wowza/settings/secrets/actions)

### Update the license key in the Wowza staging stack

In the `ops/docker-swarm` repo:

- Locate the stack file, files/staging/swarm/stacks/wowza-staging.yml
- Under wowza:environment, update:
  1. the `WOWZA_LICENSE_KEY` value
  2. the "expires" date comment
- Commit and push the changes

After the ops/docker-swarm build redeploys the app, test the new key by logging into the staging Wowza administration UI:

- Navigate to https://wowza-manager.ucblib.org/.
  - Log in (username `wowza`, password in LPE under Shared-LIT-Applications).
- Navigate to the "Home" screen

You should see something like:

> #### Welcome to Wowza Streaming Engine!
> Developer License (Expires Sep 16, 2021) - 182 days left

### Set a new reminder

1. Add a reminder to the DevOps shared calendar to update the license in another six months.
2. Update the due date for this ticket to (at least) the day before the new license expires.
