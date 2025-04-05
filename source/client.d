module client;

import std.net.curl;
import std.conv;
import std.digest.hmac;
import std.digest.sha;
import std.string;
import std.datetime;
import std.encoding;
import binance;

class Client {

	Binance bn;
	auto base_url = "https://api.binance.com";
	
	this(Binance bn)
	{
		this.bn = bn;
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

	auto auth_get_request(string endpoint, string[string] query_params=null, string[string] headers=null)
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
		http.onReceive = (ubyte[] data) {
            response ~= data;
			return data.length;
		};

		http.perform();

		return cast(string)response;
	}

	auto get_request(string endpoint, string[string] query_params=null, string[string] headers=null)
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
		http.onReceive = (ubyte[] data) {
			response ~= data;
			return data.length;
		};

		http.perform();

		return cast(string)response;
	}
}