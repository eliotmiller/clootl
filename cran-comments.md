## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

We have addressed all comments that were kindly provided by the reviewer:
- Changed relative URIs to absolute on README.
- Added reference to description and doi
- Added value to Rd files that were missing the tag
- We uncommented examples in getCitations.Rd
- Updated function to not write any files into home filespace by default
- We make sure that when user's options are changed they go back to the default on exit

## Test environments:

* local OS X install, R 4.3.3
* github actions: macOS Big Sur 10.16, x86_64-apple-darwin17.0, R 4.3.3
* github actions: Ubuntu 20.04.5, x86_64-pc-linux-gnu, R development
* github actions: Windows Server x64 (build 20348), x86_64-w64-mingw32, R development

* Note 1:
```
Possibly misspelled words in DESCRIPTION:
  McTavish (16:277)
  al (16:289)
  clootl (16:72)
  et (16:286)
```
**Comments**: <br/>
All these words are OK. 



