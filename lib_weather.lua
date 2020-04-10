local WEATHER = {
  API_KEY = "9f418d12e2c0f5e721197b55a91010a3";
  BASE_URL = "http://api.openweathermap.org/data/2.5/weather";
  UNITS = "metric"
}

-- lib used
-- http, sjson

-- execute the url request and attempt to parse the result as JSON within the response. calls the
-- response into the result callback (with json) and error callback on fault with anything that is a
-- error with code and raw data.
--
-- url (string): The url being requested.
-- result_callback (function | nil): The results callback with the parsed data.
-- error_callback (function | nil): The error callback for error cases with code and raw data.
local function execute_and_decode(url, result_callback, error_callback)
  http.get(url, nil, function (code, data)
      if code >= 200 and code <= 299 and result_callback ~= nil then
        result_callback(sjson.decode(data))
      end

      if error_callback ~= nil then
        error_callback(code, data)
      end
  end)
end

-- Gets the current weather for the city and country.
--
-- city (string): The name of the city being gathered.
-- country (string): The name of the country the city is based in.
-- result_callback (function | nil): The results callback with the parsed data.
-- error_callback (function | nil): The error callback for error cases with code and raw data.
local function get_weather_by_city_and_country(city, country, result_callback, error_callback)
  local url = string.format("%s?q=%s,%s&appid=%s&units=%s", WEATHER.BASE_URL, city, country,
  WEATHER.API_KEY, WEATHER.UNITS);

  execute_and_decode(url, result_callback, error_callback);
 end

-- Gets the current wather for the city
--
-- city (string): The name of the city being gathered.
-- result_callback (function | nil): The results callback with the parsed data.
-- error_callback (function | nil): The error callback for error cases with code and raw data.
local function get_weather_by_city(city, result_callback, error_callback)
  local url = string.format("%s?q=%s,%s&appid=%s&units=%s", WEATHER.BASE_URL, city, 
    WEATHER.API_KEY, WEATHER.UNITS);

  execute_and_decode(url, result_callback, error_callback);
end

-- Gets the current wather for the city by id.
--
-- city_id (number | string): The id of the city being gathered.
-- result_callback (function | nil): The results callback with the parsed data.
-- error_callback (function | nil): The error callback for error cases with code and raw data.
local function get_weather_by_city_id(city_id, result_callback, error_callback)
  local url = string.format("%s?id=%s&appid=%s&appid=%s&units=%s", WEATHER.BASE_URL, city_id,
    WEATHER.API_KEY, WEATHER.UNITS);

  execute_and_decode(url, result_callback, error_callback);
end

-- Gets the current wather by zipcode and country code.
--
-- zip_code (number | string): The zip-cide of the locations weather being gathered.
-- country (number | string): The country the zipcode is based in.
-- result_callback (function | nil): The results callback with the parsed data.
-- error_callback (function | nil): The error callback for error cases with code and raw data.
local function get_weather_by_zip_and_country(zip_code, country, result_callback, error_callback)
  local url = string.format("%s?zip=%s,%s&appid=%s&appid=%s&units=%s", WEATHER.BASE_URL, zip_code,
    country, WEATHER.API_KEY, WEATHER.UNITS);

  execute_and_decode(url, result_callback, error_callback);
end

-- Gets the current wather for the lat and lon.
--
-- lat (number | string): The lat of the location weather to be gathered.
-- lon (number | string): The lon of the location weather to be gathered.
-- result_callback (function | nil): The results callback with the parsed data.
-- error_callback (function | nil): The error callback for error cases with code and raw data.
local function get_weather_by_lat_lon(lat, lon, result_callback, error_callback)
  local url = string.format("%s?lat=%s&lon=%s&appid=%s&units=%s", WEATHER.BASE_URL, lat, lon,
    WEATHER.API_KEY, WEATHER.UNITS);

  execute_and_decode(url, result_callback, error_callback);
end

WEATHER.get_weather_by_city_and_country = get_weather_by_city_and_country;
WEATHER.get_weather_by_city = get_weather_by_city;
WEATHER.get_weather_by_city_id = get_weather_by_city_id;
WEATHER.get_weather_by_lat_lon = get_weather_by_lat_lon;
WEATHER.get_weather_by_zip_and_country = get_weather_by_zip_and_country;

return WEATHER