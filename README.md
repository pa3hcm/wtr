# wtr

**wtr** will be a simple command line client for the Rijkswaterstaat Waterinfo API, allowing users to query all kinds of water measurements from the Netherlands in a convenient way.

All data is retrieved from *WaterWebservices* API, which is described [here](https://rijkswaterstaatdata.nl/waterdata/) (in dutch). The data origins from [Rijkswaterstaat](https://www.rijkswaterstaat.nl/en), which is part of the dutch *Ministry of Infrastructure and Water Management*.

## Installation

This software requires Python 3 (tested on 3.10) with the following additional libraries/packages:

* requests

You can use `pip` to install these, e.g.:

```pip install -r requirements.txt```

You can copy `wtr` to any place in the system, maybe in your `~/bin` directory, or `.local/bin`, or in `/usr/local/bin`. Don't forget to give it the correct permissions, e.g.:

```chmod 755 /usr/local/bin/wtr```


## Getting started

tbd...


## Cache database

Lots of metadata is cached in a small SQLite database. This database is stored in `/tmp`, the filename is `.wtr_cache_<username>.db`. The database is created whenever you run *wtr* for the first time.

Since the metadata gets updated sometimes, it is a good plan to update this cache once in a while. To do so, run this command: 

```wtr update```

To remove the database, run:

```wtr clean```
