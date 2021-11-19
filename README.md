# Wowza

This is the containerized UC Berkeley Library installation of the
[Wowza](https://www.wowza.com/) commercial media server.

For the old standalone installation and associated code, see the
[lap/wowza-legacy](https://git.lib.berkeley.edu/lap/wowza-legacy) project.

## Structure of this stack

The stack consists of a single container, in which runs both
the Wowza streaming media engine application, and the Wowza
streaming engine manager UI (as in a typical uncontainerized
Wowza installation).

## Development

1. Build the Docker stack with

   ```sh
   docker-compose build --pull
   ```

2. From the project root directory, start the Docker stack with

   ```sh
   docker-compose up
   ```

To log into the container with an interactive shell:

```sh
docker exec -it -u wowza -w /usr/local/WowzaStreamingEngine wowza /bin/bash
```
  
### Accessing Wowza Streaming Engine Manager

To access Wowza Streaming Engine Manager, use the URL 
[`http://localhost:8088/enginemanager/login.htm`](http://localhost:8088/enginemanager/login.htm)
with username and password specified as `$WOWZA_MANAGER_USER` and `$WOWZA_MANAGER_PASSWORD` in [.env](.env)

## Testing

See the [README](test/README.md) in the test directory.

## Updating the development license

The Wowza staging server uses a development license key that is only good
for six months. The same key is also used in CI for testing Wowza container
and configuration changes.

## Prerequisites:

- access to the `libraryit@berkeley.edu` SPA

## Steps:

### Obtain the new license key

- Log into https://www.wowza.com/ using the Library IT institutional account (username `libraryit@berkeley.edu`, password in LPE under Shared-LIT-Applications)
- Navigate to https://www.wowza.com/media-server/developers/license, agree to the EULA, and submit
- Look for email from Wowza to `libraryit@berkeley.edu` containing the license key (should be a string of the form `EDEV4-XXXXX-XXXXX-XXXXX-XXXXX-XXXXX-XXXXXXXXXXXX`)
  - **Note:** this email should also include the expiration information

### Update the new license key in the `lap/wowza` repo

On the master branch of this repository:

- Locate the `.env` file in the root of the repo
  - **Note:** ordinarily `.env` files aren't checked in, but this one is. It doesn't end up in the container.
- Update:
  1. the WOWZA_LICENSE_KEY value
  2. the "generated" date comment
  3. the "expires" date comment
- Test the installation:
  1. build an image with `docker-compose build --pull`
  2. run tests with `docker-compose run wowza /opt/app/test/run_tests.py`
- If the tests pass, commit and push the changes

### Update the license key in the Wowza staging stack

In the `ops/docker-swarm` repo:

- Locate the stack file, files/staging/swarm/stacks/wowza-staging.yml
- Under wowza:environment, update:
  1. the WOWZA_LICENSE_KEY value
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
