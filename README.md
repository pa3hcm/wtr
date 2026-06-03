# wtr

**wtr** is a simple command line client for the Rijkswaterstaat Waterinfo API, allowing users to query all kinds of water measurements from the Netherlands in a convenient way.

All data is retrieved from the *WaterWebservices API*, which is described [here](https://rijkswaterstaatdata.nl/waterdata/) (in dutch). In 2026 the API was updated, details about this can be found [here](https://rijkswaterstaatdata.nl/projecten/waterwebservices-overschakeling/), implemented in wtr version 0.5b.

The data is published by [Rijkswaterstaat](https://www.rijkswaterstaat.nl/en), which is part of the dutch *Ministry of Infrastructure and Water Management*.


## Installation

This software requires Python 3 (tested on 3.12) with the following additional libraries/packages:

* requests

You can use `pip` to install these, e.g.:

```pip install -r requirements.txt```

You can copy the `wtr` file to any place in the system, maybe in your `~/bin` directory, or `.local/bin`, or in `/usr/local/bin`. Don't forget to give it the correct permissions, e.g.:

```chmod 755 /usr/local/bin/wtr```


## Getting started

To list observations you need two things: the type of *measure* and the *location*.

Run this command to obtain a list of available measures:

``` sh
$ wtr list -c measures
Compartment_Code (Description): Measure (Description) - Note
BS (Bodem/Sediment): ACTVTCCTTE (Activiteitsconcentratie) - Activiteitsconcentratie zilver 110m (metastabiel) in Bodem/Sediment t.o.v. drooggewicht in Bq/kg
BS (Bodem/Sediment): D10 (maximale korreldiameter voor 10% van het monstervolume) - maximale korreldiameter voor 10% van het monstervolume in Bodem/Sediment t.o.v. drooggewicht in um
(...)
```

Run this command to see all locations, including the available measure(s):

``` sh
$ wtr list -c locations
Location (Name): Compartment_Code (Description) - Measure (Description)
4epetroleumhaven (4e Petroleumhaven): OW (Oppervlaktewater) - CONCTTE ((massa)Concentratie)
4epetroleumhaven (4e Petroleumhaven): OW (Oppervlaktewater) - GELDHD (Geleidendheid)
4epetroleumhaven (4e Petroleumhaven): OW (Oppervlaktewater) - MASSFTE (Massafractie)
(...)
```

So let's say you want information about the water height near Culemborg. First find the corresponding measure, for example:

``` sh
$ wtr list -c measures | grep -i waterhoogte
OW (Oppervlaktewater): WATHTE (Waterhoogte) - Waterhoogte astronomisch in Oppervlaktewater t.o.v. Mean Sea Level in cm
```

So the measure we need is named `WATHTE`. Next find the location name for *Ameland*:

``` sh
$ wtr list -c locations | grep WATHTE
a12 (A12 platform): OW (Oppervlaktewater) - WATHTE (Waterhoogte)
aadorp (Aadorp): OW (Oppervlaktewater) - WATHTE (Waterhoogte)
aarlerixtel.schabbert.beneden (Aarle Rixtel, Schabbert, beneden): OW (Oppervlaktewater) - WATHTE (Waterhoogte)
(...)
```

We are interested in the location `culemborg`, so let's limit the list:

``` sh
$ wtr observe -l culemborg -m WATHTE
#
# Description: Waterhoogte astronomisch in Oppervlaktewater t.o.v. Mean Sea Level in cm
# Compartment: OW (Oppervlaktewater)
# Measure: WATHTE (Waterhoogte)
# Location: culemborg (Culemborg)
#
# Timestamp                      Value
  2026-06-03T07:30:00.000+01:00  275.0
  2026-06-03T07:40:00.000+01:00  275.0
  2026-06-03T07:50:00.000+01:00  276.0
  2026-06-03T08:00:00.000+01:00  276.0
  2026-06-03T08:10:00.000+01:00  276.0
  2026-06-03T08:20:00.000+01:00  275.0
  2026-06-03T08:30:00.000+01:00  275.0
  2026-06-03T08:40:00.000+01:00  276.0
  2026-06-03T08:50:00.000+01:00  277.0
  2026-06-03T09:00:00.000+01:00  276.0
  2026-06-03T09:10:00.000+01:00  276.0
  2026-06-03T09:20:00.000+01:00  277.0
  2026-06-03T09:30:00.000+01:00  276.0
  2026-06-03T09:40:00.000+01:00  277.0
  2026-06-03T09:50:00.000+01:00  276.0
  2026-06-03T10:00:00.000+01:00  278.0
  2026-06-03T10:10:00.000+01:00  276.0
  2026-06-03T10:20:00.000+01:00  277.0
```

Default the most actual 18 rows are shown, which normally represents the past 3 hours (most measurements do have a 10 minute interval). If you want to go further back in time, use the `--rows` (or `-r`) option, for example:

``` sh
$ wtr observe -l culemborg -m WATHTE -r 144  # 24 hours
```

Notes:

- Although the list of locations and measures is extensive, not all are currently available. So for many combinations you will find no actual data. Often you get multiple locations for the same site, only one reporting the requested measure. Rijkswaterstaat promised to make more data available.
- Measure history is limited to 48 hours (288 rows for 10-minute data).


## Cache database

Lots of metadata is cached in a small SQLite database. This database is stored in `/tmp`, the filename is `.wtr_cache_<username>.db`. The database is created whenever you run `wtr` for the first time.

Since the metadata gets updated sometimes, it is a good plan to update this cache once in a while. To do so, run `wtr update` or remove and recreate the cache file.


## About this project

This program was created in a moment of spontaneous creativity, to help out a visually impaired friend. It is a private project, donated to the open source community, and has no affiliation with *Rijkswaterstaat* or the dutch *Ministry of Infrastructure and Water Management*.

The official **wtr** code repository is [here](https://github.com/pa3hcm/wtr).


## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.
