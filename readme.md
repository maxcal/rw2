#Remote Wind

Remote wind is a service that collects live wind data, and makes it available in various ways.
It is a Rails based REST application.

This open-source project is available under a [GNU GPL v3 license](http://www.gnu.org/copyleft/gpl.html)

See the [project wiki](https://github.com/remote-wind/remote-wind/wiki) for more detailed information.

### Requirements

```
RVM > 1.2
Ruby >= 2.0.0
Postgres > 9.3
```

## Installation
- set up RVM to use ruby 2.0.0 and create a gemset named remote-wind
- clone the repo
- bundle install

### Enviromental vars
The app uses enviromental vars in to avoid checking in passwords and local enviroment config.
Add the following to your ~/.profile (os-x) or  ~/.bash_profile (linux)
```
export REMOTE_WIND_EMAIL="your@email.com"
export REMOTE_WIND_PASSWORD="password"
export REMOTE_WIND_GEONAMES="username"
export REMOTE_WIND_FB_APP_ID="id"
export REMOTE_WIND_FB_APP_SECRET="secret"
export REMOTE_WIND_EMAIL_PASSWORD="secret"
```
REMOTE_WIND_GEONAMES is a [geonames.org](http://www.geonames.org) username.

#### Adding vars to your OS-X destop enviroment
If you use an IDE on OS-x such as rubymine, you should add the following to /etc/launchd.conf
(you do not need to add them to ~/.profile as well).
```
set_env REMOTE_WIND_EMAIL your@emai.com
set_env REMOTE_WIND_PASSWORD password
set_env REMOTE_WIND_GEONAMES username
set_env REMOTE_WIND_FB_APP_ID id
set_env REMOTE_WIND_FB_APP_SECRET secret
set_env REMOTE_WIND_EMAIL_PASSWORD secret
```
Note that the values should not be quoted!
```
source /etc/launchd.conf
```

## Continuus testing with Guard and Zeus
```
zeus start
bundle exec guard (in a new tab)
```

## RailsPanel

This application supports debugging in Google chrome via [the RailsPanel extension](https://chrome.google.com/webstore/detail/railspanel/gjpfobpafnhjhbajcjgccbbdofdckggg)

## Postgres
This app defaults to using SQLite for the dev environment but can be used with Postgres.
Postgres can configured via the following enviromental vars:

```
REMOTE_WIND_DATABASE_ADAPTER # set to postgresql
REMOTE_WIND_POSTGRES_DATABASE_DEV # database name; defaults to remote_wind_dev
REMOTE_WIND_POSTGRES_PASSWORD # if needed
REMOTE_WIND_POSTGRES_USER # if needed
REMOTE_WIND_POSTGRES_HOST # if needed
```
