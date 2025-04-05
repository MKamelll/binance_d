module client;

import std.net.curl;
import std.conv;
import std.digest.hmac;
import std.digest.sha;
import std.string;
import std.datetime;
import std.uri;
import std.json;

import binance;

class HowTheHellDidYouGetHere : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe
	{
		super(msg, file, line, nextInChain);
	}
}


class Client {

	Binance bn;
	auto base_url = "https://api.binance.com";
	string endpoint;
	string method;	
	string[string] query_params = null;
	string[string] headers = null;
	bool auth = false;

	this(Binance bn)
	{
		this.bn = bn;
	}

	auto add_header(string key, string value)
	{
		headers[key] = value;
		return this;
	}

	auto add_param(string key, string value)
	{
		query_params[key] = value;
		return this;
	}

	auto uri_encode_list(string[] s)
	{
		string json_s = JSONValue(s).toString;
		return encodeComponent(json_s);
	}

	auto timestamp()
	{
		return "timestamp=" ~ to!string(Clock.currTime.toUnixTime * 1000);
	}

	auto signature(string query)
	{
		auto hmac = HMAC!SHA256(cast(ubyte[])bn.secret_key);
		hmac.put(cast(ubyte[])query);
		auto digest = toLower(dup(toHexString(hmac.finish())));
		return digest;
	}

	auto auth_request(HTTP.Method method)
	{
		ubyte[] response;
		string query;
		if (query_params is null) {
			query = timestamp();
		} else {
			foreach (key, val; query_params)
			{
				query ~= key ~ "=" ~ val ~ "&";
			}
			query = query ~ timestamp();
		}
		auto url = base_url ~ endpoint ~ "?" ~ query ~ "&signature=" ~ signature(query);
		auto http = HTTP();
		http.addRequestHeader("X-MBX-APIKEY", bn.api_key);
		if (headers !is null)
		{
			foreach (key, value; headers)
			{
				http.addRequestHeader(key, value);
			}
		}
		http.url(url);
		http.method(method);
		http.onReceive = (ubyte[] data) {
            response ~= data;
			return data.length;
		};

		http.perform();

		return cast(string)response;
	}

	auto request(HTTP.Method method)
	{
		ubyte[] response;
		string query;
		if (query_params !is null)
		{
			foreach (key, val; query_params)
			{
				query ~= key ~ "=" ~ val ~ "&";
			}
			
			query = query[0..$-1];
		}

		auto url = base_url ~ endpoint ~ "?" ~ query;
		auto http = HTTP();
		http.addRequestHeader("X-MBX-APIKEY", bn.api_key);
		if (headers !is null)
		{
			foreach (key, value; headers)
			{
				http.addRequestHeader(key, value);
			}
		}
		http.url(url);
		http.method(method);
		http.onReceive = (ubyte[] data) {
			response ~= data;
			return data.length;
		};

		http.perform();

		return cast(string)response;
	}

	auto perform()
	{
		switch (toLower(method))
		{
			case "get":
			{
				if (auth) { return auth_request(HTTP.Method.get); }
				return request(HTTP.Method.get);
			}
			
			case "post":
			{
				if (auth) { return auth_request(HTTP.Method.post); }
				return request(HTTP.Method.post);
			}

			case "delete":
			{
				if (auth) { return auth_request(HTTP.Method.del); }
				return request(HTTP.Method.del);
			}

			case "put":
			{
				if (auth) { return auth_request(HTTP.Method.put); }
				return request(HTTP.Method.put);
			}
			default:
			{
				throw new HowTheHellDidYouGetHere("unknown request type");
			}
		}
	}
}