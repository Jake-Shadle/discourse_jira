# discourse_jira
Discourse Onebox plugin for JIRA, currently it is completely static, so changing the status of the issue will not affect any pre-existing links in Discourse.

Currently supports links in the format of https://hostname.org/browse/ISSUE-ID or https://hostname.org/projects/PROJECT/issues/ISSUE-ID 
Also supports grabbing a link that may have query string parameters.

Formats the Onebox preview like Github