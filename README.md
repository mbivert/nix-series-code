# Introduction
This git repository contains code presented in a series of articles
introducing functional programming via Nix's language:

  1. [On Nix's Language: Introduction][tales-nix-1];
  2. [On Nix's Language: Recursive Functions][tales-nix-2];
  3. [On Nix's Language: Closures][tales-nix-3];
  4. [On Nix's Language: Pragmatism, laziness][tales-nix-4];
  5. [On Nix's Language: Mathematical Expressions, Brainf*ck][tales-nix-5];
  6. [On Nix's Language: Lambda Calculus Interpreter][tales-nix-6].

**<u>Note</u>**: Some of the code doesn't compile, on purpose (e.g.
[hw1][gh-mb-nix-hw1]).

**<u>Note</u>**: You can run all (automated) tests with ``make tests``.

**<u>Note</u>**: ``lambda/`` essentially contains [``lambda.nix``][gh-mb-nix-lambda] and
[``lambda_test.nix``][gh-mb-nix-lambda-test] split in multiple files for easier
inclusion in the related [article][tales-nix-6]. Furthermore, there's a great
deal of redundancies in [``lambda_test.nix``][gh-mb-nix-lambda-test].

**<u>Note</u>**: For more on the automated tests
([``ftests.nix``][gh-mb-nix-ftests]) see this [article][tales-ftests].

[gh-mb-nix-hw1]:         https://github.com/mbivert/nix-series-code/blob/master/hw/hw1.nix
[gh-mb-nix-lambda]:      https://github.com/mbivert/nix-series-code/blob/master/lambda.nix
[gh-mb-nix-lambda-test]: https://github.com/mbivert/nix-series-code/blob/master/lambda_test.nix
[gh-mb-nix-ftests]:      https://github.com/mbivert/nix-series-code/blob/master/ftests.nix

[tales-nix-1]:           https://tales.mbivert.com/on-nix-language/
[tales-nix-2]:           https://tales.mbivert.com/on-nix-language-recursive-functions/
[tales-nix-3]:           https://tales.mbivert.com/on-nix-language-closures/
[tales-nix-4]:           https://tales.mbivert.com/on-nix-language-pragmatism-laziness/
[tales-nix-5]:           https://tales.mbivert.com/on-nix-language-maths-expressions-brainfuck/
[tales-nix-6]:           https://tales.mbivert.com/on-nix-language-lambda-calculus/
[tales-ftests]:          https://tales.mbivert.com/on-a-function-based-test-framework/