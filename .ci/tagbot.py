#!/usr/bin/env python

import json
import os
import re

from github import Github

WARNING = """
TagBot as a GitHub App is deprecated in favour of TagBot as a GitHub Action.
This comes with the significant advantage of no longer needing to hand over repository write permissions to an unknown third party.
See [here](https://github.com/marketplace/actions/julia-tagbot) for more information on installing TagBot as a GitHub Action.

cc: {}
"""

with open(os.environ["GITHUB_EVENT_PATH"]) as f:
    event = json.load(f)
gh = Github(os.environ["API_TOKEN"])
r = gh.get_repo(os.environ["GITHUB_REPOSITORY"])
pr = r.get_pull(event["issue"]["number"])
creator = re.search("- Created by: (@.+)", pr.body).group(1)
pr.create_issue_comment(WARNING.format(creator))
