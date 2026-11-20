# wtr

**wtr** is a simple command line client for the Rijkswaterstaat Waterinfo API, allowing users to query all kinds of water measurements from the Netherlands in a convenient way.

All data is retrieved from the *WaterWebservices API*, which is described [here](https://rijkswaterstaatdata.nl/waterdata/) (in dutch). In 2026 the API was updated, details about this can be found [here](https://rijkswaterstaatdata.nl/projecten/waterwebservices-overschakeling/), implemented in wtr version 0.5b.

The data is published by [Rijkswaterstaat](https://www.rijkswaterstaat.nl/en), which is part of the dutch *Ministry of Infrastructure and Water Management*.


## Installation

This software requires Python 3 (tested on 3.12 to 3.15) with the following additional libraries/packages:

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

(The description in this list is a generic catalogue entry. When you observe a location, wtr shows the description of the data actually returned.)

So the measure we need is named `WATHTE`. Next find a location that offers this measure:

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
# Description: Waterhoogte in Oppervlaktewater t.o.v. Normaal Amsterdams Peil in cm
# Compartment: OW (Oppervlaktewater)
# Measure: WATHTE (Waterhoogte)
# Location: culemborg (Culemborg)
#
# Timestamp                      Value
  2026-11-20T17:40:00.000+01:00  318.0
  2026-11-20T17:50:00.000+01:00  319.0
  2026-11-20T18:00:00.000+01:00  319.0
  2026-11-20T18:10:00.000+01:00  317.0
  2026-11-20T18:20:00.000+01:00  318.0
  2026-11-20T18:30:00.000+01:00  318.0
  2026-11-20T18:40:00.000+01:00  318.0
  2026-11-20T18:50:00.000+01:00  317.0
  2026-11-20T19:00:00.000+01:00  317.0
  2026-11-20T19:10:00.000+01:00  317.0
  2026-11-20T19:20:00.000+01:00  317.0
  2026-11-20T19:30:00.000+01:00  317.0
  2026-11-20T19:40:00.000+01:00  317.0
  2026-11-20T19:50:00.000+01:00  316.0
  2026-11-20T20:00:00.000+01:00  315.0
  2026-11-20T20:10:00.000+01:00  314.0
  2026-11-20T20:20:00.000+01:00  314.0
  2026-11-20T20:30:00.000+01:00  314.0
```

Default the most actual 18 rows are shown, which normally represents the past 3 hours (most measurements do have a 10 minute interval). If you want to go further back in time, use the `--rows` (or `-r`) option, for example:

``` sh
$ wtr observe -l culemborg -m WATHTE -r 144  # 24 hours
```

Notes:

- Although the list of locations and measures is extensive, not all are currently available. So for many combinations you will find no actual data. Often you get multiple locations for the same site, only one reporting the requested measure. Rijkswaterstaat promised to make more data available.
- Measure history is limited to 48 hours (288 rows for 10-minute data).
- Some locations publish both measurements and forecasts for the same measure. wtr shows the measurements.


## Compartments

Many measures exist in more than one *compartment*, for example `T` (temperature) in surface water (`OW`) and in air (`LT`). The location list shows which compartments a location offers:

``` sh
$ wtr list -c locations | grep "^hoekvanholland (.* - T "
hoekvanholland (Hoek van Holland): LT (Lucht) - T (Temperatuur)
hoekvanholland (Hoek van Holland): OW (Oppervlaktewater) - T (Temperatuur)
```

By default wtr uses surface water (`OW`) when the location offers it, otherwise the only compartment available. Use `--compartment` to choose another one:

``` sh
$ wtr observe -l hoekvanholland -m T --compartment LT -r 3
#
# Description: Temperatuur in Lucht in oC
# Compartment: LT (Lucht)
# Measure: T (Temperatuur)
# Location: hoekvanholland (Hoek van Holland)
#
# Timestamp                      Value
  2026-11-20T20:00:00.000+01:00  7.8
  2026-11-20T20:10:00.000+01:00  8.1
  2026-11-20T20:20:00.000+01:00  7.9
```

If a measure exists in several compartments at a location and none of them is `OW`, wtr asks you to choose one with `--compartment`.


## Exit codes

wtr exits with code 1 for an unknown location, measure or compartment, 2 for invalid command line arguments, and 0 otherwise (also when there is no data).


## Cache database

Lots of metadata is cached in a small SQLite database. This database is stored in `/tmp`, the filename is `.wtr_cache_<username>.db`. The database is created whenever you run `wtr` for the first time. To use another location, set the `WTR_CACHE` environment variable, e.g. `WTR_CACHE=~/.cache/wtr.db wtr list`.

Since the metadata gets updated sometimes, it is a good plan to update this cache once in a while. To do so, run `wtr update` or remove and recreate the cache file.


## Testing

`tests/functional.sh` runs wtr against the live API and checks the output and exit codes of every command and option. It needs network access:

``` sh
$ tests/functional.sh ./wtr
```

The same tests run on GitHub Actions for every push, on Python 3.12 to 3.15, together with `pylint`.


## About this project

This program was created in a moment of spontaneous creativity, to help out a visually impaired friend. It is a private project, donated to the open source community, and has no affiliation with *Rijkswaterstaat* or the dutch *Ministry of Infrastructure and Water Management*.

The official **wtr** code repository is [here](https://github.com/pa3hcm/wtr).


## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.
