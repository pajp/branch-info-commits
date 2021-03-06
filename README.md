What's this?
------------

*WARNING*: THIS IS AN EXPERIMENT. IT CHANGES STUFF THAT PROBABLY 
SHOULDN'T BE CHANGED IN WAYS THAT PROBABLY SHOULDN'T BE DONE.

USE ON YOUR OWN RISK. IT MAY CORRUPT YOUR REPOSITORY AND/OR YOUR
COMMITS. REALLY.

This is a utility to track information about which branch the author
was working on when creating each commit. This can make it easier to
figure out the context of a particular commit without tracing it to
the nearest merge/branch point.

The script "add-hdr-to-head.rb" can be used as a post-commit hook that
will modify the head commit object to contain information about the
current branch. The result is saved as a new commit object and the
branch head is changed to point to the new object.

Currently, it doesn't work well with rebased commits (the branch
information gets lost in the rebase process).

Information about the working branch can be retrieved from a
particular commit object by issuing the following command:

    git cat-file -p 1cb7f76b5 | grep ^x-working-branch


A version of gitk able to show this information is available here:
  https://github.com/pajp/git/tree/x-working-branch/gitk-git

You can see how it looks here:

![gitk screenshot](https://github.com/downloads/pajp/branch-info-commits/gitk-branches.png)

As you can see, it's easy to see the commits created in the "redshirt"
branch without tracing upwards to the merge commit even though the
branch has been deleted.

Why?
----

In a typical git workflow, you can see the relationship of all
commits, but context information, such as in which branch a particular
commit was introduced, is sometimes hard to find. You may have to
trace back (or forward) to the nearest branch or merge to see if a
commit came from a branch called "experimental" or
"maintenance". Adding this metadata to the commit object preserves
this information without cluttering the commit log message.

