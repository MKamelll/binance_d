import std.stdio;
import dotenv;

import client;
import binance;


void main()
{
	Env.load;
	auto api_key = Env["api_key"];
	auto secret_key = Env["secret_key"];
	auto end_point = "/api/v3/time";
	
	auto bn = new Binance(api_key, secret_key);
	writeln(bn.client.get_request(end_point));
}
