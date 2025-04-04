## R CMD check results

0 errors | 0 warnings | 3 notes

* This is a new release.

We have addressed all comments that were kindly provided by the reviewer:
- Added reference to description and doi
- Added value to Rd files that were missing the tag
- We uncommented examples in getCitations.Rd
- Updated function to not write any files into home filespace by default
- We make sure that when user's options are changed they go back to the default on exit

Note 1:
Possibly misspelled words in DESCRIPTION:
  McTavish (16:277)
  al (16:289)
  clootl (16:72)
  et (16:286)

All these words are OK. 

Note 2: 
Found the following (possibly) invalid file URIs:
  URI: examples/intro.md
    From: README.md
  URI: examples/dataDownload.md
    From: README.md
  URI: examples/avonet.md
    From: README.md

All URIs are valid

Note 3:
checkRd: (-1) clootl_data.Rd:47-49: Lost braces
    47 | for (inputs in all_nodes$source_id_map) {
       |                                         ^
       
There are no missing brackets. 
