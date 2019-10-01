# Web Scraper
By: Parimal Mehta ([@prmehta24](https://github.com/prmehta24)) and Parth Panchal ([@Parth19499](https://github.com/Parth19499))

This program will crawl a given website and its links upto a given depth looking for a given keyword. It will return:

* the paragraphs in which the keyword is found
* the number of visited links
* the links visited as well as the number of occurrences of the keyword per link

## Prerequisites
* Perl (https://learn.perl.org/installing/)
* Git (https://git-scm.com/)

## Steps to Run:

* `git clone https://github.com/Parth19499/WebCrawler.git`
* In Command Prompt: `cpan LWP::UserAgent HTML::LinkExtor URI::URL LWP::Simple HTTP::Request HTTP::Response HTML::Strip HTML::DOM` 
* In Command Prompt: Navigate to cloned folder and run `perl WebCrawler.pl`

## Limitations

* Only allows one word search
* Not all websites are accessible by crawler
* HTML::Strip which is used to remove tags from text is not perfect.(https://metacpan.org/pod/HTML::Strip#LIMITATIONS)
* The number of occurences stored in hashmap is for occurences in source code, not just paragraphs

## Notes
* To change base url for crawling, edit `$url` variable
* To change number of links traversed per page, edit `$linklim`

## Future Work
* Store paragraphs retrieved in file
