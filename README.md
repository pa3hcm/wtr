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

To list observations you need two things: the type of measure and the location.

Run this command to obtain a list of available measures:

``` sh
$ wtr list -c measures
Compartment_Code (Description): Measure (Description) - Note
BS (Bodem/Sediment): ACTVTCCTTE (Activiteitsconcentratie) - Activiteitsconcentratie americium 241 in Bodem/Sediment t.o.v. drooggewicht in Bq/kg
BS (Bodem/Sediment): D10 (maximale korreldiameter voor 10% van het monstervolume) - Maximale korreldiameter voor 10% van het monstervolume Bodem/Sediment t.o.v. drooggewicht in um
```

Run this command to see all locations, including the available measure(s):

``` sh
$ wtr list -c locations
Location (Name): Compartment_Code (Description) - Measure (Description)
A12 (A12 platform): LT (Lucht) - WINDRTG (Windrichting)
A12 (A12 platform): LT (Lucht) - WINDSTOOT (Maximale 3" windstoot in de afgelopen 10 minuten)
(...)
```

So let's say you want information about the flow rate in one of our rivers, dutch *stroomsnelheid*. First find the corresponding measure, for example:

``` sh
$ wtr list -c measures | grep -i stroom
OW (Oppervlaktewater): STROOMRTG (Stroomrichting) - Stroomrichting Oppervlaktewater t.o.v. ware Noorden in graad
OW (Oppervlaktewater): STROOMSHD (Stroomsnelheid) - Stroomsnelheid Oppervlaktewater m/s
```

So the measure we need is named `STROOMSHD`. Next find locations for this measure:

``` sh
$ wtr list -c locations | grep STROOMSHD
ALBL (Alblasserdam): OW (Oppervlaktewater) - STROOMSHD (Stroomsnelheid)
ALBSDRTOVR (Alblasserdam rechteroever (nabij brug)): OW (Oppervlaktewater) - STROOMSHD (Stroomsnelheid)
BORNDP (Borndiep): OW (Oppervlaktewater) - STROOMSHD (Stroomsnelheid)
(...)
```

We are interested in the location *ALBL*, so let's limit the list

``` sh
$ wtr observe -l ALBL -m STROOMSHD
#
# Description: Stroomsnelheid Oppervlaktewater m/s
# Compartment: OW (Oppervlaktewater)
# Measure: STROOMSHD (Stroomsnelheid)
# Location: ALBL (Alblasserdam)
#
# Timestamp                      Value
  2023-12-29T06:20:00.000+01:00  -0.427
  2023-12-29T06:30:00.000+01:00  -0.348
  2023-12-29T06:40:00.000+01:00  -0.272
  2023-12-29T06:50:00.000+01:00  -0.227
  2023-12-29T07:00:00.000+01:00  -0.15
  2023-12-29T07:10:00.000+01:00  -0.075
  2023-12-29T07:20:00.000+01:00  0.021
  2023-12-29T07:30:00.000+01:00  0.125
  2023-12-29T07:40:00.000+01:00  0.218
  2023-12-29T07:50:00.000+01:00  0.286
  2023-12-29T08:00:00.000+01:00  0.377
  2023-12-29T08:10:00.000+01:00  0.465
  2023-12-29T08:20:00.000+01:00  0.525
  2023-12-29T08:30:00.000+01:00  0.567
  2023-12-29T08:40:00.000+01:00  0.616
  2023-12-29T08:50:00.000+01:00  0.662
  2023-12-29T09:00:00.000+01:00  0.717
  2023-12-29T09:10:00.000+01:00  0.78
```

Notes:

- Although the list of locations and measures is extensive, not all are currently in use. So for many combinations you will find no actual data. Often you get multiple locations for the same site, only one reporting the requested measure.
- Measures are reported from midnight.


## Cache database

Lots of metadata is cached in a small SQLite database. This database is stored in `/tmp`, the filename is `.wtr_cache_<username>.db`. The database is created whenever you run *wtr* for the first time.

Since the metadata gets updated sometimes, it is a good plan to update this cache once in a while. To do so, run this command: 

```wtr update```

To remove the database, run:

```wtr clean```