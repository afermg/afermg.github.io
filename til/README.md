Collection of snippets of know-how I have accumulated.


# Recursive search and replace <span class="timestamp-wrapper"><span class="timestamp">&lt;2025-08-12 Tue&gt;</span></span>

It uses `ripgrep`, `xargs` and `GNU sed`. [source](https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md#search-and-replace).

    rg old_pattern --files-with-matches | xargs sed -i 's/old_pattern/new_pattern/g'


# Github code review on existing code base <span class="timestamp-wrapper"><span class="timestamp">&lt;2024-11-26 Tue&gt;</span></span>

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

