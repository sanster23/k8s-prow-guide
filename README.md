# k8s_prow_flask_cicd

### PROW - CI/CD the Kubernetes way

Prow is a Kubernetes based CI/CD system. Jobs can be triggered by various types of events and report their status to
many different services. In addition to job execution, Prow provides GitHub automation in the form of policy
enforcement, chat-ops via `/foo` style commands, and automatic PR merging.

#### Prow Components

* **Hook**
    * This is the heart of Prow.
    * Responds to github events and dispatches them to respective plugins.
    * Hooks plugins are used to trigger jobs , implement 'slash' commands, post ot Slack and many more.
    * Plugins provide a great amount of extensibility.
    * Support for external plugins.

* **Horologium**
    * Responsible for triggering all the periodic jobs.

* **Plank**
    * Controller that manages job execution and lifecycle of K8s jobs.
    * Looks for jobs created by prow with agent Kubernetes.
    * Starts the jobs.
    * Updates jobs state.
    * Terminates duplicate pre-submit jobs.

* **Sinker**
    * Cleans up.
    * Deletes completed prow jobs.
    * Ensuring to kep the most recent completed periodic job.
    * Removes old completed pods.

* **Deck**
    * Provides a view of recent prow jobs.
    * Help on plugins and commands.
    * Status of merge automation (provided by Tide).
    * Dashboard for PR authors.

* **Tide**
    * Merge automation.
    * Batches and retests a group of PRs against latest HEAD.
    * Merge the changes.


##### Possible jobs in Prow
- presubmit
- postsubmit
- periodic
- batch

    > Possible states of a job
    - triggered
    - pending
    - success
    - failure
    - aborted
    - error

##### Deploy you own Prow cluster for continuous integration
1. Create a bot account. For info [look here](https://stackoverflow.com/questions/29177623/what-is-a-bot-account-on-github).


2. Create an oauth2 token from the github gui for the bot account.  

    `echo "PUT_TOKEN_HERE" > prow-bot-oauth2`

    `kubectl create secret generic oauth-token --from-file=oauth=prow-bot-oauth2`

3. Create an openssl token to be used with the Hook.

    `openssl rand -hex 20 > hmac-token`

    `kubectl create secret generic hmac-token --from-file=hmac=hmac-token`

4. Create all the Prow components.

    `kubectl create -f https://raw.githubusercontent.com/kubernetes/test-infra/master/prow/cluster/starter.yaml`

5. Update all the jobs and plugins needed for the CI.
    ```bash
    update-config:
        kubectl create configmap config --from-file=config.yaml=config.yaml --dry-run -o yaml | kubectl replace configmap config -f -

    update-plugins:
        kubectl create configmap plugins --from-file=plugins.yaml=plugins.yaml --dry-run -o yaml | kubectl replace configmap plugins -f -
    ```
6. Create a webhook to the github repository and use ultrahook.

    Install `ultrahook`

    ```bash
    echo "api_key: CCUs4r8diUCh4upO2EG5p1WpsNUfo0Ef" > ~/.ultrahook
    gem install ultrahook
    ```

    `ultrahook github http://192.168.99.100:31367/hook`

    `ultrahook github http://<MINIKUBE_IP>:<HOOK_NODE_PORT>/hook`

    this will give you a publicly accessible endpoint (in my case)

    http://github.sanster23.ultrahook.com
7. Create a docker hub credentials secret in k8s
  `kubectl create secret generic docker-creds --from-literal=username=<USERNAME> --from-literal=password=<PASSWORD>`
