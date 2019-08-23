# weather_app
Simple app to display weather information from openweathermap.org API

Uses static location (city 'Olomouc,CZ').

How to run it:
- clone this repository and go into folder
- run `bundle install`
- get key for API on https://openweathermap.org/current and set it as environment variable `OPEN_WEATHER_API_KEY`(eg. on Linux: `export OPEN_WEATHER_API_KEY='8ce0...6e3'`)
- run `bundle exec rake test`
- if it passes, run app `bundle exec ruby weather_app`
- open browser at `http://localhost:4567/` and You will see current temperature (got only 1 record now)
- keep page open for some time (at least 30 minutes to see difference), it will collect data and display average temperature

