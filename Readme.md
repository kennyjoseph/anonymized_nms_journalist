# Overview

This repository provides replication data and code for the following paper:

```
@article{wihbey_exploring_2017,
  title = {The social silos of journalism? Twitter, news media and partisan segregation,
  archivePrefix = {arXiv},
  eprinttype = {arxiv},
  eprint = {1708.06727},
  primaryClass = {cs},
  journal = {arXiv:1708.06727 [cs]},
  author = {Wihbey, John and Coleman, Thalita Dias and Joseph, Kenneth and Lazer, David},
  month = aug,
  year = {2017},
  keywords = {Computer Science - Social and Information Networks}
}
```

The primary file for replication is ```analysis.R```

***In order to keep the data anonymous, the only data provided are anonymized data input to create figures in the text and to run the regression model.  If you would like to replicate other parts of the paper that involve additional, deanonymized data, please contact the authors.  While those we study are public figures, and thus such data can potentially be made available, we do not wish to make results that could be used against individuals fully public.***


# Twitter Ideology Method
We provide the code used to create our Twitter ideology score, although note that the data required are only available from the authors (as noted above). Given this data, results can be replicated as follows:

1. Enter into the ```data``` directory and untar ```heavy_user_friends.tgz``` and ```reporter_friends.tgz```. 
2.  [Download](https://www.dropbox.com/s/y5hfrgah0ldcei7/congress_followers.tgz?dl=0) the follower data for Congresspeople, put it into the ```data``` directory, and untar it. From the command line, you can run steps 1 and 2 as follows:

```
cd data
tar -xzvf heavy_user_friends.tgz
tar -xzvf reporter_friends.tgz
wget https://www.dropbox.com/s/y5hfrgah0ldcei7/congress_followers.tgz?dl=0
mv congress_followers.tgz?dl=0 congress_followers.tgz
tar -xzvf congress_followers.tgz
```
2. Run ```twitter_ideology_method.ipynb```

# News Ideology Method

We also cannot release the newspaper data we collected.   However, we do provide the script ```newspaper.py```, which shows how, given a list of articles from an author (extracted from MuckRack), we preprocess the data for input into our method. We then run ```news_ideology_method.ipynb``` to generate the text-based ideology score.

# Putting it all together to replicate paper
1. Run ```analysis.R```. Note that in order to compare our results to the work from [Bakshy et al.](http://science.sciencemag.org/content/348/6239/1130), you will have to request the file ```top500.tab``` from their [Dataverse repository](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/LDJ7MS), rename it to ```top500.csv```, and put it into the ```data``` directory.


# More info on ```data``` directory

- We collected bill sponsorship data from [GovTrack](https://www.govtrack.us/) and congressional social media data from the awesome [congress-legislators](https://github.com/unitedstates/congress-legislators/) github respository using the following commands:

```
wget https://www.govtrack.us/data/us/115/stats/sponsorshipanalysis_h.txt
wget https://www.govtrack.us/data/us/115/stats/sponsorshipanalysis_s.txt
wget https://github.com/unitedstates/congress-legislators/blob/master/legislators-current.yaml
wget https://github.com/unitedstates/congress-legislators/blob/master/legislators-social-media.yaml
```

- We used the [twitter_dm](https://github.com/kennyjoseph/twitter_dm) Github library to collect basic information about the Twitter accounts of our journalist accounts and our heavy political users.  This data is in ```data/basic_twitter_info.tsv``` and ```data/heavy_pol_basic_twitter_info.tsv```.  This was done during May of 2017. 

- We also used [twitter_dm](https://github.com/kennyjoseph/twitter_dm) to collect the followers of Congressional accounts and the friends of the heavy political users and journalists. This was also done during May of 2017 (these are the tar files from Steps 1. and 2. above)

- The file ```data/org_info.tsv``` provides hand-constructed information on the news organizations we considered for this study, plus several others.



