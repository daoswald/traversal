# traversal
Various examples of filesystem traversal

Imagine a filesystem beginning at some path within a user's homedir such as public_html.

Imagine a subroutine named is_infected() or is_wanted(), that tells you if a specific file has a problem.

Write an algorithm that finds the deepest point within this directory structure where the "infection" can be found.

Bonus points for considering symlinks and circular directory structures (thanks to links).

Create the algorithms as modules named DirTraverse::[your_name_here].pm

The tests in t/ will be used to prove the correctness.  If you feel tests should be added to the suite, please provide
them in a branch separate from your module submission so that they can be layered in separately.


