# Whippet Application Tagger

This runs a GitHub action on a schedule (once an hour), that looks for all repos in the dxw organization that have a `whippet.lock` file in the root, and adds the "whippet-app" topic to them.

This is primarily because GitHub's code search API does not return consistent results, so we can't rely on it to correctly identify all Whippet repos every time. So instead, we run this task hourly (to ensure that any repos it misses get tagged in one of the next runs), and search by the "whippet-app" topic when we want to find all Whippet applications we're managing in GitHub.

The script uses GitHub CLI (authenticated as a service user account) to interact with the relevant repos. The token for authenticating with GitHub CLI is a secret stored as `GOVPRESS_TOOLS_TOKEN`.

## Testing locally

You can run the main script locally whilst logged into your own account with GitHub CLI:

```
gh auth login
...
bin/whippet-application-tagger.sh
```

Or you can run the action as a whole using (act)[https://github.com/nektos/act]:

* Install act: `brew install act`
* Run the action: `act -j whippet-application-tagger -s GOVPRESS_TOOLS_TOKEN=[a token that has repo and org access]`

Note: this will actually run the action against live data, so will add the topic to any relevant repos that don't already have it.
