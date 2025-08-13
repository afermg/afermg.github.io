+++
title = "Github code review on existing code base"
author = ["Alán F. Muñoz"]
date = 2024-11-26T13:06:00-05:00
tags = ["til", "github", "code", "review"]
draft = false
+++

Create an empty branch with one empty commit

1.  Create new branch `git checkout --orphan review-1-target`
2.  Reset `git reset .`
3.  Clean branch `git clean -df`
4.  Add empty commit `git commit --allow-empty -m 'Empty commit'`

Rebase a branch to put this commit at the root

1.  Push to your fork `git push -u origin review-1-target`
2.  Move to branch to review `git checkout origin/main`
3.  Spin-off branch from here `git checkout -b review-1`
4.  Rebase to empty branch `git rebase -i review-1-target`, the empty commit must be at the start
5.  Push `git push -u origin review-1`

That should make a pull request possible, providing the code review tooling.
[source](https://thib.me/recipe-code-reviews-for-existing-code-with-github)
